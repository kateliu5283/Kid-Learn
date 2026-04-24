<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class VocabularyItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'lesson_id',
        'term',
        'meaning',
        'example',
        'sort',
    ];

    protected $casts = [
        'sort' => 'integer',
    ];

    public function lesson(): BelongsTo
    {
        return $this->belongsTo(Lesson::class);
    }
}
