<?php

namespace App\Listeners;

use App\Models\Student;
use App\Models\User;
use Illuminate\Auth\Events\Login;

/**
 * 訪客先開啟 /join-teaching/{token} 時會寫入 session，教師於 Filament 登入後在此完成 teacher_student 關聯。
 */
class ProcessPendingTeacherInvite
{
    public function handle(Login $event): void
    {
        $user = $event->user;
        if (! $user instanceof User || $user->role !== User::ROLE_TEACHER) {
            return;
        }

        $token = session()->pull('pending_teacher_invite_token');
        if (! is_string($token) || $token === '') {
            return;
        }

        $student = Student::query()->where('teacher_invite_token', $token)->first();
        if ($student === null) {
            return;
        }

        $user->taughtStudents()->syncWithoutDetaching([$student->id]);
    }
}
