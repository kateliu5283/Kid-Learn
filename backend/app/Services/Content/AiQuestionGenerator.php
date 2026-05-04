<?php

namespace App\Services\Content;

use App\Models\Question;
use App\Models\Subject;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use RuntimeException;

/**
 * 呼叫相容 OpenAI 的 Chat Completions API 產生選擇題，寫入為待審核（不發佈）。
 */
class AiQuestionGenerator
{
    public function generate(
        int $subjectId,
        int $grade,
        int $count,
        ?int $lessonId = null,
        ?string $topicFocus = null,
    ): array {
        $apiKey = config('services.openai.key');
        if (empty($apiKey)) {
            throw new RuntimeException('未設定 OPENAI_API_KEY，無法使用 AI 出題。');
        }

        $count = max(1, min(20, $count));
        $subject = Subject::query()->findOrFail($subjectId);
        $baseUrl = rtrim((string) config('services.openai.base_url'), '/');
        $model = (string) config('services.openai.question_model');

        $topicLine = $topicFocus ? "主題或範圍重點：{$topicFocus}\n" : '';

        $userPrompt = <<<TXT
請為台灣國小課程產生 {$count} 道「選擇題」。
學科：{$subject->name}（代碼 {$subject->code}）
年級：{$grade} 年級
{$topicLine}
每題需有 4 個選項、一個正確答案、簡短解析。用語符合該年級程度，使用繁體中文（台灣用字）。
回傳 JSON 物件，鍵為 "questions"，值為陣列；每個元素欄位：
- "prompt"：題幹字串
- "options"：長度 4 的字串陣列
- "correct_index"：0 到 3 的整數
- "difficulty"："easy"、"normal" 或 "hard" 之一
- "explanation"：解析字串
TXT;

        $url = $baseUrl.'/chat/completions';
        $response = Http::withToken($apiKey)
            ->timeout(120)
            ->acceptJson()
            ->post($url, [
                'model' => $model,
                'response_format' => ['type' => 'json_object'],
                'messages' => [
                    [
                        'role' => 'system',
                        'content' => '你只輸出合法 JSON，不要 Markdown 或額外說明。',
                    ],
                    ['role' => 'user', 'content' => $userPrompt],
                ],
                'temperature' => 0.7,
            ]);

        if (! $response->successful()) {
            throw new RuntimeException('API 錯誤：HTTP '.$response->status().' — '.$response->body());
        }

        $content = data_get($response->json(), 'choices.0.message.content');
        if (! is_string($content) || $content === '') {
            throw new RuntimeException('API 回應無有效內容。');
        }

        $decoded = json_decode($this->stripJsonFences($content), true);
        if (! is_array($decoded) || ! isset($decoded['questions']) || ! is_array($decoded['questions'])) {
            throw new RuntimeException('無法解析題目 JSON（缺少 questions 陣列）。');
        }

        $created = [];
        $maxSort = (int) Question::query()
            ->where('subject_id', $subjectId)
            ->where('grade', $grade)
            ->max('sort');

        foreach ($decoded['questions'] as $i => $row) {
            if (count($created) >= $count) {
                break;
            }
            if (! is_array($row)) {
                continue;
            }

            $validated = $this->validateRow($row);
            if ($validated === null) {
                continue;
            }

            $code = $this->uniqueCode();
            $created[] = Question::query()->create([
                'code' => $code,
                'source' => Question::SOURCE_AI,
                'approval_status' => Question::APPROVAL_PENDING,
                'subject_id' => $subjectId,
                'lesson_id' => $lessonId,
                'grade' => $grade,
                'type' => 'multiple_choice',
                'difficulty' => $validated['difficulty'],
                'prompt' => $validated['prompt'],
                'options' => $validated['options'],
                'correct_index' => $validated['correct_index'],
                'explanation' => $validated['explanation'],
                'is_published' => false,
                'is_premium' => false,
                'sort' => $maxSort + count($created) + 1,
                'ai_model' => $model,
            ]);
        }

        if ($created === []) {
            throw new RuntimeException('沒有產生任何有效題目，請調整主題或稍後再試。');
        }

        return $created;
    }

    protected function stripJsonFences(string $content): string
    {
        $t = trim($content);
        if (str_starts_with($t, '```')) {
            $t = preg_replace('/^```(?:json)?\s*/i', '', $t) ?? $t;
            $t = preg_replace('/\s*```$/', '', $t) ?? $t;
        }

        return trim($t);
    }

    /**
     * @param  array<string, mixed>  $row
     * @return array{prompt: string, options: list<string>, correct_index: int, difficulty: string, explanation: string}|null
     */
    protected function validateRow(array $row): ?array
    {
        $prompt = isset($row['prompt']) && is_string($row['prompt']) ? trim($row['prompt']) : '';
        if ($prompt === '') {
            return null;
        }

        $options = $row['options'] ?? null;
        if (! is_array($options) || count($options) !== 4) {
            return null;
        }

        $flat = [];
        foreach ($options as $o) {
            if (! is_string($o) || trim($o) === '') {
                return null;
            }
            $flat[] = trim($o);
        }

        $ci = $row['correct_index'] ?? null;
        if (! is_int($ci) && ! (is_string($ci) && ctype_digit($ci))) {
            return null;
        }
        $ci = (int) $ci;
        if ($ci < 0 || $ci > 3) {
            return null;
        }

        $diff = $row['difficulty'] ?? 'normal';
        if (! is_string($diff) || ! in_array($diff, ['easy', 'normal', 'hard'], true)) {
            $diff = 'normal';
        }

        $explanation = isset($row['explanation']) && is_string($row['explanation'])
            ? trim($row['explanation'])
            : '';

        return [
            'prompt' => $prompt,
            'options' => $flat,
            'correct_index' => $ci,
            'difficulty' => $diff,
            'explanation' => $explanation,
        ];
    }

    protected function uniqueCode(): string
    {
        for ($i = 0; $i < 20; $i++) {
            $code = 'q-ai-'.Str::lower(Str::random(12));
            if (! Question::query()->where('code', $code)->exists()) {
                return $code;
            }
        }

        throw new RuntimeException('無法產生唯一題目代碼。');
    }
}
