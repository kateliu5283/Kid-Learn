<?php

use App\Http\Controllers\TeacherJoinController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/join-teaching/{token}', TeacherJoinController::class)
    ->name('join-teaching');
