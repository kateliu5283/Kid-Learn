<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

/**
 * 未驗證家長登入網頁後台時的說明頁，並可重寄驗證信。
 */
class ParentEmailNoticeController extends Controller
{
    public function show(Request $request): View|RedirectResponse
    {
        $user = $this->parentOrAbort($request);
        if ($user->hasVerifiedEmail()) {
            return redirect('/parent');
        }

        return view('auth.email-unverified', [
            'email' => $user->email,
        ]);
    }

    public function resend(Request $request): RedirectResponse
    {
        $user = $this->parentOrAbort($request);
        if (! $user->hasVerifiedEmail()) {
            $user->sendEmailVerificationNotification();
        }

        return redirect()
            ->route('parent.email.notice')
            ->with('status', 'sent');
    }

    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect('/parent/login');
    }

    protected function parentOrAbort(Request $request): User
    {
        $user = $request->user();
        abort_unless($user instanceof User && $user->role === User::ROLE_PARENT, 403);

        return $user;
    }
}
