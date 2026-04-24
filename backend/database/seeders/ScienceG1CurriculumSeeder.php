<?php

namespace Database\Seeders;

use App\Models\Lesson;
use App\Models\Question;
use App\Models\Subject;
use App\Models\VocabularyItem;
use Illuminate\Database\Seeder;

/**
 * 與 Flutter `lib/data/science_g1_lessons.dart` 同步：小一自然 11 課 + 單元題目。
 *
 * 資料來源：database/data/science_g1_sync.php
 */
class ScienceG1CurriculumSeeder extends Seeder
{
    public function run(): void
    {
        $rows = require database_path('data/science_g1_sync.php');
        if (! is_array($rows)) {
            return;
        }

        // 移除舊版小一自然單元代碼（與 App 課程 id 不一致者）
        Lesson::where('code', 'cl-s-1-1-u1')->delete();

        $sortBase = (int) Lesson::max('sort') + 1;

        foreach ($rows as $i => $data) {
            $subject = Subject::where('code', $data['subject'])->firstOrFail();

            $lesson = Lesson::updateOrCreate(
                ['code' => $data['code']],
                [
                    'subject_id' => $subject->id,
                    'grade' => $data['grade'],
                    'semester' => $data['semester'],
                    'unit' => $data['unit'],
                    'track' => $data['track'] ?? 'core',
                    'title' => $data['title'],
                    'summary' => $data['summary'] ?? null,
                    'content' => $data['content'] ?? null,
                    'objectives' => $data['objectives'] ?? [],
                    'key_points' => $data['key_points'] ?? [],
                    'estimated_minutes' => $data['estimated_minutes'] ?? 10,
                    'is_published' => true,
                    'is_premium' => false,
                    'sort' => $sortBase + $i,
                ]
            );

            $lesson->vocabularyItems()->delete();
            foreach ($data['vocab'] ?? [] as $vi => $v) {
                VocabularyItem::create([
                    'lesson_id' => $lesson->id,
                    'term' => $v['term'],
                    'meaning' => $v['meaning'],
                    'example' => $v['example'] ?? null,
                    'sort' => $vi,
                ]);
            }

            foreach ($data['questions'] ?? [] as $qi => $q) {
                Question::updateOrCreate(
                    ['code' => $q['code']],
                    [
                        'subject_id' => $subject->id,
                        'lesson_id' => $lesson->id,
                        'grade' => $data['grade'],
                        'type' => 'multiple_choice',
                        'difficulty' => 'easy',
                        'prompt' => $q['prompt'],
                        'options' => $q['options'],
                        'correct_index' => $q['correct_index'],
                        'explanation' => $q['explanation'] ?? null,
                        'is_published' => true,
                        'is_premium' => false,
                        'sort' => $qi,
                    ]
                );
            }
        }
    }
}
