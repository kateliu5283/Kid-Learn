<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\URL;
use Symfony\Component\HttpFoundation\Response;

/**
 * Filament 本機除錯用（掛在 StartSession 之前）：
 *
 * 1) **Session cookie**：若 .env 誤設 `SESSION_SECURE_COOKIE=true`（或 `same_site=none`）卻用 **http** 開站，
 *    瀏覽器會拒收 cookie → 每個請求都是新 session → CSRF／Livewire 失效，**登入欄位無法輸入、按鈕無效**。
 * 2) **APP_URL 埠**：僅在「與請求同一主機、但埠與 APP_URL 不同」時 `URL::forceRootUrl`（不互換 localhost／127.0.0.1）。
 */
class ForceAppUrlFromHttpRequest
{
    public function handle(Request $request, Closure $next): Response
    {
        if (app()->environment('local') && ! $request->secure()) {
            config([
                'session.secure' => false,
                'session.partitioned' => false,
            ]);
            if (config('session.same_site') === 'none') {
                config(['session.same_site' => 'lax']);
            }
        }

        if (! app()->environment('local')) {
            return $next($request);
        }

        $base = rtrim((string) config('app.url'), '/');
        $cfg = parse_url($base) ?: [];
        $cfgHost = $cfg['host'] ?? '';
        if ($cfgHost === '') {
            return $next($request);
        }

        $cfgScheme = strtolower((string) ($cfg['scheme'] ?? 'http'));
        $cfgPort = isset($cfg['port']) ? (int) $cfg['port'] : ($cfgScheme === 'https' ? 443 : 80);

        $reqHost = $request->getHost();
        $reqPort = (int) $request->getPort();

        if (strcasecmp($cfgHost, $reqHost) !== 0) {
            return $next($request);
        }

        if ($cfgPort === $reqPort) {
            return $next($request);
        }

        URL::forceRootUrl(rtrim($request->getSchemeAndHttpHost(), '/'));

        return $next($request);
    }
}
