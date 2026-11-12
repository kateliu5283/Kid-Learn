<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Auth\Events\Login;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TeacherInviteTest extends TestCase
{
    use RefreshDatabase;

    public function test_parent_can_request_teacher_invite_join_url(): void
    {
        $parent = User::factory()->create(['role' => User::ROLE_PARENT]);
        $student = $parent->students()->create([
            'name' => '小華',
            'grade' => 2,
            'device_local_id' => 'local-1',
            'sort' => 1,
        ]);
        $token = $parent->createToken('t')->plainTextToken;

        $res = $this->postJson(
            "/api/v1/user/students/{$student->id}/teacher-invite",
            [],
            ['Authorization' => 'Bearer '.$token],
        );

        $res->assertOk();
        $joinUrl = $res->json('data.join_url');
        $this->assertIsString($joinUrl);
        $this->assertStringContainsString('/join-teaching/', $joinUrl);
        $student->refresh();
        $this->assertNotNull($student->teacher_invite_token);
        $this->assertNotNull($student->teacher_invite_expires_at);
        $this->assertTrue($student->teacher_invite_expires_at->isFuture());
        $this->assertStringEndsWith($student->teacher_invite_token, $joinUrl);
    }

    public function test_teacher_hitting_join_url_attaches_student(): void
    {
        $parent = User::factory()->create(['role' => User::ROLE_PARENT]);
        $student = $parent->students()->create([
            'name' => '小美',
            'grade' => 1,
            'sort' => 1,
        ]);
        $student->ensureTeacherInviteToken(false);

        $teacher = User::factory()->create(['role' => User::ROLE_TEACHER]);

        $this->actingAs($teacher)
            ->get('/join-teaching/'.$student->teacher_invite_token)
            ->assertRedirect('/teacher');

        $this->assertTrue($teacher->fresh()->taughtStudents->contains($student));
        $student->refresh();
        $this->assertNull($student->teacher_invite_token);
    }

    public function test_expired_invite_is_rejected(): void
    {
        $parent = User::factory()->create(['role' => User::ROLE_PARENT]);
        $student = $parent->students()->create([
            'name' => '小美',
            'grade' => 1,
            'sort' => 1,
        ]);
        $student->ensureTeacherInviteToken(false);
        $student->forceFill([
            'teacher_invite_expires_at' => now()->subMinute(),
        ])->save();

        $teacher = User::factory()->create(['role' => User::ROLE_TEACHER]);

        $this->actingAs($teacher)
            ->get('/join-teaching/'.$student->teacher_invite_token)
            ->assertNotFound();
    }

    public function test_login_event_processes_pending_invite_in_session(): void
    {
        $parent = User::factory()->create(['role' => User::ROLE_PARENT]);
        $student = $parent->students()->create([
            'name' => '小強',
            'grade' => 3,
            'sort' => 1,
        ]);
        $student->ensureTeacherInviteToken(false);

        $teacher = User::factory()->create(['role' => User::ROLE_TEACHER]);

        $this->withSession(['pending_teacher_invite_token' => $student->teacher_invite_token]);
        event(new Login('web', $teacher, false));

        $this->assertTrue($teacher->fresh()->taughtStudents->contains($student));
        $this->assertNull(session('pending_teacher_invite_token'));
        $student->refresh();
        $this->assertNull($student->teacher_invite_token);
    }

    public function test_fetching_invite_again_does_not_extend_expiry(): void
    {
        $parent = User::factory()->create(['role' => User::ROLE_PARENT]);
        $student = $parent->students()->create([
            'name' => '小華',
            'grade' => 2,
            'device_local_id' => 'local-1',
            'sort' => 1,
        ]);
        $token = $parent->createToken('t')->plainTextToken;

        $this->postJson(
            "/api/v1/user/students/{$student->id}/teacher-invite",
            [],
            ['Authorization' => 'Bearer '.$token],
        )->assertOk();

        $student->refresh();
        $invite = $student->teacher_invite_token;
        $expires = $student->teacher_invite_expires_at->clone();

        $this->travel(30)->minutes();

        $this->postJson(
            "/api/v1/user/students/{$student->id}/teacher-invite",
            [],
            ['Authorization' => 'Bearer '.$token],
        )->assertOk()
            ->assertJsonPath('data.join_url', rtrim((string) config('app.url'), '/').'/join-teaching/'.$invite);

        $student->refresh();
        $this->assertSame($invite, $student->teacher_invite_token);
        $this->assertTrue($student->teacher_invite_expires_at->equalTo($expires));
    }

    public function test_invite_cannot_be_used_twice(): void
    {
        $parent = User::factory()->create(['role' => User::ROLE_PARENT]);
        $student = $parent->students()->create([
            'name' => '小美',
            'grade' => 1,
            'sort' => 1,
        ]);
        $student->ensureTeacherInviteToken(false);
        $teacher = User::factory()->create(['role' => User::ROLE_TEACHER]);
        $url = '/join-teaching/'.$student->teacher_invite_token;

        $this->actingAs($teacher)->get($url)->assertRedirect('/teacher');
        $this->actingAs($teacher)->get($url)->assertNotFound();
    }

    public function test_unverified_parent_cannot_request_teacher_invite(): void
    {
        $parent = User::factory()->unverified()->create(['role' => User::ROLE_PARENT]);
        $student = $parent->students()->create([
            'name' => '小華',
            'grade' => 1,
            'sort' => 0,
        ]);
        $token = $parent->createToken('t')->plainTextToken;

        $this->postJson(
            "/api/v1/user/students/{$student->id}/teacher-invite",
            [],
            ['Authorization' => 'Bearer '.$token],
        )->assertForbidden()
            ->assertJsonPath('code', 'email_unverified');
    }

    public function test_parent_cannot_update_another_parents_student(): void
    {
        $owner = User::factory()->create(['role' => User::ROLE_PARENT]);
        $student = $owner->students()->create([
            'name' => '小華',
            'grade' => 1,
            'sort' => 0,
        ]);
        $other = User::factory()->create(['role' => User::ROLE_PARENT]);
        $token = $other->createToken('t')->plainTextToken;

        $this->putJson(
            "/api/v1/user/students/{$student->id}",
            ['name' => '被改掉'],
            ['Authorization' => 'Bearer '.$token],
        )->assertNotFound();

        $this->assertSame('小華', $student->fresh()->name);
    }
}
