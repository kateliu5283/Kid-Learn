<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Auth\Events\Verified;
use Illuminate\Http\Request;

/**
 * 家長點擊驗證信內的簽名連結後，標記 email 已驗證並顯示成功頁。
 */
class EmailVerificationController extends Controller
{
    public function __invoke(Request $request, string $id, string $hash)
    {
        $user = User::query()->findOrFail($id);

        if (! hash_equals(sha1($user->getEmailForVerification()), (string) $hash)) {
            abort(403, '驗證連結無效。');
        }

        if (! $user->hasVerifiedEmail()) {
            $user->markEmailAsVerified();
            event(new Verified($user));
        }

        return response()->view('auth.email-verified', [
            'name' => $user->name,
            'email' => $user->email,
        ]);
    }
}
