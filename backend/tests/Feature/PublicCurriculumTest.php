<?php

namespace Tests\Feature;

use App\Models\Lesson;
use App\Models\Question;
use App\Models\Subject;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PublicCurriculumTest extends TestCase
{
    use RefreshDatabase;

    public function test_public_endpoints_omit_premium_content_even_if_asked(): void
    {
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

        $freeLesson = Lesson::query()->create([
            'code' => 'math-free',
            'subject_id' => $subject->id,
            'grade' => 1,
            'title' => '免費單元',
            'content' => '免費課文',
            'is_published' => true,
            'is_premium' => false,
        ]);
        $premiumLesson = Lesson::query()->create([
            'code' => 'math-paid',
            'subject_id' => $subject->id,
            'grade' => 1,
            'title' => '付費單元',
            'content' => '付費課文秘密',
            'is_published' => true,
            'is_premium' => true,
        ]);
        $draftLesson = Lesson::query()->create([
            'code' => 'math-draft',
            'subject_id' => $subject->id,
            'grade' => 1,
            'title' => '未上架單元',
            'content' => '草稿課文秘密',
            'is_published' => false,
            'is_premium' => false,
        ]);

        $this->question($subject->id, $freeLesson->id, 'free-q', '免費題目', false);
        $this->question($subject->id, $freeLesson->id, 'paid-q', '付費題目秘密', true);
        $this->question($subject->id, $premiumLesson->id, 'on-paid-lesson', '掛在付費課的題目', false);
        $this->question($subject->id, $draftLesson->id, 'on-draft-lesson', '掛在草稿課的題目', false);
        $this->question($subject->id, null, 'standalone', '獨立免費題', false);

        foreach (['/api/v1/content/snapshot?include_premium=1', '/api/v1/snapshot?include_premium=1'] as $url) {
            $snapshot = $this->getJson($url)->assertOk();
            $body = json_encode($snapshot->json(), JSON_UNESCAPED_UNICODE);
            $this->assertIsString($body);
            $this->assertStringContainsString('免費題目', $body);
            $this->assertStringContainsString('獨立免費題', $body);
            $this->assertStringContainsString('免費課文', $body);
            $this->assertStringNotContainsString('付費題目秘密', $body);
            $this->assertStringNotContainsString('掛在付費課的題目', $body);
            $this->assertStringNotContainsString('掛在草稿課的題目', $body);
            $this->assertStringNotContainsString('付費課文秘密', $body);
            $this->assertStringNotContainsString('草稿課文秘密', $body);
        }

        $questions = $this->getJson('/api/v1/content/questions?include_premium=1&limit=50')->assertOk();
        $prompts = collect($questions->json('data'))->pluck('prompt')->all();
        $this->assertEqualsCanonicalizing(['免費題目', '獨立免費題'], $prompts);

        $this->getJson('/api/v1/content/lessons/math-paid')->assertNotFound();
        $this->getJson('/api/v1/content/lessons/math-free')
            ->assertOk()
            ->assertJsonPath('data.questions.0.prompt', '免費題目');
        $this->assertCount(1, $this->getJson('/api/v1/content/lessons/math-free')->json('data.questions'));
    }

    private function question(int $subjectId, ?int $lessonId, string $code, string $prompt, bool $premium): void
    {
        Question::query()->create([
            'code' => $code,
            'subject_id' => $subjectId,
            'lesson_id' => $lessonId,
            'grade' => 1,
            'type' => 'multiple_choice',
            'difficulty' => 'normal',
            'prompt' => $prompt,
            'options' => ['甲', '乙'],
            'correct_index' => 0,
            'is_published' => true,
            'is_premium' => $premium,
            'approval_status' => Question::APPROVAL_APPROVED,
            'sort' => 1,
        ]);
    }
}
