<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * 教師 ↔ 學生（家教、小班帶領）。僅 role=teacher 的 User 應出現在 teacher_user_id。
 */
class TeacherStudent extends Model
{
    protected $table = 'teacher_student';

    protected $fillable = [
        'teacher_user_id',
        'student_id',
        'note',
    ];

    public function teacher(): BelongsTo
    {
        return $this->belongsTo(User::class, 'teacher_user_id');
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }
}
