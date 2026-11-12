<?php

namespace Tests\Feature;

use App\Models\StudentLearningRecord;
use App\Models\User;
use App\Notifications\ResetParentPassword;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\Password;
use Tests\TestCase;

class ParentAccountTest extends TestCase
{
    use RefreshDatabase;

    public function test_forgot_password_sends_mail_only_for_parents_and_hides_existence(): void
    {
        Notification::fake();

        $parent = User::factory()->create([
            'role' => User::ROLE_PARENT,
            'email' => 'parent@example.com',
        ]);
        $teacher = User::factory()->create([
            'role' => User::ROLE_TEACHER,
            'email' => 'teacher@example.com',
        ]);

        $parentRes = $this->postJson('/api/v1/user/forgot-password', [
            'email' => $parent->email,
        ]);
        $teacherRes = $this->postJson('/api/v1/user/forgot-password', [
            'email' => $teacher->email,
        ]);
        $missingRes = $this->postJson('/api/v1/user/forgot-password', [
            'email' => 'nobody@example.com',
        ]);

        $parentRes->assertOk();
        $this->assertSame($parentRes->json('message'), $teacherRes->json('message'));
        $this->assertSame($parentRes->json('message'), $missingRes->json('message'));

        Notification::assertSentTo(
            $parent,
            ResetParentPassword::class,
            function (ResetParentPassword $notification) use ($parent) {
                $mail = $notification->toMail($parent);

                return str_contains((string) $mail->actionUrl, '/password/reset/');
            },
        );
        Notification::assertNotSentTo($teacher, ResetParentPassword::class);
        Notification::assertCount(1);
    }

    public function test_parent_can_reset_password_from_email_link_and_old_token_stops_working(): void
    {
        $parent = User::factory()->create([
            'role' => User::ROLE_PARENT,
            'email' => 'parent@example.com',
        ]);
        $oldToken = $parent->createToken('kid-learn-app')->plainTextToken;
        $resetToken = Password::broker()->createToken($parent);

        $this->get('/password/reset/'.$resetToken.'?email='.urlencode($parent->email))
            ->assertOk()
            ->assertSee('設定新密碼');

        $this->post('/password/reset', [
            'token' => $resetToken,
            'email' => $parent->email,
            'password' => 'new-password-1',
            'password_confirmation' => 'new-password-1',
        ])->assertOk()->assertSee('密碼已更新');

        $this->assertTrue(Hash::check('new-password-1', $parent->fresh()->password));

        $this->getJson('/api/v1/user/me', [
            'Authorization' => 'Bearer '.$oldToken,
        ])->assertUnauthorized();

        $this->postJson('/api/v1/user/login', [
            'email' => 'parent@example.com',
            'password' => 'new-password-1',
        ])->assertOk();
    }

    public function test_teacher_cannot_reset_password_on_parent_form(): void
    {
        $teacher = User::factory()->create([
            'role' => User::ROLE_TEACHER,
            'email' => 'teacher@example.com',
        ]);
        $token = Password::broker()->createToken($teacher);

        $this->post('/password/reset', [
            'token' => $token,
            'email' => $teacher->email,
            'password' => 'new-password-1',
            'password_confirmation' => 'new-password-1',
        ])->assertSessionHasErrors('email');

        $this->assertTrue(Hash::check('password', $teacher->fresh()->password));
    }

    public function test_parent_can_export_own_students_and_records_only(): void
    {
        $parent = User::factory()->create(['role' => User::ROLE_PARENT, 'name' => '家長甲']);
        $student = $parent->students()->create([
            'name' => '小華',
            'grade' => 2,
            'device_local_id' => 'p-local',
            'sort' => 0,
        ]);
        StudentLearningRecord::query()->create([
            'student_id' => $student->id,
            'activity_type' => 'lesson_quiz',
            'context_key' => 'math_g1_u1',
            'correct_count' => 8,
            'question_count' => 10,
            'recorded_at' => now(),
        ]);

        $other = User::factory()->create(['role' => User::ROLE_PARENT]);
        $other->students()->create([
            'name' => '不該出現',
            'grade' => 1,
            'sort' => 0,
        ]);

        $token = $parent->createToken('kid-learn-app')->plainTextToken;

        $res = $this->getJson('/api/v1/user/export', [
            'Authorization' => 'Bearer '.$token,
        ]);

        $res->assertOk()
            ->assertJsonPath('user.email', $parent->email)
            ->assertJsonPath('students.0.name', '小華')
            ->assertJsonPath('students.0.learning_records.0.context_key', 'math_g1_u1')
            ->assertJsonMissing(['name' => '不該出現']);

        $this->assertArrayNotHasKey('password', $res->json('user'));
        $encoded = json_encode($res->json());
        $this->assertIsString($encoded);
        $this->assertStringNotContainsString('teacher_invite', $encoded);
    }

    public function test_parent_can_delete_account_with_password_and_records_go_with_it(): void
    {
        $parent = User::factory()->create(['role' => User::ROLE_PARENT]);
        $student = $parent->students()->create([
            'name' => '小華',
            'grade' => 1,
            'sort' => 0,
        ]);
        $record = StudentLearningRecord::query()->create([
            'student_id' => $student->id,
            'activity_type' => 'lesson_quiz',
            'context_key' => 'math_g1_u1',
            'correct_count' => 1,
            'question_count' => 1,
            'recorded_at' => now(),
        ]);
        $token = $parent->createToken('kid-learn-app')->plainTextToken;

        $this->deleteJson('/api/v1/user/account', [
            'password' => 'wrong-password',
        ], [
            'Authorization' => 'Bearer '.$token,
        ])->assertStatus(422);

        $this->deleteJson('/api/v1/user/account', [
            'password' => 'password',
        ], [
            'Authorization' => 'Bearer '.$token,
        ])->assertOk()->assertJsonPath('message', '帳號已刪除。');

        $this->assertDatabaseMissing('users', ['id' => $parent->id]);
        $this->assertDatabaseMissing('students', ['id' => $student->id]);
        $this->assertDatabaseMissing('student_learning_records', ['id' => $record->id]);
        $this->assertDatabaseMissing('personal_access_tokens', [
            'tokenable_id' => $parent->id,
        ]);

        // 同一個測試行程會留下已解析的 guard，清掉才看得到 token 已失效。
        $this->app['auth']->forgetGuards();

        $this->getJson('/api/v1/user/me', [
            'Authorization' => 'Bearer '.$token,
        ])->assertUnauthorized();
    }
}
