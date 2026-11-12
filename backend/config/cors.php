<?php

$origins = env('CORS_ALLOWED_ORIGINS', 'http://127.0.0.1:8000,http://localhost:8000,http://127.0.0.1:*,http://localhost:*');

$allowedOrigins = array_values(array_filter(array_map(
    static fn (string $origin): string => trim($origin),
    explode(',', (string) $origins),
)));

// 正式環境拒絕 * 與任意 localhost，避免把開發用白名單帶上線。
if (env('APP_ENV') === 'production') {
    $allowedOrigins = array_values(array_filter(
        $allowedOrigins,
        static fn (string $origin): bool => $origin !== '*' && ! str_contains($origin, '*'),
    ));
}

// 生產環境請在 .env 設定明確網域，例如：
// CORS_ALLOWED_ORIGINS=https://app.example.com,https://www.example.com
// 切勿在正式環境使用 *。

return [

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],

    'allowed_origins' => in_array('*', $allowedOrigins, true)
        ? ['*']
        : array_values(array_filter(
            $allowedOrigins,
            static fn (string $o): bool => ! str_contains($o, '*'),
        )),

    'allowed_origins_patterns' => in_array('*', $allowedOrigins, true)
        ? []
        : array_values(array_filter(array_map(
            static function (string $origin): ?string {
                // 只允許「協定+主機:*」這種埠號萬用，例如 http://127.0.0.1:*
                if (! str_ends_with($origin, ':*')) {
                    return null;
                }

                $host = substr($origin, 0, -2);
                if ($host === '' || str_contains($host, '*')) {
                    return null;
                }

                return '/^'.preg_quote($host, '/').'(:\d+)?$/';
            },
            $allowedOrigins,
        ))),

    'allowed_headers' => ['Content-Type', 'Authorization', 'Accept', 'X-Requested-With'],

    'exposed_headers' => [],

    'max_age' => 600,

    'supports_credentials' => false,

];
