<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Question extends Model
{
    use HasFactory;

    public const SOURCE_MANUAL = 'manual';

    public const SOURCE_AI = 'ai';

    public const APPROVAL_PENDING = 'pending';

    public const APPROVAL_APPROVED = 'approved';

    public const APPROVAL_REJECTED = 'rejected';

    protected $fillable = [
        'code',
        'source',
        'approval_status',
        'reviewed_at',
        'reviewed_by',
        'ai_model',
        'subject_id',
        'lesson_id',
        'grade',
        'type',
        'difficulty',
        'prompt',
        'options',
        'correct_index',
        'explanation',
        'image_url',
        'tags',
        'is_published',
        'is_premium',
        'sort',
    ];

    protected $casts = [
        'grade' => 'integer',
        'correct_index' => 'integer',
        'options' => 'array',
        'tags' => 'array',
        'is_published' => 'boolean',
        'is_premium' => 'boolean',
        'sort' => 'integer',
        'reviewed_at' => 'datetime',
    ];

    protected static function booted(): void
    {
        static::saving(function (Question $question): void {
            if ($question->approval_status !== self::APPROVAL_APPROVED) {
                $question->is_published = false;
            }
        });
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function lesson(): BelongsTo
    {
        return $this->belongsTo(Lesson::class);
    }

    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }
}
