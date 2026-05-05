<?php

namespace App\Http\Controllers\Api\V1\User;

use App\Http\Controllers\Controller;
use App\Models\Student;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

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

            $token = $user->createToken('kid-learn-app')->plainTextToken;
        });

        return $this->authSuccessResponse($user, $token, 201);
    }

    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::query()->where('email', $data['email'])->first();
        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => [__('auth.failed')],
            ]);
        }

        if ($user->role !== User::ROLE_PARENT) {
            return response()->json([
                'message' => '此帳號為教師或管理者，請使用網頁後台登入（/teacher 或 /admin）。',
            ], 403);
        }

        $token = $user->createToken('kid-learn-app')->plainTextToken;

        return $this->authSuccessResponse($user, $token);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()?->currentAccessToken()?->delete();

        return response()->json(['message' => 'ok']);
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

    protected function authSuccessResponse(User $user, string $token, int $status = 200): JsonResponse
    {
        return response()->json([
            'data' => [
                'user' => $this->userPayload($user),
                'token' => $token,
                'students' => $this->studentsPayload($user),
            ],
        ], $status);
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
     * @return array<string, mixed>
     */
    protected function userPayload(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
        ];
    }
}
