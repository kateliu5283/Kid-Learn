<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Question extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
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
    ];

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function lesson(): BelongsTo
    {
        return $this->belongsTo(Lesson::class);
    }
}
