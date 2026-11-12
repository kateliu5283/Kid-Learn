<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * 基本瀏覽器安全標頭。邀請連結另加 no-referrer，避免 token 經 Referer 外洩。
 */
class SecurityHeaders
{
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        $response->headers->set('X-Content-Type-Options', 'nosniff');
        $response->headers->set('X-Frame-Options', 'SAMEORIGIN');
        $response->headers->set('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
        $response->headers->set('X-Permitted-Cross-Domain-Policies', 'none');

        $sensitive = $request->is('join-teaching', 'join-teaching/*', 'email/unverified', 'email/unverified/*', 'email/verify/*');
        $response->headers->set(
            'Referrer-Policy',
            $sensitive ? 'no-referrer' : 'strict-origin-when-cross-origin',
        );

        if ($sensitive) {
            $response->headers->set('Cache-Control', 'no-store');
        }

        return $response;
    }
}
