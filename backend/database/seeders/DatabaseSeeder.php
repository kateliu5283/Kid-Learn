<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Admin 帳號 (Filament)
        User::updateOrCreate(
            ['email' => 'admin@kidlearn.local'],
            [
                'name' => '系統管理員',
                'password' => Hash::make('password'),
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
