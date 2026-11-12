<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Email 已驗證 — 小學堂</title>
    <style>
        body { font-family: system-ui, -apple-system, sans-serif; background: #f6f8fb; margin: 0; padding: 40px 16px; color: #1a1a1a; }
        .card { max-width: 420px; margin: 0 auto; background: #fff; border-radius: 16px; padding: 28px; box-shadow: 0 8px 24px rgba(0,0,0,.06); }
        h1 { font-size: 1.35rem; margin: 0 0 8px; }
        p { line-height: 1.6; color: #555; margin: 0 0 12px; }
        .ok { color: #1b7a3d; font-weight: 700; }
    </style>
</head>
<body>
<div class="card">
    <p class="ok">驗證成功</p>
    <h1>嗨，{{ $name }}</h1>
    <p>您的 Email（{{ $email }}）已完成驗證。請回到 App 重新整理家長帳號，即可上傳學習紀錄與產生教師邀請。</p>
</div>
</body>
</html>
