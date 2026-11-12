<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>請先驗證 Email — 小學堂</title>
    <style>
        body { font-family: system-ui, -apple-system, sans-serif; background: #f6f8fb; margin: 0; padding: 40px 16px; color: #1a1a1a; }
        .card { max-width: 440px; margin: 0 auto; background: #fff; border-radius: 16px; padding: 28px; box-shadow: 0 8px 24px rgba(0,0,0,.06); }
        h1 { font-size: 1.35rem; margin: 0 0 8px; }
        p { line-height: 1.6; color: #555; margin: 0 0 12px; }
        .ok { color: #1b7a3d; font-weight: 700; }
        button, .link {
            display: inline-block; margin-top: 8px; margin-right: 8px;
            border: 0; border-radius: 10px; padding: 10px 14px; font-size: 0.95rem; cursor: pointer;
        }
        button { background: #0f766e; color: #fff; }
        .link { background: transparent; color: #444; }
    </style>
</head>
<body>
<div class="card">
    <h1>請先驗證 Email</h1>
    <p>帳號 {{ $email }} 尚未完成驗證。驗證前無法使用家長後台、上傳學習紀錄或產生教師邀請。</p>
    @if (session('status') === 'sent')
        <p class="ok">驗證信已寄出，請到信箱點擊連結。</p>
    @endif
    <form method="post" action="{{ route('parent.email.resend') }}">
        @csrf
        <button type="submit">重寄驗證信</button>
    </form>
    <form method="post" action="{{ route('parent.email.logout') }}">
        @csrf
        <button class="link" type="submit">登出</button>
    </form>
</div>
</body>
</html>
