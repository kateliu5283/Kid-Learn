<?php

namespace Tests\Feature;

use App\Models\User;
use App\Notifications\VerifyParentEmail;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\URL;
use Tests\TestCase;

class EmailVerificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_sends_verification_email_and_marks_unverified(): void
    {
        Notification::fake();

        $res = $this->postJson('/api/v1/user/register', [
            'name' => '家長',
            'email' => 'parent@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $res->assertCreated()
            ->assertJsonPath('data.user.email_verified', false);

        $user = User::query()->where('email', 'parent@example.com')->firstOrFail();
        $this->assertNull($user->email_verified_at);
        Notification::assertSentTo($user, \App\Notifications\VerifyParentEmail::class);
    }

    public function test_signed_link_verifies_email(): void
    {
        $user = User::factory()->unverified()->create(['role' => User::ROLE_PARENT]);

        $url = URL::temporarySignedRoute(
            'verification.verify',
            now()->addHour(),
            ['id' => $user->id, 'hash' => sha1($user->email)],
        );

        $this->get($url)->assertOk();
        $this->assertTrue($user->fresh()->hasVerifiedEmail());
    }

    public function test_unverified_parent_cannot_submit_learning_record(): void
    {
        $parent = User::factory()->unverified()->create(['role' => User::ROLE_PARENT]);
        $parent->students()->create([
            'name' => '小華',
            'grade' => 1,
            'device_local_id' => 'p1',
            'sort' => 0,
        ]);
        $token = $parent->createToken('t')->plainTextToken;

        $this->postJson(
            '/api/v1/learning/records',
            [
                'device_local_id' => 'p1',
                'activity_type' => 'lesson_quiz',
                'correct_count' => 1,
                'question_count' => 1,
            ],
            ['Authorization' => 'Bearer '.$token],
        )->assertForbidden()
            ->assertJsonPath('code', 'email_unverified');
    }

    public function test_resend_verification(): void
    {
        Notification::fake();
        $parent = User::factory()->unverified()->create(['role' => User::ROLE_PARENT]);
        $token = $parent->createToken('t')->plainTextToken;

        $this->postJson(
            '/api/v1/user/email/resend',
            [],
            ['Authorization' => 'Bearer '.$token],
        )->assertOk()->assertJsonPath('message', 'sent');

        Notification::assertSentTo($parent, \App\Notifications\VerifyParentEmail::class);
    }

    public function test_unverified_parent_web_panel_redirects_to_notice(): void
    {
        $parent = User::factory()->unverified()->create(['role' => User::ROLE_PARENT]);

        $this->actingAs($parent)
            ->get('/parent')
            ->assertRedirect(route('parent.email.notice'));

        $this->actingAs($parent)
            ->get('/email/unverified')
            ->assertOk()
            ->assertSee('請先驗證 Email')
            ->assertSee($parent->email, false);
    }

    public function test_unverified_parent_can_resend_from_notice_page(): void
    {
        Notification::fake();
        $parent = User::factory()->unverified()->create(['role' => User::ROLE_PARENT]);

        $this->actingAs($parent)
            ->post('/email/unverified/resend')
            ->assertRedirect(route('parent.email.notice'));

        Notification::assertSentTo($parent, VerifyParentEmail::class);
    }

    public function test_login_locks_after_repeated_failures(): void
    {
        User::factory()->create([
            'role' => User::ROLE_PARENT,
            'email' => 'parent@example.com',
        ]);

        for ($i = 0; $i < 5; $i++) {
            $this->postJson('/api/v1/user/login', [
                'email' => 'parent@example.com',
                'password' => 'wrong-password',
            ])->assertStatus(422);
        }

        $locked = $this->postJson('/api/v1/user/login', [
            'email' => 'parent@example.com',
            'password' => 'wrong-password',
        ]);

        $locked->assertStatus(422);
        $this->assertStringContainsString(
            '嘗試次數過多',
            (string) $locked->json('errors.email.0'),
        );
    }
}
