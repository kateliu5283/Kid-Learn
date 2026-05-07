<?php

namespace App\Http\Controllers\Api\V1\User;

use App\Http\Controllers\Controller;
use App\Models\Student;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/**
 * 家長名下學生（雲端實體）。教師可經邀請連結加入，或由後台 Filament 指派 teacher_student。
 */
class StudentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $this->requireParent($request);

        $list = $user->students()->orderBy('sort')->get()->map(fn (Student $s) => $s->toApiArray())->values();

        return response()->json(['data' => $list]);
    }

    public function store(Request $request): JsonResponse
    {
        $user = $this->requireParent($request);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'grade' => ['nullable', 'integer', 'min:1', 'max:6'],
            'avatar' => ['nullable', 'string', 'max:32'],
            'device_local_id' => [
                'nullable',
                'string',
                'max:64',
                Rule::unique('students', 'device_local_id')->where(
                    fn ($q) => $q->where('parent_user_id', $user->id),
                ),
            ],
            'sort' => ['nullable', 'integer', 'min:0', 'max:65535'],
        ]);

        $maxSort = (int) $user->students()->max('sort');

        $student = $user->students()->create([
            'name' => $data['name'],
            'grade' => $data['grade'] ?? 1,
            'avatar' => $data['avatar'] ?? null,
            'device_local_id' => $data['device_local_id'] ?? null,
            'sort' => $data['sort'] ?? ($maxSort + 1),
        ]);

        return response()->json(['data' => $student->toApiArray()], 201);
    }

    public function update(Request $request, Student $student): JsonResponse
    {
        $user = $this->requireParent($request);
        $this->authorizeParentStudent($user, $student);

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:120'],
            'grade' => ['sometimes', 'integer', 'min:1', 'max:6'],
            'avatar' => ['nullable', 'string', 'max:32'],
            'device_local_id' => [
                'nullable',
                'string',
                'max:64',
                Rule::unique('students', 'device_local_id')
                    ->where(fn ($q) => $q->where('parent_user_id', $user->id))
                    ->ignore($student->id),
            ],
            'sort' => ['sometimes', 'integer', 'min:0', 'max:65535'],
        ]);

        $student->fill($data);
        $student->save();

        return response()->json(['data' => $student->fresh()->toApiArray()]);
    }

    public function destroy(Request $request, Student $student): JsonResponse
    {
        $user = $this->requireParent($request);
        $this->authorizeParentStudent($user, $student);
        $student->delete();

        return response()->json(['message' => 'ok']);
    }

    /**
     * 取得（或重新產生）讓教師掃描加入的邀請連結。QR 內容應為回傳的 join_url。
     */
    public function teacherInvite(Request $request, Student $student): JsonResponse
    {
        $user = $this->requireParent($request);
        $this->authorizeParentStudent($user, $student);

        $data = $request->validate([
            'regenerate' => ['sometimes', 'boolean'],
        ]);

        $regenerate = (bool) ($data['regenerate'] ?? false);
        $student->ensureTeacherInviteToken($regenerate);
        $student->refresh();

        return response()->json([
            'data' => [
                'join_url' => $student->joinTeachingUrl(),
            ],
        ]);
    }

    protected function requireParent(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();
        abort_unless($user->role === User::ROLE_PARENT, 403, '僅家長可操作學生資料。');

        return $user;
    }

    protected function authorizeParentStudent(User $user, Student $student): void
    {
        abort_unless($student->parent_user_id === $user->id, 404);
    }
}
