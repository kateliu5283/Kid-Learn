<?php

use App\Http\Controllers\EmailVerificationController;
use App\Http\Controllers\ParentEmailNoticeController;
use App\Http\Controllers\PasswordResetController;
use App\Http\Controllers\TeacherJoinController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/join-teaching/{token}', TeacherJoinController::class)
    ->middleware('throttle:20,1')
    ->where('token', '[A-Za-z0-9]{48}')
    ->name('join-teaching');

Route::get('/password/reset/{token}', [PasswordResetController::class, 'show'])
    ->middleware('throttle:20,1')
    ->where('token', '[A-Za-z0-9]+')
    ->name('password.reset');
Route::post('/password/reset', [PasswordResetController::class, 'store'])
    ->middleware('throttle:10,1')
    ->name('password.update');

Route::get('/email/verify/{id}/{hash}', EmailVerificationController::class)
    ->middleware(['signed', 'throttle:6,1'])
    ->name('verification.verify');

Route::get('/email/unverified', [ParentEmailNoticeController::class, 'show'])
    ->name('parent.email.notice');
Route::post('/email/unverified/resend', [ParentEmailNoticeController::class, 'resend'])
    ->middleware('throttle:6,1')
    ->name('parent.email.resend');
Route::post('/email/unverified/logout', [ParentEmailNoticeController::class, 'logout'])
    ->name('parent.email.logout');
