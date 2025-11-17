<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BukuController;
use App\Http\Controllers\KategoriBukuController;
use App\Http\Controllers\PeminjamanController;
use App\Http\Controllers\PengembalianController;
use App\Http\Controllers\RiwayatController;
use App\Http\Controllers\AuthController;

// PUBLIC
Route::get('/test', fn() => response()->json(['message' => 'API Ready']));
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);


// ===========================
// USER ONLY (auth + isUser)
// ===========================
Route::middleware(['auth:sanctum', 'isUser'])->group(function () {

    Route::get('/profile/{id}', [AuthController::class, 'profile']);

    // Peminjaman
    Route::post('/peminjaman', [PeminjamanController::class, 'store']);

    // Riwayat peminjaman user
    Route::get('/riwayat/user/{id_user}', [RiwayatController::class, 'showByUser']);
});


// ===========================
// ADMIN ONLY (auth + isAdmin)
// ===========================
Route::middleware(['auth:sanctum', 'isAdmin'])->group(function () {

    // Buku
    Route::get('/buku', [BukuController::class, 'index']);
    Route::get('/buku/{id}', [BukuController::class, 'show']);
    Route::post('/buku', [BukuController::class, 'store']);
    Route::put('/buku/{id}', [BukuController::class, 'update']);
    Route::delete('/buku/{id}', [BukuController::class, 'destroy']);

    // Kategori
    Route::get('/kategori', [KategoriBukuController::class, 'index']);
    Route::get('/kategori/{id}', [KategoriBukuController::class, 'show']);
    Route::post('/kategori', [KategoriBukuController::class, 'store']);
    Route::put('/kategori/{id}', [KategoriBukuController::class, 'update']);
    Route::delete('/kategori/{id}', [KategoriBukuController::class, 'destroy']);

    // Pengembalian
    Route::post('/pengembalian', [PengembalianController::class, 'store']);

    // Semua riwayat
    Route::get('/riwayat', [RiwayatController::class, 'index']);
});


// LOGOUT
Route::middleware('auth:sanctum')->post('/logout', [AuthController::class, 'logout']);
