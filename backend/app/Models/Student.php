<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Student extends Model
{
    protected $fillable = [
        'parent_user_id',
        'name',
        'grade',
        'avatar',
        'device_local_id',
        'sort',
    ];

    protected function casts(): array
    {
        return [
            'grade' => 'integer',
            'sort' => 'integer',
        ];
    }

    public function parent(): BelongsTo
    {
        return $this->belongsTo(User::class, 'parent_user_id');
    }

    /**
     * 家教／小班：教師與學生多對多（透過 teacher_student）。
     *
     * @return BelongsToMany<User, $this>
     */
    public function teachers(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'teacher_student', 'student_id', 'teacher_user_id')
            ->withPivot('note')
            ->withTimestamps();
    }

    /** @return HasMany<StudentLearningRecord, $this> */
    public function learningRecords(): HasMany
    {
        return $this->hasMany(StudentLearningRecord::class)->orderByDesc('recorded_at');
    }

    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'grade' => $this->grade,
            'avatar' => $this->avatar,
            'device_local_id' => $this->device_local_id,
        ];
    }
}
