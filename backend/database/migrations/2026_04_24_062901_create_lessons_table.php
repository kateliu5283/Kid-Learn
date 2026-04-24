<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('lessons', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique()->comment('e.g. cl-c-1-1-u1');
            $table->foreignId('subject_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('grade')->comment('1-6');
            $table->enum('semester', ['first', 'second'])->nullable();
            $table->unsignedTinyInteger('unit')->nullable();
            $table->enum('track', ['core', 'extended', 'general'])->default('core');
            $table->string('title');
            $table->string('summary', 500)->nullable();
            $table->longText('content')->nullable();
            $table->unsignedInteger('estimated_minutes')->default(10);
            $table->json('objectives')->nullable()->comment('List of 學習目標');
            $table->json('key_points')->nullable()->comment('List of 重點');
            $table->boolean('is_published')->default(true);
            $table->boolean('is_premium')->default(false)->comment('付費版本才可讀');
            $table->unsignedInteger('sort')->default(0);
            $table->timestamps();

            $table->index(['subject_id', 'grade', 'semester']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('lessons');
    }
};
