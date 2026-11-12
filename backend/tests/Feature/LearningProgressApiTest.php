<?php

namespace Tests\Feature;

use App\Models\StudentLearningRecord;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LearningProgressApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_progress_keeps_best_stars_and_latest_score(): void
    {
        $parent = User::factory()->create(['role' => User::ROLE_PARENT]);
        $student = $parent->students()->create([
            'name' => '小華',
            'grade' => 2,
            'avatar' => '🦊',
            'device_local_id' => 'p-local',
            'sort' => 0,
        ]);
        $blank = $parent->students()->create([
            'name' => '小明',
            'grade' => 1,
            'device_local_id' => null,
            'sort' => 1,
        ]);

        StudentLearningRecord::query()->create([
            'student_id' => $student->id,
            'activity_type' => 'lesson_quiz',
            'context_key' => 'math_g1_u1',
            'correct_count' => 10,
            'question_count' => 10,
            'recorded_at' => now()->subHour(),
        ]);
        StudentLearningRecord::query()->create([
            'student_id' => $student->id,
            'activity_type' => 'lesson_review',
            'context_key' => 'math_g1_u1',
            'correct_count' => 4,
            'question_count' => 10,
            'recorded_at' => now(),
        ]);
        StudentLearningRecord::query()->create([
            'student_id' => $student->id,
            'activity_type' => 'daily_review',
            'context_key' => 'math',
            'correct_count' => 10,
            'question_count' => 10,
            'recorded_at' => now(),
        ]);

        $other = User::factory()->create(['role' => User::ROLE_PARENT]);
        $otherStudent = $other->students()->create([
            'name' => '別人的孩子',
            'grade' => 3,
            'device_local_id' => 'other',
            'sort' => 0,
        ]);
        StudentLearningRecord::query()->create([
            'student_id' => $otherStudent->id,
            'activity_type' => 'lesson_quiz',
            'context_key' => 'secret_lesson',
            'correct_count' => 10,
            'question_count' => 10,
            'recorded_at' => now(),
        ]);

        $token = $parent->createToken('kid-learn-app')->plainTextToken;
        $res = $this->getJson('/api/v1/learning/progress', [
            'Authorization' => 'Bearer '.$token,
        ]);

        $res->assertOk()
            ->assertJsonPath('data.0.device_local_id', 'p-local')
            ->assertJsonPath('data.0.lessons.0.lesson_id', 'math_g1_u1')
            ->assertJsonPath('data.0.lessons.0.stars', 3)
            ->assertJsonPath('data.0.lessons.0.last_score', 4)
            ->assertJsonPath('data.0.lessons.0.question_count', 10)
            ->assertJsonPath('data.1.name', '小明')
            ->assertJsonPath('data.1.device_local_id', 'c_'.$blank->id)
            ->assertJsonPath('data.1.lessons', []);

        $this->assertCount(1, $res->json('data.0.lessons'));
        $this->assertSame('c_'.$blank->id, $blank->fresh()->device_local_id);

        $again = $this->getJson('/api/v1/learning/progress', [
            'Authorization' => 'Bearer '.$token,
        ]);
        $again->assertJsonPath('data.1.device_local_id', 'c_'.$blank->id);

        $encoded = json_encode($res->json());
        $this->assertIsString($encoded);
        $this->assertStringNotContainsString('secret_lesson', $encoded);
        $this->assertStringNotContainsString('別人的孩子', $encoded);
    }

    public function test_unverified_parent_cannot_read_progress(): void
    {
        $parent = User::factory()->unverified()->create(['role' => User::ROLE_PARENT]);
        $token = $parent->createToken('kid-learn-app')->plainTextToken;

        $this->getJson('/api/v1/learning/progress', [
            'Authorization' => 'Bearer '.$token,
        ])->assertForbidden()
            ->assertJsonPath('code', 'email_unverified');
    }
}
