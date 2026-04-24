<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Lesson extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'subject_id',
        'grade',
        'semester',
        'unit',
        'track',
        'title',
        'summary',
        'content',
        'estimated_minutes',
        'objectives',
        'key_points',
        'is_published',
        'is_premium',
        'sort',
    ];

    protected $casts = [
        'grade' => 'integer',
        'unit' => 'integer',
        'estimated_minutes' => 'integer',
        'objectives' => 'array',
        'key_points' => 'array',
        'is_published' => 'boolean',
        'is_premium' => 'boolean',
        'sort' => 'integer',
    ];

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function questions(): HasMany
    {
        return $this->hasMany(Question::class);
    }

    public function vocabularyItems(): HasMany
    {
        return $this->hasMany(VocabularyItem::class)->orderBy('sort');
    }
}
