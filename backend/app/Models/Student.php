<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class Student extends Model
{
    protected $fillable = [
        'parent_user_id',
        'name',
        'grade',
        'avatar',
        'device_local_id',
        'sort',
    ];

    protected $hidden = [
        'teacher_invite_token',
    ];

    protected function casts(): array
    {
        return [
            'grade' => 'integer',
            'sort' => 'integer',
            'teacher_invite_expires_at' => 'datetime',
        ];
    }

    public function parent(): BelongsTo
    {
        return $this->belongsTo(User::class, 'parent_user_id');
    }

    /**
     * 家教／小班：教師與學生多對多（透過 teacher_student）。
     *
     * @return BelongsToMany<User, $this>
     */
    public function teachers(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'teacher_student', 'student_id', 'teacher_user_id')
            ->withPivot('note')
            ->withTimestamps();
    }

    /** @return HasMany<StudentLearningRecord, $this> */
    public function learningRecords(): HasMany
    {
        return $this->hasMany(StudentLearningRecord::class)->orderByDesc('recorded_at');
    }

    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'grade' => $this->grade,
            'avatar' => $this->avatar,
            'device_local_id' => $this->device_local_id,
        ];
    }

    /**
     * 產生或沿用邀請 token（24 小時有效）。
     * 沿用未過期 token 時不延長期限，避免外洩的 QR 被無限續期。
     */
    public function ensureTeacherInviteToken(bool $regenerate = false): void
    {
        $expired = $this->teacher_invite_expires_at === null
            || $this->teacher_invite_expires_at->isPast();

        if (! $regenerate && filled($this->teacher_invite_token) && ! $expired) {
            return;
        }

        $this->teacher_invite_token = Str::random(48);
        $this->teacher_invite_expires_at = now()->addDay();
        $this->save();
    }

    public function isTeacherInviteValid(): bool
    {
        return filled($this->teacher_invite_token)
            && $this->teacher_invite_expires_at !== null
            && $this->teacher_invite_expires_at->isFuture();
    }

    /**
     * 以資料列鎖綁定教師並作廢邀請。同時兩個請求只有一個會成功。
     */
    public static function claimTeacherInvite(User $teacher, string $token): bool
    {
        if ($teacher->role !== User::ROLE_TEACHER || $token === '') {
            return false;
        }

        return DB::transaction(function () use ($teacher, $token): bool {
            $student = static::query()
                ->where('teacher_invite_token', $token)
                ->lockForUpdate()
                ->first();

            if ($student === null || ! $student->isTeacherInviteValid()) {
                return false;
            }

            $teacher->taughtStudents()->syncWithoutDetaching([$student->id]);
            $student->teacher_invite_token = null;
            $student->teacher_invite_expires_at = null;
            $student->save();

            return true;
        });
    }

    public static function findByValidTeacherInviteToken(string $token): ?self
    {
        $student = static::query()->where('teacher_invite_token', $token)->first();
        if ($student === null || ! $student->isTeacherInviteValid()) {
            return null;
        }

        return $student;
    }

    public function joinTeachingUrl(): string
    {
        return rtrim(config('app.url'), '/').'/join-teaching/'.$this->teacher_invite_token;
    }
}
