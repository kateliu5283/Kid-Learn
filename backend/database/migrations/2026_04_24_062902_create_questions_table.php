<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('questions', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique()->comment('e.g. q-math-1-001');
            $table->foreignId('subject_id')->constrained()->cascadeOnDelete();
            $table->foreignId('lesson_id')->nullable()->constrained()->nullOnDelete()->comment('若綁定特定課程則填入');
            $table->unsignedTinyInteger('grade')->comment('1-6');
            $table->enum('type', ['multiple_choice', 'true_false', 'fill_blank'])->default('multiple_choice');
            $table->enum('difficulty', ['easy', 'normal', 'hard'])->default('normal');
            $table->text('prompt');
            $table->json('options')->comment('List of 選項');
            $table->unsignedTinyInteger('correct_index')->default(0);
            $table->text('explanation')->nullable();
            $table->string('image_url')->nullable();
            $table->json('tags')->nullable();
            $table->boolean('is_published')->default(true);
            $table->boolean('is_premium')->default(false)->comment('付費題目');
            $table->unsignedInteger('sort')->default(0);
            $table->timestamps();

            $table->index(['subject_id', 'grade', 'is_published']);
            $table->index(['lesson_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('questions');
    }
};
