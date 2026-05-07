<?php

namespace App\Support;

use App\Models\StudentLearningRecord;

final class LearningActivityLabels
{
    /** @return array<string, string> */
    public static function options(): array
    {
        return [
            StudentLearningRecord::TYPE_LESSON_QUIZ => self::label(StudentLearningRecord::TYPE_LESSON_QUIZ),
            StudentLearningRecord::TYPE_LESSON_REVIEW => self::label(StudentLearningRecord::TYPE_LESSON_REVIEW),
            StudentLearningRecord::TYPE_DAILY_REVIEW => self::label(StudentLearningRecord::TYPE_DAILY_REVIEW),
            StudentLearningRecord::TYPE_GAME_MATH_BLITZ => self::label(StudentLearningRecord::TYPE_GAME_MATH_BLITZ),
            StudentLearningRecord::TYPE_GAME_MEMORY_MATCH => self::label(StudentLearningRecord::TYPE_GAME_MEMORY_MATCH),
            StudentLearningRecord::TYPE_GAME_WORD_RAIN => self::label(StudentLearningRecord::TYPE_GAME_WORD_RAIN),
        ];
    }

    public static function label(string $type): string
    {
        return match ($type) {
            StudentLearningRecord::TYPE_LESSON_QUIZ => '單元測驗',
            StudentLearningRecord::TYPE_LESSON_REVIEW => '單課複習',
            StudentLearningRecord::TYPE_DAILY_REVIEW => '每日複習',
            StudentLearningRecord::TYPE_GAME_MATH_BLITZ => '數學快閃',
            StudentLearningRecord::TYPE_GAME_MEMORY_MATCH => '記憶翻牌',
            StudentLearningRecord::TYPE_GAME_WORD_RAIN => '單字雨',
            default => $type,
        };
    }
}
