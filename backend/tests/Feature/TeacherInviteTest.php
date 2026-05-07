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
    }
}
