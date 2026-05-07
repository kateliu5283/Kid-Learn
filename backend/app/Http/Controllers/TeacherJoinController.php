<?php

namespace App\Http\Controllers;

use App\Models\Student;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TeacherJoinController extends Controller
{
    /**
     * 老師用手機掃描家長提供的 QR（內容為本站 join URL）後，登入教師後台即與該雲端學生建立關聯。
     */
    public function __invoke(Request $request, string $token)
    {
        $student = Student::query()->where('teacher_invite_token', $token)->first();
        if ($student === null) {
            abort(404, '邀請連結無效或已失效，請向家長索取新的 QR。');
        }

        $user = Auth::user();
        if ($user instanceof User) {
            if ($user->role !== User::ROLE_TEACHER) {
                return response()
                    ->view('join-teaching-wrong-role', ['studentName' => $student->name], 403);
            }

            $user->taughtStudents()->syncWithoutDetaching([$student->id]);

            return redirect('/teacher');
        }

        $request->session()->put('pending_teacher_invite_token', $token);

        return redirect()->guest(url('/teacher/login'));
    }
}
