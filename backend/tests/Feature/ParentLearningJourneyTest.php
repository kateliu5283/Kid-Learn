<?php

namespace Tests\Feature;

use App\Models\StudentLearningRecord;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Notification;
use Tests\TestCase;

/**
 * 家長從註冊、未驗證、改密碼、上傳到還原進度的一條路徑。
 */
class ParentLearningJourneyTest extends TestCase
{
    use RefreshDatabase;

    public function test_parent_can_register_change_password_upload_and_restore_progress(): void
    {
        Notification::fake();

        $registered = $this->api('post', '/api/v1/user/register', [
            'name' => '家長',
            'email' => 'journey@example.com',
            'password' => 'old-secret-1',
            'password_confirmation' => 'old-secret-1',
            'device_id' => 'phone-device',
            'device_label' => 'iPhone',
            'students' => [[
                'name' => '小華',
                'grade' => 2,
                'avatar' => '🦊',
                'device_local_id' => 'child-1',
            ]],
        ]);
        $registered->assertCreated()
            ->assertJsonPath('data.user.email_verified', false)
            ->assertJsonPath('data.students.0.device_local_id', 'child-1');
        $phone = $registered->json('data.token');
        $this->assertIsString($phone);

        $user = User::query()->where('email', 'journey@example.com')->firstOrFail();

        $this->api('post', '/api/v1/learning/records', $this->quizPayload(), $phone)
            ->assertForbidden()
            ->assertJsonPath('code', 'email_unverified');
        $this->api('get', '/api/v1/learning/progress', [], $phone)
            ->assertForbidden()
            ->assertJsonPath('code', 'email_unverified');

        $tablet = $this->api('post', '/api/v1/user/login', [
            'email' => 'journey@example.com',
            'password' => 'old-secret-1',
            'device_id' => 'tablet-device',
            'device_label' => 'iPad',
        ])->assertOk()->json('data.token');

        $this->api('put', '/api/v1/user/password', [
            'current_password' => 'nope',
            'password' => 'new-secret-1',
            'password_confirmation' => 'new-secret-1',
        ], $phone)->assertStatus(422);

        $this->api('put', '/api/v1/user/password', [
            'current_password' => 'old-secret-1',
            'password' => 'old-secret-1',
            'password_confirmation' => 'old-secret-1',
        ], $phone)->assertStatus(422);

        $this->api('put', '/api/v1/user/password', [
            'current_password' => 'old-secret-1',
            'password' => 'new-secret-1',
            'password_confirmation' => 'new-secret-1',
        ], $phone)->assertOk()->assertJsonPath('message', '密碼已更新。');

        $this->api('get', '/api/v1/user/me', [], $phone)->assertOk();
        $this->api('get', '/api/v1/user/me', [], $tablet)->assertUnauthorized();
        $this->assertSame(1, $user->fresh()->tokens()->count());

        $this->api('post', '/api/v1/user/login', [
            'email' => 'journey@example.com',
            'password' => 'old-secret-1',
            'device_id' => 'tablet-device2',
        ])->assertStatus(422);

        $tablet = $this->api('post', '/api/v1/user/login', [
            'email' => 'journey@example.com',
            'password' => 'new-secret-1',
            'device_id' => 'tablet-device2',
            'device_label' => 'iPad',
        ])->assertOk()->json('data.token');

        $this->api('post', '/api/v1/learning/records', $this->quizPayload(), $tablet)
            ->assertForbidden()
            ->assertJsonPath('code', 'email_unverified');

        $user->forceFill(['email_verified_at' => now()])->save();

        $yesterday = Carbon::now('Asia/Taipei')->subDay();
        $today = Carbon::now('Asia/Taipei')->subMinutes(5);

        $this->api('post', '/api/v1/learning/records', [
            'device_local_id' => 'missing-child',
            'activity_type' => 'game_memory_match',
            'correct_count' => 6,
            'question_count' => 6,
            'duration_seconds' => 40,
            'client_submission_id' => 'missing-1',
        ], $tablet)->assertNotFound();

        $this->api('post', '/api/v1/learning/records', [
            'device_local_id' => 'child-1',
            'activity_type' => 'lesson_quiz',
            'context_key' => 'math_g1_u1',
            'correct_count' => 9,
            'question_count' => 10,
            'client_submission_id' => 'quiz-1',
            'recorded_at' => $yesterday->toIso8601String(),
        ], $tablet)->assertCreated();

        $this->api('post', '/api/v1/learning/records', [
            'device_local_id' => 'child-1',
            'activity_type' => 'lesson_quiz',
            'context_key' => 'math_g1_u1',
            'correct_count' => 1,
            'question_count' => 10,
            'client_submission_id' => 'quiz-1',
            'recorded_at' => $today->toIso8601String(),
        ], $tablet)->assertOk()->assertJsonPath('duplicate', true);

        $this->api('post', '/api/v1/learning/records', [
            'device_local_id' => 'child-1',
            'activity_type' => 'daily_review',
            'context_key' => 'math',
            'correct_count' => 11,
            'question_count' => 10,
            'client_submission_id' => 'bad-1',
        ], $tablet)->assertStatus(422);

        foreach ([
            ['daily_review', 'math', 8, 10, null, 'daily-1', $today],
            ['daily_review', 'math', 6, 10, null, 'daily-2', $today],
            ['game_math_blitz', null, 12, 20, 60, 'math-1', $today],
            ['game_math_blitz', null, 18, 20, 60, 'math-2', $today],
            ['game_memory_match', null, 6, 6, 40, 'mem-1', $today],
            ['game_memory_match', null, 6, 6, 25, 'mem-2', $today],
            ['game_word_rain', null, 9, 9, null, 'rain-1', $today],
        ] as [$type, $context, $correct, $total, $duration, $submission, $when]) {
            $payload = [
                'device_local_id' => 'child-1',
                'activity_type' => $type,
                'correct_count' => $correct,
                'question_count' => $total,
                'client_submission_id' => $submission,
                'recorded_at' => $when->toIso8601String(),
            ];
            if ($context !== null) {
                $payload['context_key'] = $context;
            }
            if ($duration !== null) {
                $payload['duration_seconds'] = $duration;
            }
            $this->api('post', '/api/v1/learning/records', $payload, $tablet)->assertCreated();
        }

        $this->assertSame(8, StudentLearningRecord::query()->count());

        $progress = $this->api('get', '/api/v1/learning/progress', [], $phone);
        $progress->assertOk()
            ->assertJsonPath('data.0.device_local_id', 'child-1')
            ->assertJsonPath('data.0.lessons.0.lesson_id', 'math_g1_u1')
            ->assertJsonPath('data.0.lessons.0.stars', 3)
            ->assertJsonPath('data.0.lessons.0.last_score', 9)
            ->assertJsonCount(1, 'data.0.lessons');

        $dates = [
            $yesterday->toDateString(),
            $today->toDateString(),
        ];
        sort($dates);
        $progress->assertJsonPath('data.0.study_dates', array_values(array_unique($dates)));

        $activities = collect($progress->json('data.0.activities'))->keyBy('activity_type');
        $this->assertFalse($activities->has('lesson_quiz'));
        $this->assertSame(8, $activities['daily_review']['best_correct']);
        $this->assertSame(80, $activities['daily_review']['best_percent']);
        $this->assertSame(2, $activities['daily_review']['attempts']);
        $this->assertSame(18, $activities['game_math_blitz']['best_correct']);
        $this->assertSame(2, $activities['game_math_blitz']['attempts']);
        $this->assertNull($activities['game_math_blitz']['best_duration_seconds']);
        $this->assertSame(25, $activities['game_memory_match']['best_duration_seconds']);
        $this->assertSame(2, $activities['game_memory_match']['attempts']);
        $this->assertSame(9, $activities['game_word_rain']['best_correct']);
        $this->assertSame(1, $activities['game_word_rain']['attempts']);
    }

    /**
     * @param  array<string, mixed>  $data
     */
    private function api(string $method, string $uri, array $data, ?string $token = null): \Illuminate\Testing\TestResponse
    {
        $this->app['auth']->forgetGuards();
        $headers = $token === null ? [] : ['Authorization' => 'Bearer '.$token];

        return match ($method) {
            'post' => $this->postJson($uri, $data, $headers),
            'put' => $this->putJson($uri, $data, $headers),
            default => $this->getJson($uri, $headers),
        };
    }

    /**
     * @return array<string, mixed>
     */
    private function quizPayload(): array
    {
        return [
            'device_local_id' => 'child-1',
            'activity_type' => 'lesson_quiz',
            'context_key' => 'math_g1_u1',
            'correct_count' => 9,
            'question_count' => 10,
            'client_submission_id' => 'quiz-early',
        ];
    }
}
