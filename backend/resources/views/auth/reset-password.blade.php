<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>重設密碼 — 小學堂</title>
    <style>
        body { font-family: system-ui, -apple-system, sans-serif; background: #f6f8fb; margin: 0; padding: 40px 16px; color: #1a1a1a; }
        .card { max-width: 420px; margin: 0 auto; background: #fff; border-radius: 16px; padding: 28px; box-shadow: 0 8px 24px rgba(0,0,0,.06); }
        h1 { font-size: 1.35rem; margin: 0 0 8px; }
        p { line-height: 1.6; color: #555; margin: 0 0 16px; }
        label { display: block; font-size: .9rem; font-weight: 650; margin: 12px 0 6px; }
        input { width: 100%; box-sizing: border-box; padding: 12px 14px; border: 1px solid #d0d5dd; border-radius: 10px; font-size: 1rem; }
        button { margin-top: 18px; width: 100%; border: 0; border-radius: 12px; padding: 12px 16px; background: #5b4bdb; color: #fff; font-size: 1rem; font-weight: 700; }
        .error { color: #b42318; font-size: .9rem; margin: 0 0 8px; }
    </style>
</head>
<body>
<div class="card">
    <h1>設定新密碼</h1>
    <p>請為小學堂家長帳號設定一組新密碼。完成後回到 App，用新密碼登入。</p>
    @if ($errors->any())
        @foreach ($errors->all() as $error)
            <p class="error">{{ $error }}</p>
        @endforeach
    @endif
    <form method="POST" action="{{ route('password.update') }}">
        @csrf
        <input type="hidden" name="token" value="{{ $token }}">
        <label for="email">Email</label>
        <input id="email" name="email" type="email" value="{{ old('email', $email) }}" required autocomplete="username">
        <label for="password">新密碼</label>
        <input id="password" name="password" type="password" required minlength="8" autocomplete="new-password">
        <label for="password_confirmation">再輸入一次</label>
        <input id="password_confirmation" name="password_confirmation" type="password" required minlength="8" autocomplete="new-password">
        <button type="submit">更新密碼</button>
    </form>
</div>
</body>
</html>
