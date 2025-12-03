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
        $data = Peminjaman::join('buku', 'peminjaman.id_buku', '=', 'buku.id')
            ->join('users', 'peminjaman.id_user', '=', 'users.id')
            ->select(
                'peminjaman.id as id_peminjaman',
                'buku.judul as judul_buku',
                'users.nama as nama_user',
                'peminjaman.tanggal_pinjam',
                'peminjaman.tanggal_jatuh_tempo',
                'peminjaman.status_pinjam'
            )
            ->get();

        return response()->json([
            "success" => true,
            "data" => $data
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

    // APPROVE oleh admin
    public function approve($id)
    {
        $p = Peminjaman::find($id);

        if (!$p) {
            return response()->json(['success' => false, 'message' => 'Data tidak ditemukan']);
        }

        $p->status_pinjam = 'aktif';
        $p->tanggal_pinjam = now();
        $p->save();

        return response()->json(['success' => true, 'message' => 'Peminjaman disetujui']);
    }


}
