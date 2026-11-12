<?php

namespace Tests\Feature;

use App\Models\Question;
use App\Models\Subject;
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

    public function test_server_grades_answers_when_questions_exist(): void
    {
        $parent = User::factory()->create(['role' => User::ROLE_PARENT]);
        $parent->students()->create([
            'name' => '小華',
            'grade' => 2,
            'device_local_id' => 'profile-xyz',
            'sort' => 0,
        ]);

        $subject = Subject::query()->create([
            'code' => 'math',
            'name' => '數學',
            'english_name' => 'Math',
            'icon' => 'calculate',
            'color' => '#000',
            'description' => '',
            'is_active' => true,
            'sort' => 1,
        ]);

        Question::query()->create([
            'code' => 'q-test-a',
            'subject_id' => $subject->id,
            'grade' => 1,
            'type' => 'multiple_choice',
            'difficulty' => 'normal',
            'prompt' => '1+1?',
            'options' => ['1', '2', '3', '4'],
            'correct_index' => 1,
            'is_published' => true,
            'is_premium' => false,
            'approval_status' => Question::APPROVAL_APPROVED,
            'sort' => 1,
        ]);
        Question::query()->create([
            'code' => 'q-test-b',
            'subject_id' => $subject->id,
            'grade' => 1,
            'type' => 'multiple_choice',
            'difficulty' => 'normal',
            'prompt' => '2+2?',
            'options' => ['3', '4', '5', '6'],
            'correct_index' => 1,
            'is_published' => true,
            'is_premium' => false,
            'approval_status' => Question::APPROVAL_APPROVED,
            'sort' => 2,
        ]);

        $token = $parent->createToken('test')->plainTextToken;

        // 客戶端謊報 2/2，但 answers 只有第一題對 → 伺服器應記 1/2
        $res = $this->postJson(
            '/api/v1/learning/records',
            [
                'device_local_id' => 'profile-xyz',
                'activity_type' => 'lesson_quiz',
                'correct_count' => 2,
                'question_count' => 2,
                'score_percent' => 100,
                'answers' => [
                    ['question_code' => 'q-test-a', 'selected_index' => 1],
                    ['question_code' => 'q-test-b', 'selected_index' => 0],
                ],
                'client_submission_id' => 'grade-001',
            ],
            ['Authorization' => 'Bearer '.$token],
        );

        $res->assertCreated()
            ->assertJsonPath('data.correct_count', 1)
            ->assertJsonPath('data.question_count', 2)
            ->assertJsonPath('data.score_percent', 50)
            ->assertJsonPath('data.meta.grading', 'server');
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

    public function test_parent_cannot_submit_record_for_another_parents_student(): void
    {
        $owner = User::factory()->create(['role' => User::ROLE_PARENT]);
        $student = $owner->students()->create([
            'name' => '小華',
            'grade' => 1,
            'device_local_id' => 'owner-device',
            'sort' => 0,
        ]);
        $other = User::factory()->create(['role' => User::ROLE_PARENT]);
        $token = $other->createToken('t')->plainTextToken;

        $this->postJson(
            '/api/v1/learning/records',
            [
                'student_id' => $student->id,
                'activity_type' => 'lesson_quiz',
                'correct_count' => 1,
                'question_count' => 1,
            ],
            ['Authorization' => 'Bearer '.$token],
        )->assertStatus(422);

        $this->assertSame(0, $student->learningRecords()->count());
    }

    public function test_recorded_at_far_in_the_future_is_rejected(): void
    {
        $parent = User::factory()->create(['role' => User::ROLE_PARENT]);
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
                'recorded_at' => now()->addDays(3)->toIso8601String(),
            ],
            ['Authorization' => 'Bearer '.$token],
        )->assertStatus(422);
    }
}
