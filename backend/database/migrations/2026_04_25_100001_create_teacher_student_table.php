<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('teacher_student', function (Blueprint $table) {
            $table->id();
            $table->foreignId('teacher_user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('student_id')->constrained('students')->cascadeOnDelete();
            $table->string('note', 255)->nullable();
            $table->timestamps();

            $table->unique(['teacher_user_id', 'student_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('teacher_student');
    }
};
