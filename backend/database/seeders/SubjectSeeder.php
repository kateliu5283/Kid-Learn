<?php

namespace Database\Seeders;

use App\Models\Subject;
use Illuminate\Database\Seeder;

class SubjectSeeder extends Seeder
{
    public function run(): void
    {
        $subjects = [
            ['code' => 'chinese', 'name' => '國語', 'english_name' => 'Chinese', 'icon' => 'menu_book',    'color' => '#E57373', 'sort' => 1, 'description' => '認字、閱讀與表達。'],
            ['code' => 'math',    'name' => '數學', 'english_name' => 'Math',    'icon' => 'calculate',    'color' => '#64B5F6', 'sort' => 2, 'description' => '運算與解題思考。'],
            ['code' => 'english', 'name' => '英語', 'english_name' => 'English', 'icon' => 'translate',    'color' => '#81C784', 'sort' => 3, 'description' => '字母、單字與句型。'],
            ['code' => 'science', 'name' => '自然', 'english_name' => 'Science', 'icon' => 'science',      'color' => '#FFB74D', 'sort' => 4, 'description' => '生活中的科學現象。'],
            ['code' => 'social',  'name' => '社會', 'english_name' => 'Social',  'icon' => 'public',       'color' => '#BA68C8', 'sort' => 5, 'description' => '認識環境與文化。'],
            ['code' => 'life',    'name' => '生活', 'english_name' => 'Life',    'icon' => 'favorite',     'color' => '#4DD0E1', 'sort' => 6, 'description' => '品格、生活自理與安全。'],
        ];

        foreach ($subjects as $s) {
            Subject::updateOrCreate(['code' => $s['code']], $s);
        }
    }
}
