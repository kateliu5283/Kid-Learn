<?php

use App\Http\Controllers\Api\V1\Content\CurriculumController;
use App\Http\Controllers\Api\V1\Learning\LearningRecordController;
use App\Http\Controllers\Api\V1\ModuleStatusController;
use App\Http\Controllers\Api\V1\User\AuthController;
use App\Http\Controllers\Api\V1\User\StudentController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Gateway（Laravel）— /api/v1
|--------------------------------------------------------------------------
| 依業務模組分區（與 docs/ARCHITECTURE.md 一致）：
|   content   — 題庫／課程（核心）
|   user      — 使用者（預留）
|   learning  — 學習紀錄（App POST /learning/records、GET /learning/progress；家長 token）
|   missions  — 任務（預留）
|   analytics — 分析（預留）
|
| 舊路徑（/api/v1/subjects 等）仍暫時轉發至 Content，方便既有工具相容。
*/

Route::prefix('v1')->group(function () {
    Route::middleware('throttle:60,1')->group(function () {
        Route::get('ping', fn () => response()->json(['status' => 'ok', 'time' => now()->toIso8601String()]));
    });

    // —— Content（題庫系統）⭐ — 公開讀取，嚴格限流防刮題／DoS ——
    Route::middleware('throttle:120,1')->prefix('content')->group(function () {
        Route::get('subjects', [CurriculumController::class, 'subjects']);
        Route::get('lessons', [CurriculumController::class, 'lessons']);
        Route::get('lessons/{code}', [CurriculumController::class, 'lesson']);
        Route::get('questions', [CurriculumController::class, 'questions']);
        Route::get('snapshot', [CurriculumController::class, 'snapshot']);
    });

    // —— User（App 家長帳號）——
    Route::middleware('throttle:12,1')->group(function () {
        Route::post('user/register', [AuthController::class, 'register']);
        Route::post('user/login', [AuthController::class, 'login']);
    });
    Route::post('user/forgot-password', [AuthController::class, 'forgotPassword'])
        ->middleware('throttle:6,1');
    Route::middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
        Route::post('user/logout', [AuthController::class, 'logout']);
        Route::get('user/me', [AuthController::class, 'me']);
        Route::post('user/email/resend', [AuthController::class, 'resendVerification'])
            ->middleware('throttle:6,1');
        Route::get('user/export', [AuthController::class, 'exportData']);
        Route::delete('user/account', [AuthController::class, 'destroyAccount'])
            ->middleware('throttle:6,1');
        Route::get('user/students', [StudentController::class, 'index']);
        Route::post('user/students', [StudentController::class, 'store']);
        Route::put('user/students/{student}', [StudentController::class, 'update']);
        Route::post('user/students/{student}/teacher-invite', [StudentController::class, 'teacherInvite'])
            ->middleware('parent.verified');
        Route::delete('user/students/{student}', [StudentController::class, 'destroy']);
        Route::post('learning/records', [LearningRecordController::class, 'store'])
            ->middleware('parent.verified');
        Route::get('learning/progress', [LearningRecordController::class, 'progress'])
            ->middleware('parent.verified');
    });

    // —— 其餘模組（預留）——
    Route::middleware('throttle:60,1')->group(function () {
        Route::get('user/status', [ModuleStatusController::class, 'user']);
        Route::get('learning/status', [ModuleStatusController::class, 'learning']);
        Route::get('missions/status', [ModuleStatusController::class, 'missions']);
        Route::get('analytics/status', [ModuleStatusController::class, 'analytics']);
    });

    // —— Legacy：舊版路徑（請改走 /content/*）——
    Route::middleware('throttle:120,1')->group(function () {
        Route::get('subjects', [CurriculumController::class, 'subjects']);
        Route::get('lessons', [CurriculumController::class, 'lessons']);
        Route::get('lessons/{code}', [CurriculumController::class, 'lesson']);
        Route::get('questions', [CurriculumController::class, 'questions']);
        Route::get('snapshot', [CurriculumController::class, 'snapshot']);
    });
});
