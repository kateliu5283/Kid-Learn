<?php

namespace Database\Seeders;

use App\Models\Lesson;
use App\Models\Subject;
use App\Models\VocabularyItem;
use Illuminate\Database\Seeder;

class LessonSeeder extends Seeder
{
    public function run(): void
    {
        $lessons = [
            // 國語 一年級 ===========================
            [
                'code' => 'cl-c-1-1-u1', 'subject' => 'chinese', 'grade' => 1, 'semester' => 'first', 'unit' => 1,
                'title' => '我會說早安',
                'summary' => '學會向家人和老師打招呼。',
                'content' => "每天早上醒來，先跟爸爸、媽媽說「早安」。\n到學校看到老師和同學，也要微笑說「老師早、同學好」。\n一句問候，就能讓大家一天都開心。",
                'objectives' => ['能使用「早安」「您好」等問候語', '能面帶微笑向他人打招呼'],
                'key_points' => ['早安使用時機', '禮貌用語的重要性'],
                'vocab' => [
                    ['term' => '早安', 'meaning' => '早上見面時的問候語', 'example' => '早安，老師！'],
                    ['term' => '禮貌', 'meaning' => '對他人恭敬有禮', 'example' => '我是個有禮貌的好孩子。'],
                ],
            ],
            [
                'code' => 'cl-c-1-1-u2', 'subject' => 'chinese', 'grade' => 1, 'semester' => 'first', 'unit' => 2,
                'title' => '我的家',
                'summary' => '認識家人和家的溫暖。',
                'content' => "家裡有爸爸、媽媽和兄弟姐妹，他們都很愛我。\n我們一起吃飯、一起玩，家是最溫暖的地方。",
                'objectives' => ['認識家人稱謂', '用詞描述家的溫暖'],
                'key_points' => ['家人稱呼', '家的定義'],
                'vocab' => [
                    ['term' => '家人', 'meaning' => '住在一起的親人', 'example' => '我愛我的家人。'],
                ],
            ],

            // 數學 一年級 ===========================
            [
                'code' => 'cl-m-1-1-u1', 'subject' => 'math', 'grade' => 1, 'semester' => 'first', 'unit' => 1,
                'title' => '10 以內的加法',
                'summary' => '學會 10 以內的加法運算。',
                'content' => "把兩堆東西合在一起，就是加法。\n例如：3 顆蘋果加 2 顆蘋果，一共 5 顆。\n我們寫作 3 + 2 = 5。",
                'objectives' => ['理解加法的意義', '能計算 10 以內的加法'],
                'key_points' => ['加號「+」', '從小數字開始練習'],
                'vocab' => [
                    ['term' => '加法', 'meaning' => '把數量合起來', 'example' => '2 + 3 = 5'],
                ],
            ],
            [
                'code' => 'cl-m-1-1-u2', 'subject' => 'math', 'grade' => 1, 'semester' => 'first', 'unit' => 2,
                'title' => '10 以內的減法',
                'summary' => '學會 10 以內的減法運算。',
                'content' => "從一堆東西拿走一些，就是減法。\n例如：有 7 顆糖，吃掉 3 顆，還剩下 4 顆。\n我們寫作 7 - 3 = 4。",
                'objectives' => ['理解減法的意義', '能計算 10 以內的減法'],
                'key_points' => ['減號「−」', '減法是加法的相反'],
                'vocab' => [
                    ['term' => '減法', 'meaning' => '從數量中拿走一部分', 'example' => '5 − 2 = 3'],
                ],
            ],

            // 數學 二年級 ===========================
            [
                'code' => 'cl-m-2-1-u1', 'subject' => 'math', 'grade' => 2, 'semester' => 'first', 'unit' => 1,
                'title' => '進位加法',
                'summary' => '學會兩位數的進位加法。',
                'content' => "個位相加超過 10 時，要進位到十位。\n例如：17 + 25，個位 7 + 5 = 12，寫 2 進 1；十位 1 + 2 + 1 = 4。\n所以 17 + 25 = 42。",
                'objectives' => ['理解進位的概念', '能正確做兩位數進位加法'],
                'key_points' => ['個位、十位', '進位符號'],
                'vocab' => [
                    ['term' => '進位', 'meaning' => '超過 10 時往高位加 1', 'example' => '8 + 5 = 13，要進位。'],
                ],
            ],

            // 英語 一年級 ===========================
            [
                'code' => 'cl-e-1-1-u1', 'subject' => 'english', 'grade' => 1, 'semester' => 'first', 'unit' => 1,
                'title' => 'ABC Song',
                'summary' => '認識英文 26 個字母。',
                'content' => "英文有 26 個字母，從 A 到 Z。\n我們先學 A, B, C, D, E，每天跟著老師念。\n字母就像國字的部首，是所有單字的基礎。",
                'objectives' => ['認識 26 個字母', '能唱 ABC 歌'],
                'key_points' => ['大小寫字母', '字母順序'],
                'vocab' => [
                    ['term' => 'A a', 'meaning' => '字母 A', 'example' => 'Apple'],
                    ['term' => 'B b', 'meaning' => '字母 B', 'example' => 'Banana'],
                ],
            ],

            // 自然 一年級：改由 ScienceG1CurriculumSeeder 與 Flutter science_g1_lessons 同步

            // 社會 一年級 ===========================
            [
                'code' => 'cl-so-1-1-u1', 'subject' => 'social', 'grade' => 1, 'semester' => 'first', 'unit' => 1,
                'title' => '我的學校',
                'summary' => '認識自己的學校和老師。',
                'content' => "學校是我們學習的地方。\n學校有校長、老師、同學。\n我們要愛護學校的環境，跟同學好好相處。",
                'objectives' => ['認識學校成員', '學會尊重校園環境'],
                'key_points' => ['學校規則', '尊重他人'],
                'vocab' => [
                    ['term' => '校長', 'meaning' => '學校裡最大的領導者', 'example' => '校長很慈祥。'],
                ],
            ],
        ];

        foreach ($lessons as $i => $data) {
            $subject = Subject::where('code', $data['subject'])->firstOrFail();
            $lesson = Lesson::updateOrCreate(
                ['code' => $data['code']],
                [
                    'subject_id' => $subject->id,
                    'grade' => $data['grade'],
                    'semester' => $data['semester'],
                    'unit' => $data['unit'],
                    'track' => 'core',
                    'title' => $data['title'],
                    'summary' => $data['summary'],
                    'content' => $data['content'],
                    'objectives' => $data['objectives'],
                    'key_points' => $data['key_points'],
                    'estimated_minutes' => 12,
                    'is_published' => true,
                    'is_premium' => false,
                    'sort' => $i,
                ]
            );
            // Replace vocab
            $lesson->vocabularyItems()->delete();
            foreach ($data['vocab'] as $vi => $v) {
                VocabularyItem::create([
                    'lesson_id' => $lesson->id,
                    'term' => $v['term'],
                    'meaning' => $v['meaning'],
                    'example' => $v['example'] ?? null,
                    'sort' => $vi,
                ]);
            }
        }
    }
}
