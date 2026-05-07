<?php

namespace App\Http\Controllers\Api\V1\Learning;

use App\Http\Controllers\Controller;
use App\Models\Student;
use App\Models\StudentLearningRecord;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/**
 * App 上傳答題／遊戲成績（家長 Sanctum）。家長／教師於 Filament 檢視。
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
            'activity_type' => ['required', 'string', 'max:64'],
            'context_key' => ['nullable', 'string', 'max:120'],
            'title' => ['nullable', 'string', 'max:255'],
            'correct_count' => ['required', 'integer', 'min:0', 'max:100000'],
            'question_count' => ['required', 'integer', 'min:0', 'max:100000'],
            'score_percent' => ['nullable', 'integer', 'min:0', 'max:100'],
            'duration_seconds' => ['nullable', 'integer', 'min:0', 'max:86400'],
            'meta' => ['nullable', 'array'],
            'client_submission_id' => ['nullable', 'string', 'max:64'],
            'recorded_at' => ['nullable', 'date'],
        ]);

        abort_unless(
            ! empty($data['student_id']) || ! empty($data['device_local_id']),
            422,
            '請提供 student_id 或 device_local_id。',
        );

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

        $q = max(0, (int) $data['question_count']);
        $c = max(0, (int) $data['correct_count']);
        if ($q > 0 && $c > $q) {
            abort(422, 'correct_count 不可大於 question_count。');
        }

        $pct = $data['score_percent'] ?? null;
        if ($pct === null && $q > 0) {
            $pct = (int) round(($c / $q) * 100);
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
            'meta' => $data['meta'] ?? null,
            'client_submission_id' => $data['client_submission_id'] ?? null,
            'recorded_at' => isset($data['recorded_at'])
                ? \Carbon\Carbon::parse($data['recorded_at'])
                : now(),
        ]);

        return response()->json(['data' => $record->toApiArray()], 201);
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
}
