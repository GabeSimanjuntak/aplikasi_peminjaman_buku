<?php

namespace App\Http\Controllers;

use App\Models\Peminjaman;
use App\Models\Buku;
use Illuminate\Http\Request;

class PeminjamanController extends Controller
{
    // GET semua peminjaman
    public function index()
    {
        $data = Peminjaman::with(['buku', 'user'])->get();

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    // POST peminjaman (pinjam buku)
    public function store(Request $request)
    {
        $request->validate([
            'id_user' => 'required|exists:users,id',
            'id_buku' => 'required|exists:buku,id',
            'tanggal_jatuh_tempo' => 'required|date|after_or_equal:today'
        ]);

        // ===== CEGAH ADMIN MINJAM BUKU =====
        $user = \App\Models\User::find($request->id_user);
        if ($user->role_id == 1) { // role 1 = admin
            return response()->json([
                'success' => false,
                'message' => 'Admin tidak diperbolehkan meminjam buku'
            ], 403);
        }
        // ===================================

        // Cek apakah buku sedang dipinjam
        $buku = Buku::find($request->id_buku);
        if ($buku->status === 'dipinjam') {
            return response()->json([
                'success' => false,
                'message' => 'Buku sedang dipinjam orang lain'
            ], 400);
        }

        // Cek apakah user masih punya pinjaman aktif untuk buku ini
        $cekPeminjaman = Peminjaman::where('id_user', $request->id_user)
            ->where('id_buku', $request->id_buku)
            ->where('status_pinjam', 'aktif')
            ->first();

        if ($cekPeminjaman) {
            return response()->json([
                'success' => false,
                'message' => 'Anda masih meminjam buku ini'
            ], 400);
        }

        // Simpan peminjaman
        $pinjam = Peminjaman::create([
            'id_user' => $request->id_user,
            'id_buku' => $request->id_buku,
            'tanggal_pinjam' => date('Y-m-d'),
            'tanggal_jatuh_tempo' => $request->tanggal_jatuh_tempo,
            'status_pinjam' => 'aktif'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Buku berhasil dipinjam',
            'data' => $pinjam
        ]);
    }

    // GET detail peminjaman
    public function show($id)
    {
        $data = Peminjaman::with(['buku', 'user'])->find($id);

        if (!$data) {
            return response()->json([
                'success' => false,
                'message' => 'Data peminjaman tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }
}
