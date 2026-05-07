<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LearningRecordApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_parent_can_submit_learning_record_by_device_local_id(): void
    {
        $parent = User::factory()->create(['role' => User::ROLE_PARENT]);
        $parent->students()->create([
            'name' => '小華',
            'grade' => 2,
            'device_local_id' => 'profile-xyz',
            'sort' => 0,
        ]);

        $token = $parent->createToken('test')->plainTextToken;

        $res = $this->postJson(
            '/api/v1/learning/records',
            [
                'device_local_id' => 'profile-xyz',
                'activity_type' => 'lesson_quiz',
                'context_key' => 'math_g1_u1',
                'title' => '測驗',
                'correct_count' => 8,
                'question_count' => 10,
                'client_submission_id' => 'sub-001',
            ],
            ['Authorization' => 'Bearer '.$token],
        );

        $res->assertCreated()
            ->assertJsonPath('data.correct_count', 8)
            ->assertJsonPath('data.question_count', 10)
            ->assertJsonPath('data.score_percent', 80);

        $dup = $this->postJson(
            '/api/v1/learning/records',
            [
                'device_local_id' => 'profile-xyz',
                'activity_type' => 'lesson_quiz',
                'correct_count' => 8,
                'question_count' => 10,
                'client_submission_id' => 'sub-001',
            ],
            ['Authorization' => 'Bearer '.$token],
        );
        $dup->assertOk()->assertJsonPath('duplicate', true);
    }

    public function test_teacher_cannot_submit_learning_record(): void
    {
        $teacher = User::factory()->create(['role' => User::ROLE_TEACHER]);
        $token = $teacher->createToken('t')->plainTextToken;

        $this->postJson(
            '/api/v1/learning/records',
            [
                'device_local_id' => 'x',
                'activity_type' => 'lesson_quiz',
                'correct_count' => 1,
                'question_count' => 1,
            ],
            ['Authorization' => 'Bearer '.$token],
        )->assertForbidden();
    }
}
