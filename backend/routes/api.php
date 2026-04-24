<?php

use App\Http\Controllers\Api\CurriculumController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::get('ping', fn() => response()->json(['status' => 'ok', 'time' => now()->toIso8601String()]));

    Route::get('subjects', [CurriculumController::class, 'subjects']);
    Route::get('lessons', [CurriculumController::class, 'lessons']);
    Route::get('lessons/{code}', [CurriculumController::class, 'lesson']);
    Route::get('questions', [CurriculumController::class, 'questions']);
    Route::get('snapshot', [CurriculumController::class, 'snapshot']);
});
