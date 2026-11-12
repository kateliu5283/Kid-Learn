<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\View\View;

/**
 * 家長從重設密碼信開啟的網頁表單。完成後需回到 App 用新密碼登入。
 */
class PasswordResetController extends Controller
{
    public function show(Request $request, string $token): View
    {
        return view('auth.reset-password', [
            'token' => $token,
            'email' => (string) $request->query('email', ''),
        ]);
    }

    public function store(Request $request): View|RedirectResponse
    {
        $data = $request->validate([
            'token' => ['required', 'string'],
            'email' => ['required', 'email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ], [
            'email.required' => '請輸入 Email。',
            'email.email' => 'Email 格式不正確。',
            'password.required' => '請輸入新密碼。',
            'password.min' => '密碼至少 8 個字元。',
            'password.confirmed' => '兩次輸入的密碼不一致。',
        ]);

        $user = User::query()->where('email', $data['email'])->first();
        if (! $user || $user->role !== User::ROLE_PARENT) {
            return back()
                ->withInput($request->only('email'))
                ->withErrors(['email' => '重設連結無效或已過期。']);
        }

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function (User $user, string $password): void {
                $user->forceFill([
                    'password' => $password,
                    'remember_token' => Str::random(60),
                ])->save();

                $user->tokens()->delete();

                event(new PasswordReset($user));
            }
        );

        if ($status !== Password::PASSWORD_RESET) {
            return back()
                ->withInput($request->only('email'))
                ->withErrors(['email' => '重設連結無效或已過期。']);
        }

        return view('auth.password-reset-done', [
            'email' => $user->email,
        ]);
    }
}
