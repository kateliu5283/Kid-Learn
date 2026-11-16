<?php

namespace App\Http\Controllers\Api\V1\User;

use App\Http\Controllers\Controller;
use App\Models\Student;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\PersonalAccessToken;

/**
 * App 端「家長」帳號（僅 role=parent）。教師／管理者請使用 Filament 網頁後台。
 */
class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'device_id' => ['nullable', 'string', 'regex:/^[A-Za-z0-9_-]{8,64}$/'],
            'device_label' => ['nullable', 'string', 'max:24'],
            'students' => ['nullable', 'array', 'max:20'],
            'students.*.name' => ['required_with:students', 'string', 'max:120'],
            'students.*.grade' => ['nullable', 'integer', 'min:1', 'max:6'],
            'students.*.avatar' => ['nullable', 'string', 'max:32'],
            'students.*.device_local_id' => ['nullable', 'string', 'max:64'],
        ]);

        $user = null;
        $token = null;

        DB::transaction(function () use (&$user, &$token, $data): void {
            $user = User::query()->create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
                'role' => User::ROLE_PARENT,
            ]);

            $students = $data['students'] ?? [];
            foreach (array_values($students) as $i => $row) {
                $user->students()->create([
                    'name' => $row['name'],
                    'grade' => $row['grade'] ?? 1,
                    'avatar' => $row['avatar'] ?? null,
                    'device_local_id' => $row['device_local_id'] ?? null,
                    'sort' => $i,
                ]);
            }

            $token = $this->issueAppToken($user, $data);
        });

        $user->sendEmailVerificationNotification();

        return $this->authSuccessResponse($user, $token, 201);
    }

    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
            'device_id' => ['nullable', 'string', 'regex:/^[A-Za-z0-9_-]{8,64}$/'],
            'device_label' => ['nullable', 'string', 'max:24'],
        ]);

        $throttleKey = 'parent-login:'.sha1(strtolower($data['email']).'|'.$request->ip());
        if (RateLimiter::tooManyAttempts($throttleKey, 5)) {
            $seconds = RateLimiter::availableIn($throttleKey);
            throw ValidationException::withMessages([
                'email' => ["嘗試次數過多，請 {$seconds} 秒後再試。"],
            ]);
        }

        $user = User::query()->where('email', $data['email'])->first();
        $passwordOk = $user
            ? Hash::check($data['password'], $user->password)
            : Hash::check($data['password'], $this->dummyPasswordHash());

        if (! $user || ! $passwordOk) {
            RateLimiter::hit($throttleKey, 15 * 60);
            throw ValidationException::withMessages([
                'email' => [__('auth.failed')],
            ]);
        }

        RateLimiter::clear($throttleKey);

        if ($user->role !== User::ROLE_PARENT) {
            return response()->json([
                'message' => '此帳號為教師或管理者，請使用網頁後台登入（/teacher 或 /admin）。',
            ], 403);
        }

        $token = $this->issueAppToken($user, $data);

        return $this->authSuccessResponse($user, $token);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()?->currentAccessToken()?->delete();

        return response()->json(['message' => 'ok']);
    }

    /** 這位家長目前的 App 登入（不含網頁後台 session）。 */
    public function sessions(Request $request): JsonResponse
    {
        $user = $this->requireParent($request);
        $currentId = $this->currentTokenId($user);

        $rows = $user->tokens()
            ->orderByDesc('last_used_at')
            ->orderByDesc('id')
            ->get()
            ->map(function ($token) use ($currentId) {
                $label = $this->appTokenLabel($token->name);
                if ($label === null) {
                    return null;
                }

                return [
                    'id' => $token->id,
                    'label' => $label,
                    'current' => $token->id === $currentId,
                    'last_used_at' => $token->last_used_at?->toIso8601String(),
                    'created_at' => $token->created_at?->toIso8601String(),
                ];
            })
            ->filter()
            ->values();

        return response()->json(['data' => $rows])->header('Cache-Control', 'no-store');
    }

    /** 撤銷其他 App 登入，這台裝置的 token 保留。 */
    public function logoutOtherDevices(Request $request): JsonResponse
    {
        $user = $this->requireParent($request);
        $currentId = $this->currentTokenId($user);

        $ids = $user->tokens()
            ->get(['id', 'name'])
            ->filter(fn ($token) => $this->isAppToken($token->name) && $token->id !== $currentId)
            ->pluck('id');

        if ($ids->isNotEmpty()) {
            $user->tokens()->whereIn('id', $ids)->delete();
        }

        return response()->json([
            'message' => '已登出其他裝置。',
            'revoked' => $ids->count(),
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        return response()->json([
            'data' => [
                'user' => $this->userPayload($user),
                'students' => $this->studentsPayload($user),
            ],
        ]);
    }

    /** 重寄驗證信（已驗證則回 200）。 */
    public function resendVerification(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        abort_unless($user->role === User::ROLE_PARENT, 403);

        if ($user->hasVerifiedEmail()) {
            return response()->json(['message' => 'already_verified']);
        }

        $user->sendEmailVerificationNotification();

        return response()->json(['message' => 'sent']);
    }

    protected function authSuccessResponse(User $user, string $token, int $status = 200): JsonResponse
    {
        return response()->json([
            'data' => [
                'user' => $this->userPayload($user),
                'token' => $token,
                'students' => $this->studentsPayload($user),
            ],
        ], $status)->header('Cache-Control', 'no-store');
    }

    /** 帳號不存在時仍做一次 bcrypt，避免以回應時間判斷 email 是否註冊。 */
    protected function dummyPasswordHash(): string
    {
        static $hash = null;

        return $hash ??= Hash::make('timing-dummy-not-a-user-password');
    }

    /**
     * @return list<array<string, mixed>>
     */
    protected function studentsPayload(User $user): array
    {
        if ($user->role !== User::ROLE_PARENT) {
            return [];
        }

        return $user->students()
            ->orderBy('sort')
            ->get()
            ->map(fn (Student $s) => $s->toApiArray())
            ->values()
            ->all();
    }

    /**
     * 不透露 Email 是否已註冊。只有家長帳號會收到重設信。
     */
    public function forgotPassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
        ], [
            'email.required' => '請輸入 Email。',
            'email.email' => 'Email 格式不正確。',
        ]);

        $message = '若此 Email 已註冊家長帳號，我們已寄出重設密碼信件。請至信箱開啟連結設定新密碼。';

        $user = User::query()->where('email', $data['email'])->first();
        if ($user && $user->role === User::ROLE_PARENT) {
            Password::sendResetLink(['email' => $user->email]);
        }

        return response()->json(['message' => $message]);
    }

    /**
     * 匯出這位家長名下的孩子與學習紀錄（不含密碼與邀請 token）。
     */
    public function exportData(Request $request): JsonResponse
    {
        $user = $this->requireParent($request);

        $students = $user->students()
            ->with(['learningRecords' => fn ($q) => $q->orderBy('recorded_at')->orderBy('id')])
            ->orderBy('sort')
            ->orderBy('id')
            ->get();

        return response()->json([
            'exported_at' => now()->toIso8601String(),
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'email_verified_at' => $user->email_verified_at?->toIso8601String(),
                'created_at' => $user->created_at?->toIso8601String(),
            ],
            'students' => $students->map(fn (Student $student) => [
                'id' => $student->id,
                'name' => $student->name,
                'grade' => $student->grade,
                'avatar' => $student->avatar,
                'device_local_id' => $student->device_local_id,
                'created_at' => $student->created_at?->toIso8601String(),
                'learning_records' => $student->learningRecords
                    ->map(fn ($record) => $record->toApiArray())
                    ->values()
                    ->all(),
            ])->values()->all(),
        ])->header('Cache-Control', 'no-store');
    }

    /**
     * 刪除家長帳號。孩子、學習紀錄與登入 token 一併移除。
     */
    public function destroyAccount(Request $request): JsonResponse
    {
        $user = $this->requireParent($request);

        $data = $request->validate([
            'password' => ['required', 'string'],
        ], [
            'password.required' => '請輸入目前的密碼。',
        ]);

        $throttleKey = 'parent-delete:'.$user->id;
        if (RateLimiter::tooManyAttempts($throttleKey, 5)) {
            $seconds = RateLimiter::availableIn($throttleKey);

            return response()->json([
                'message' => "嘗試次數過多，請 {$seconds} 秒後再試。",
            ], 429);
        }

        if (! Hash::check($data['password'], $user->password)) {
            RateLimiter::hit($throttleKey, 15 * 60);
            throw ValidationException::withMessages([
                'password' => ['密碼不正確。'],
            ]);
        }

        RateLimiter::clear($throttleKey);

        DB::transaction(function () use ($user): void {
            $email = $user->email;
            $user->tokens()->delete();
            DB::table('sessions')->where('user_id', $user->id)->delete();
            DB::table('password_reset_tokens')->where('email', $email)->delete();
            $user->delete();
        });

        return response()->json(['message' => '帳號已刪除。']);
    }

    /**
     * 同一裝置重登只換掉該裝置的 token，其他裝置保持登入。最多保留 8 個 App token。
     *
     * @param  array<string, mixed>  $data
     */
    protected function issueAppToken(User $user, array $data): string
    {
        $deviceId = is_string($data['device_id'] ?? null) && $data['device_id'] !== ''
            ? $data['device_id']
            : 'anon-'.Str::lower(Str::random(16));
        $label = $this->cleanDeviceLabel($data['device_label'] ?? null);
        $name = 'kid-learn:'.$deviceId.($label !== '' ? '|'.$label : '');

        $user->tokens()->get(['id', 'name'])->each(function ($token) use ($deviceId): void {
            $tokenName = (string) $token->name;
            if ($tokenName === 'kid-learn:'.$deviceId || str_starts_with($tokenName, 'kid-learn:'.$deviceId.'|')) {
                $token->delete();
            }
        });

        $plain = $user->createToken($name)->plainTextToken;
        $this->trimAppTokens($user, 8);

        return $plain;
    }

    protected function trimAppTokens(User $user, int $max): void
    {
        $appTokens = $user->tokens()
            ->orderBy('created_at')
            ->orderBy('id')
            ->get()
            ->filter(fn ($token) => $this->isAppToken((string) $token->name))
            ->values();

        $extra = $appTokens->count() - $max;
        if ($extra <= 0) {
            return;
        }

        $appTokens->take($extra)->each->delete();
    }

    protected function isAppToken(string $name): bool
    {
        return $name === 'kid-learn-app' || str_starts_with($name, 'kid-learn:');
    }

    protected function appTokenLabel(string $name): ?string
    {
        if ($name === 'kid-learn-app') {
            return '舊版 App';
        }
        if (! str_starts_with($name, 'kid-learn:')) {
            return null;
        }

        $rest = substr($name, strlen('kid-learn:'));
        $label = explode('|', $rest, 2)[1] ?? '';

        return $label !== '' ? $label : 'App 裝置';
    }

    protected function cleanDeviceLabel(mixed $label): string
    {
        if (! is_string($label)) {
            return '';
        }

        $label = trim(preg_replace('/\s+/u', ' ', str_replace('|', ' ', $label)) ?? '');

        return mb_substr($label, 0, 24);
    }

    protected function currentTokenId(User $user): ?int
    {
        $token = $user->currentAccessToken();

        return $token instanceof PersonalAccessToken ? $token->id : null;
    }

    protected function requireParent(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();
        abort_unless($user->role === User::ROLE_PARENT, 403, '僅家長可操作此功能。');

        return $user;
    }

    /**
     * @return array<string, mixed>
     */
    protected function userPayload(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'email_verified' => $user->hasVerifiedEmail(),
            'email_verified_at' => $user->email_verified_at?->toIso8601String(),
        ];
    }
}
