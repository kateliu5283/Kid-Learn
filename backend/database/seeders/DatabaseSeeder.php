<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 後台帳號（依 role 進入 /admin、/teacher、/parent）
        User::updateOrCreate(
            ['email' => 'admin@kidlearn.local'],
            [
                'name' => '系統管理員',
                'password' => Hash::make('password'),
                'role' => User::ROLE_ADMIN,
            ]
        );
        User::updateOrCreate(
            ['email' => 'teacher@kidlearn.local'],
            [
                'name' => '示範教師',
                'password' => Hash::make('password'),
                'role' => User::ROLE_TEACHER,
            ]
        );
        User::updateOrCreate(
            ['email' => 'parent@kidlearn.local'],
            [
                'name' => '示範家長',
                'password' => Hash::make('password'),
                'role' => User::ROLE_PARENT,
            ]
        );

        $this->call([
            SubjectSeeder::class,
            LessonSeeder::class,
            ScienceG1CurriculumSeeder::class,
            QuestionBankSeeder::class,
        ]);
    }
}
