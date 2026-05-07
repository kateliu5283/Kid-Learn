<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StudentLearningRecord extends Model
{
    public const TYPE_LESSON_QUIZ = 'lesson_quiz';

    public const TYPE_LESSON_REVIEW = 'lesson_review';

    public const TYPE_DAILY_REVIEW = 'daily_review';

    public const TYPE_GAME_MATH_BLITZ = 'game_math_blitz';

    public const TYPE_GAME_MEMORY_MATCH = 'game_memory_match';

    public const TYPE_GAME_WORD_RAIN = 'game_word_rain';

    protected $table = 'student_learning_records';

    protected $fillable = [
        'student_id',
        'activity_type',
        'context_key',
        'title',
        'correct_count',
        'question_count',
        'score_percent',
        'duration_seconds',
        'meta',
        'client_submission_id',
        'recorded_at',
    ];

    protected function casts(): array
    {
        return [
            'correct_count' => 'integer',
            'question_count' => 'integer',
            'score_percent' => 'integer',
            'duration_seconds' => 'integer',
            'meta' => 'array',
            'recorded_at' => 'datetime',
        ];
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'student_id' => $this->student_id,
            'activity_type' => $this->activity_type,
            'context_key' => $this->context_key,
            'title' => $this->title,
            'correct_count' => $this->correct_count,
            'question_count' => $this->question_count,
            'score_percent' => $this->score_percent,
            'duration_seconds' => $this->duration_seconds,
            'meta' => $this->meta,
            'recorded_at' => $this->recorded_at?->toIso8601String(),
        ];
    }
}
