<?php

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * 家長 App 敏感寫入需先完成 Email 驗證（教師／管理者不受影響）。
 */
class EnsureParentEmailIsVerified
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        if ($user instanceof User
            && $user->role === User::ROLE_PARENT
            && ! $user->hasVerifiedEmail()) {
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'message' => '請先完成 Email 驗證後再使用此功能。',
                    'code' => 'email_unverified',
                ], 403);
            }

            return redirect()->route('parent.email.notice');
        }

        return $next($request);
    }
}
