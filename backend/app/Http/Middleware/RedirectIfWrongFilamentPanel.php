<?php

namespace App\Http\Middleware;

use Closure;
use Filament\Facades\Filament;
use Filament\Models\Contracts\FilamentUser;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * 同一瀏覽器使用 web session 時，若已登入其他角色（例如管理者）再開另一個 Filament 面板，
 * 預設會 403。改為登出並導向目前面板的登入頁，方便改以家長／教師帳號登入。
 */
class RedirectIfWrongFilamentPanel
{
    public function handle(Request $request, Closure $next): Response
    {
        try {
            $panel = Filament::getCurrentPanel();
        } catch (\Throwable) {
            return $next($request);
        }

        $guard = Filament::auth();
        if (! $guard->check()) {
            return $next($request);
        }

        $user = $guard->user();
        if (! $user instanceof FilamentUser) {
            return $next($request);
        }

        if ($user->canAccessPanel($panel)) {
            return $next($request);
        }

        $guard->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->guest(Filament::getLoginUrl());
    }
}
