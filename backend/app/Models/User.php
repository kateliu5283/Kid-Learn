<?php

namespace App\Models;

use App\Notifications\ResetParentPassword;
use App\Notifications\VerifyParentEmail;
use Database\Factories\UserFactory;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Auth\MustVerifyEmail as MustVerifyEmailTrait;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable implements FilamentUser, MustVerifyEmail
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, MustVerifyEmailTrait, Notifiable;

    public const ROLE_ADMIN = 'admin';

    public const ROLE_TEACHER = 'teacher';

    public const ROLE_PARENT = 'parent';

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, mixed>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * 僅家長 App 帳號強制 Email 驗證；教師／管理者走 Filament，視為已驗證。
     */
    public function hasVerifiedEmail(): bool
    {
        if ($this->role !== self::ROLE_PARENT) {
            return true;
        }

        return $this->email_verified_at !== null;
    }

    public function sendEmailVerificationNotification(): void
    {
        $this->notify(new VerifyParentEmail);
    }

    /**
     * 家長信裡的連結導向 App 用的重設頁。其他角色維持 Laravel 預設通知。
     */
    public function sendPasswordResetNotification(#[\SensitiveParameter] $token): void
    {
        if ($this->role === self::ROLE_PARENT) {
            $this->notify(new ResetParentPassword($token));

            return;
        }

        parent::sendPasswordResetNotification($token);
    }

    public function canAccessPanel(Panel $panel): bool
    {
        return match ($panel->getId()) {
            'admin' => $this->role === self::ROLE_ADMIN,
            'teacher' => $this->role === self::ROLE_TEACHER,
            'parent' => $this->role === self::ROLE_PARENT,
            default => false,
        };
    }

    /** @return HasMany<Student, $this> */
    public function students(): HasMany
    {
        return $this->hasMany(Student::class, 'parent_user_id')->orderBy('sort');
    }

    /**
     * 家教／小班：此教師帶領的學生。
     *
     * @return BelongsToMany<Student, $this>
     */
    public function taughtStudents(): BelongsToMany
    {
        return $this->belongsToMany(Student::class, 'teacher_student', 'teacher_user_id', 'student_id')
            ->withPivot('note')
            ->withTimestamps();
    }
}
