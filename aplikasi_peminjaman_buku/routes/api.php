<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BukuController;
use App\Http\Controllers\KategoriBukuController;
use App\Http\Controllers\PeminjamanController;
use App\Http\Controllers\PengembalianController;
use App\Http\Controllers\RiwayatController;
use App\Http\Controllers\AuthController;


// =====================================================
// PUBLIC ROUTES (TIDAK PERLU LOGIN)
// User dan Guest bebas baca buku dan detail buku
// =====================================================

Route::get('/test', fn() => response()->json(['message' => 'API Ready']));

// Auth
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Forgot Password (OTP)
Route::post('/forgot-password', [AuthController::class, 'sendOtp']);
Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);

// Buku (Public)
Route::get('/buku', [BukuController::class, 'index']);
Route::get('/buku/{id}', [BukuController::class, 'show']);
Route::get('/buku-serupa/{id}', [BukuController::class, 'bukuSerupa']);


// =====================================================
// USER ROUTES (LOGIN + ROLE USER)
// =====================================================

Route::middleware(['auth:sanctum', 'isUser'])->group(function () {

    // Profile user
    Route::get('/profile/{id}', [AuthController::class, 'profile']);
    Route::post('/profile/update', [AuthController::class, 'updateProfile']);

    // Peminjaman buku
    Route::post('/peminjaman', [PeminjamanController::class, 'store']);

    // Riwayat peminjaman user
    Route::get('/riwayat/user/{id_user}', [RiwayatController::class, 'showByUser']);
});


// =====================================================
// ADMIN ROUTES (LOGIN + ROLE ADMIN)
// CRUD Buku hanya Admin yang boleh
// =====================================================

Route::middleware(['auth:sanctum', 'isAdmin'])->group(function () {

    // CRUD Buku
    Route::post('/buku', [BukuController::class, 'store']);
    Route::put('/buku/{id}', [BukuController::class, 'update']);
    Route::delete('/buku/{id}', [BukuController::class, 'destroy']);

    // CRUD Kategori
    Route::get('/kategori', [KategoriBukuController::class, 'index']);
    Route::get('/kategori/{id}', [KategoriBukuController::class, 'show']);
    Route::post('/kategori', [KategoriBukuController::class, 'store']);
    Route::put('/kategori/{id}', [KategoriBukuController::class, 'update']);
    Route::delete('/kategori/{id}', [KategoriBukuController::class, 'destroy']);

    // Pengembalian buku
    Route::post('/pengembalian', [PengembalianController::class, 'store']);
    Route::get('/pengembalian', [PengembalianController::class, 'index']);

    // Peminjaman approval
    Route::get('/peminjaman', [PeminjamanController::class, 'index']);
    Route::post('/peminjaman/{id}/konfirmasi', [PeminjamanController::class, 'konfirmasi']);
    Route::put('/peminjaman/{id}/pengembalian', [PeminjamanController::class, 'pengembalian']);

    // Semua riwayat
    Route::get('/riwayat', [RiwayatController::class, 'index']);
});


// =====================================================
// LOGOUT (User atau Admin)
// =====================================================

Route::middleware('auth:sanctum')->post('/logout', [AuthController::class, 'logout']);
