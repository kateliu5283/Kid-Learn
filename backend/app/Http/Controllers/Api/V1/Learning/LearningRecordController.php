<?php

namespace App\Http\Controllers\Api\V1\Learning;

use App\Http\Controllers\Controller;
use App\Models\Question;
use App\Models\Student;
use App\Models\StudentLearningRecord;
use App\Models\User;
use App\Support\LearningActivityLabels;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

/**
 * App 上傳答題／遊戲成績（家長 Sanctum）。家長／教師於 Filament 檢視。
 *
 * 若帶 `answers`（question_code + selected_index），由伺服器依題庫評分；
 * 題庫找不到的題目（本機課綱）則回退客戶端分數。遊戲仍走客戶端計分。
 */
class LearningRecordController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $user = $this->requireParent($request);

        $data = $request->validate([
            'student_id' => [
                'nullable',
                'integer',
                Rule::exists('students', 'id')->where('parent_user_id', $user->id),
            ],
            'device_local_id' => ['nullable', 'string', 'max:64'],
            'activity_type' => ['required', 'string', Rule::in(array_keys(LearningActivityLabels::options()))],
            'context_key' => ['nullable', 'string', 'max:120'],
            'title' => ['nullable', 'string', 'max:255'],
            'correct_count' => ['nullable', 'integer', 'min:0', 'max:100000'],
            'question_count' => ['nullable', 'integer', 'min:0', 'max:100000'],
            'score_percent' => ['nullable', 'integer', 'min:0', 'max:100'],
            'duration_seconds' => ['nullable', 'integer', 'min:0', 'max:86400'],
            'meta' => ['nullable', 'array', 'max:16'],
            'answers' => ['nullable', 'array', 'min:1', 'max:100'],
            'answers.*.question_code' => ['required', 'string', 'max:120'],
            'answers.*.selected_index' => ['required', 'integer', 'min:0', 'max:50'],
            'client_submission_id' => ['nullable', 'string', 'max:64'],
            'recorded_at' => ['nullable', 'date'],
        ]);

        abort_unless(
            ! empty($data['student_id']) || ! empty($data['device_local_id']),
            422,
            '請提供 student_id 或 device_local_id。',
        );

        $hasAnswers = ! empty($data['answers']);
        abort_unless(
            $hasAnswers
                || (isset($data['correct_count']) && isset($data['question_count'])),
            422,
            '請提供 answers，或同時提供 correct_count 與 question_count。',
        );

        if (isset($data['recorded_at'])) {
            $recordedAt = \Carbon\Carbon::parse($data['recorded_at']);
            if ($recordedAt->gt(now()->addMinutes(10)) || $recordedAt->lt(now()->subYear())) {
                throw ValidationException::withMessages([
                    'recorded_at' => ['紀錄時間超出允許範圍。'],
                ]);
            }
        }

        $student = $this->resolveStudent($user, $data);

        if (! empty($data['client_submission_id'])) {
            $existing = StudentLearningRecord::query()
                ->where('student_id', $student->id)
                ->where('client_submission_id', $data['client_submission_id'])
                ->first();
            if ($existing) {
                return response()->json([
                    'data' => $existing->toApiArray(),
                    'duplicate' => true,
                ]);
            }
        }

        $meta = $this->sanitizeMeta($data['meta'] ?? null) ?? [];
        [$c, $q, $grading] = $this->resolveScore($data, $hasAnswers);
        $meta['grading'] = $grading;

        if ($q > 0 && $c > $q) {
            abort(422, 'correct_count 不可大於 question_count。');
        }

        $pct = $data['score_percent'] ?? null;
        if ($grading === 'server' || $pct === null) {
            $pct = $q > 0 ? (int) round(($c / $q) * 100) : null;
        }

        $record = StudentLearningRecord::query()->create([
            'student_id' => $student->id,
            'activity_type' => $data['activity_type'],
            'context_key' => $data['context_key'] ?? null,
            'title' => $data['title'] ?? null,
            'correct_count' => $c,
            'question_count' => $q,
            'score_percent' => $pct,
            'duration_seconds' => $data['duration_seconds'] ?? null,
            'meta' => $meta === [] ? null : $meta,
            'client_submission_id' => $data['client_submission_id'] ?? null,
            'recorded_at' => isset($data['recorded_at'])
                ? \Carbon\Carbon::parse($data['recorded_at'])
                : now(),
        ]);

        return response()->json(['data' => $record->toApiArray()], 201);
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array{0: int, 1: int, 2: string}
     */
    protected function resolveScore(array $data, bool $hasAnswers): array
    {
        if (! $hasAnswers) {
            return [
                max(0, (int) $data['correct_count']),
                max(0, (int) $data['question_count']),
                'client',
            ];
        }

        /** @var list<array{question_code: string, selected_index: int}> $answers */
        $answers = $data['answers'];
        $codes = collect($answers)->pluck('question_code')->unique()->values()->all();

        $questions = Question::query()
            ->whereIn('code', $codes)
            ->where('is_published', true)
            ->where('approval_status', Question::APPROVAL_APPROVED)
            ->get(['code', 'correct_index'])
            ->keyBy('code');

        $serverCorrect = 0;
        $serverTotal = 0;
        foreach ($answers as $row) {
            $q = $questions->get($row['question_code']);
            if ($q === null) {
                continue;
            }
            $serverTotal++;
            if ((int) $row['selected_index'] === (int) $q->correct_index) {
                $serverCorrect++;
            }
        }

        // 全部題目皆在雲端題庫 → 伺服器評分
        if ($serverTotal === count($answers) && $serverTotal > 0) {
            return [$serverCorrect, $serverTotal, 'server'];
        }

        // 純本機課綱或混合題 → 回退客戶端分數（仍要求帶上）
        abort_unless(
            isset($data['correct_count'], $data['question_count']),
            422,
            '部分題目不在雲端題庫，請同時提供 correct_count 與 question_count。',
        );

        return [
            max(0, (int) $data['correct_count']),
            max(0, (int) $data['question_count']),
            $serverTotal === 0 ? 'client_local' : 'client_mixed',
        ];
    }

    protected function requireParent(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();
        abort_unless($user->role === User::ROLE_PARENT, 403, '僅家長可上傳學習紀錄。');

        return $user;
    }

    /**
     * @param  array<string, mixed>  $data
     */
    protected function resolveStudent(User $parent, array $data): Student
    {
        if (! empty($data['student_id'])) {
            $s = Student::query()
                ->where('parent_user_id', $parent->id)
                ->whereKey((int) $data['student_id'])
                ->firstOrFail();

            return $s;
        }

        $localId = $data['device_local_id'];
        $s = Student::query()
            ->where('parent_user_id', $parent->id)
            ->where('device_local_id', $localId)
            ->first();

        abort_if($s === null, 404, '找不到對應的雲端學生，請確認已登入家長帳號並同步孩子資料。');

        return $s;
    }

    /**
     * 僅允許扁平 scalar meta，避免任意巢狀 JSON／過大 PII。
     *
     * @param  mixed  $meta
     * @return array<string, mixed>|null
     */
    protected function sanitizeMeta(mixed $meta): ?array
    {
        if (! is_array($meta) || $meta === []) {
            return null;
        }

        $out = [];
        $i = 0;
        foreach ($meta as $key => $value) {
            if ($i >= 16) {
                break;
            }
            if (! is_string($key) || $key === '' || strlen($key) > 64) {
                continue;
            }
            if (is_string($value)) {
                $out[$key] = mb_substr($value, 0, 255);
            } elseif (is_int($value) || is_float($value) || is_bool($value) || is_null($value)) {
                $out[$key] = $value;
            } else {
                continue;
            }
            $i++;
        }

        return $out === [] ? null : $out;
    }
}
