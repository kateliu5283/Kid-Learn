<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('student_learning_records', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained('students')->cascadeOnDelete();
            $table->string('activity_type', 64);
            $table->string('context_key', 120)->nullable();
            $table->string('title', 255)->nullable();
            $table->unsignedInteger('correct_count');
            $table->unsignedInteger('question_count');
            $table->unsignedTinyInteger('score_percent')->nullable();
            $table->unsignedInteger('duration_seconds')->nullable();
            $table->json('meta')->nullable();
            $table->string('client_submission_id', 64)->nullable();
            $table->timestamp('recorded_at')->useCurrent();
            $table->timestamps();

            $table->index(['student_id', 'recorded_at']);
            $table->index(['activity_type', 'recorded_at']);
            $table->unique(['student_id', 'client_submission_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('student_learning_records');
    }
};
