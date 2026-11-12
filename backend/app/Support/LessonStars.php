<?php

namespace App\Support;

/**
 * 與 Flutter ProgressProvider._calcStars 相同的門檻。
 * 變更時兩邊要一起改。
 */
class LessonStars
{
    public static function fromCounts(int $correct, int $total): int
    {
        if ($total <= 0) {
            return 0;
        }

        $ratio = $correct / $total;
        if ($ratio >= 0.9) {
            return 3;
        }
        if ($ratio >= 0.7) {
            return 2;
        }
        if ($ratio >= 0.5) {
            return 1;
        }

        return 0;
    }
}
