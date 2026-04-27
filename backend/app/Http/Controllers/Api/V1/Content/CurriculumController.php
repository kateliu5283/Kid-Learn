<?php

namespace App\Http\Controllers\Api\V1\Content;

use App\Http\Controllers\Controller;
use App\Models\Lesson;
use App\Models\Question;
use App\Models\Subject;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * 題庫系統（Content）— 課程、單元、題目、快照。
 *
 * 對外路徑：`GET /api/v1/content/*`（見 `routes/api.php`）。
 */
class CurriculumController extends Controller
{
    /**
     * 全部學科列表（Flutter 啟動時預取）
     */
    public function subjects(): JsonResponse
    {
        $subjects = Subject::query()
            ->where('is_active', true)
            ->orderBy('sort')
            ->get(['id', 'code', 'name', 'english_name', 'icon', 'color', 'description']);

        return response()->json([
            'data' => $subjects,
            'meta' => [
                'count' => $subjects->count(),
                'synced_at' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * 課程列表（支援依 subject / grade / semester 過濾）
     */
    public function lessons(Request $request): JsonResponse
    {
        $query = Lesson::query()
            ->with(['subject:id,code,name', 'vocabularyItems:id,lesson_id,term,meaning,example,sort'])
            ->where('is_published', true);

        if ($request->filled('subject')) {
            $subjectCode = $request->string('subject');
            $query->whereHas('subject', fn ($q) => $q->where('code', $subjectCode));
        }
        if ($request->filled('grade')) {
            $query->where('grade', $request->integer('grade'));
        }
        if ($request->filled('semester')) {
            $query->where('semester', $request->string('semester'));
        }

        $lessons = $query
            ->orderBy('subject_id')
            ->orderBy('grade')
            ->orderBy('semester')
            ->orderBy('unit')
            ->orderBy('sort')
            ->get();

        return response()->json([
            'data' => $lessons->map(fn ($l) => $this->transformLesson($l))->values(),
            'meta' => [
                'count' => $lessons->count(),
                'synced_at' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * 單一課程詳情（含題目）
     */
    public function lesson(string $code): JsonResponse
    {
        $lesson = Lesson::with([
            'subject:id,code,name',
            'vocabularyItems',
            'questions' => fn ($q) => $q->where('is_published', true)->orderBy('sort'),
        ])
            ->where('code', $code)
            ->where('is_published', true)
            ->firstOrFail();

        return response()->json([
            'data' => $this->transformLesson($lesson, withQuestions: true),
        ]);
    }

    /**
     * 題目列表（給「複習」「每日複習」使用）
     *
     * 可用參數：subject, grade, lesson, difficulty, include_premium, limit
     */
    public function questions(Request $request): JsonResponse
    {
        $query = Question::query()
            ->with(['subject:id,code,name'])
            ->where('is_published', true);

        if (! $request->boolean('include_premium', false)) {
            $query->where('is_premium', false);
        }

        if ($request->filled('subject')) {
            $query->whereHas('subject', fn ($q) => $q->where('code', $request->string('subject')));
        }
        if ($request->filled('grade')) {
            $query->where('grade', $request->integer('grade'));
        }
        if ($request->filled('difficulty')) {
            $query->where('difficulty', $request->string('difficulty'));
        }
        if ($request->filled('lesson')) {
            $query->whereHas('lesson', fn ($q) => $q->where('code', $request->string('lesson')));
        }
        if ($request->boolean('random', false)) {
            $query->inRandomOrder();
        }

        $limit = min(100, max(1, $request->integer('limit', 50)));
        $questions = $query->limit($limit)->get();

        return response()->json([
            'data' => $questions->map(fn ($q) => $this->transformQuestion($q))->values(),
            'meta' => [
                'count' => $questions->count(),
                'synced_at' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * 整份快取（Flutter 可一次抓下來存 SharedPreferences）
     */
    public function snapshot(Request $request): JsonResponse
    {
        $subjects = Subject::query()->where('is_active', true)->orderBy('sort')->get();
        $lessons = Lesson::with('vocabularyItems')
            ->where('is_published', true)
            ->orderBy('subject_id')
            ->orderBy('grade')
            ->get();
        $questions = Question::where('is_published', true)
            ->where('is_premium', false)
            ->get();

        return response()->json([
            'subjects' => $subjects,
            'lessons' => $lessons->map(fn ($l) => $this->transformLesson($l))->values(),
            'questions' => $questions->map(fn ($q) => $this->transformQuestion($q))->values(),
            'meta' => [
                'synced_at' => now()->toIso8601String(),
                'version' => config('app.curriculum_version', '1.0.0'),
            ],
        ]);
    }

    protected function transformLesson(Lesson $lesson, bool $withQuestions = false): array
    {
        return [
            'id' => $lesson->id,
            'code' => $lesson->code,
            'subject_code' => $lesson->subject?->code,
            'grade' => $lesson->grade,
            'semester' => $lesson->semester,
            'unit' => $lesson->unit,
            'track' => $lesson->track,
            'title' => $lesson->title,
            'summary' => $lesson->summary,
            'content' => $lesson->content,
            'estimated_minutes' => $lesson->estimated_minutes,
            'objectives' => $lesson->objectives ?? [],
            'key_points' => $lesson->key_points ?? [],
            'vocabulary' => $lesson->vocabularyItems->map(fn ($v) => [
                'term' => $v->term,
                'meaning' => $v->meaning,
                'example' => $v->example,
            ])->values(),
            'is_premium' => $lesson->is_premium,
            'questions' => $withQuestions
                ? $lesson->questions->map(fn ($q) => $this->transformQuestion($q))->values()
                : null,
        ];
    }

    protected function transformQuestion(Question $q): array
    {
        return [
            'id' => $q->id,
            'code' => $q->code,
            'subject_code' => $q->subject?->code,
            'grade' => $q->grade,
            'lesson_code' => $q->lesson?->code,
            'type' => $q->type,
            'difficulty' => $q->difficulty,
            'prompt' => $q->prompt,
            'options' => $q->options ?? [],
            'correct_index' => $q->correct_index,
            'explanation' => $q->explanation,
            'image_url' => $q->image_url,
            'tags' => $q->tags ?? [],
            'is_premium' => $q->is_premium,
        ];
    }
}
