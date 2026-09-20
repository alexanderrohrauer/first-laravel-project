<?php

use App\Http\Controllers\Files\FilesController;
use Illuminate\Support\Facades\Route;

Route::inertia('/', 'Welcome')->name('home');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::inertia('dashboard', 'Dashboard')->name('dashboard');

    Route::prefix("files")->group(function () {
        Route::post('upload', [FilesController::class, 'uploadFile'])->name('files.upload');
    });
});

require __DIR__.'/settings.php';
