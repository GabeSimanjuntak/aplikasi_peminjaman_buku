<?php

namespace App\Http\Controllers;

use App\Models\Peminjaman;
use App\Models\Buku;
use App\Models\User;
use Illuminate\Http\Request;

class PeminjamanController extends Controller
{
    // ============================================================
    // GET LIST PEMINJAMAN (ADMIN)
    // ============================================================
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
            ->orderBy('peminjaman.id', 'DESC')
            ->get();

        return response()->json([
            "success" => true,
            "data" => $data
        ]);
    }

    // ============================================================
    // USER → REQUEST PEMINJAMAN
    // ============================================================
    public function store(Request $request)
    {
        $request->validate([
            'id_user' => 'required|exists:users,id',
            'id_buku' => 'required|exists:buku,id',
        ]);

        $user = User::find($request->id_user);
        if ($user->role_id == 1) {
            return response()->json([
                'success' => false,
                'message' => 'Admin tidak boleh meminjam buku'
            ], 403);
        }

        $buku = Buku::find($request->id_buku);

        if ($buku->stok_tersedia <= 0) {
            return response()->json([
                'success' => false,
                'message' => 'Stok buku habis'
            ], 400);
        }

        // Cek apakah user sudah punya request pending atau aktif
        $cekDuplikat = Peminjaman::where('id_user', $request->id_user)
            ->where('id_buku', $request->id_buku)
            ->whereIn('status_pinjam', ['pending', 'aktif'])
            ->first();

        if ($cekDuplikat) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah meminjam / sedang menunggu persetujuan untuk buku ini'
            ], 400);
        }

        $tanggalPinjam = now()->toDateString();
        $tanggalTempo = now()->addDays(7)->toDateString();

        $peminjaman = Peminjaman::create([
            'id_user' => $request->id_user,
            'id_buku' => $request->id_buku,
            'tanggal_pinjam' => $tanggalPinjam,
            'tanggal_jatuh_tempo' => $tanggalTempo,
            'status_pinjam' => 'pending'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Peminjaman menunggu persetujuan admin',
            'data' => $peminjaman
        ]);
    }

    // ============================================================
    // ADMIN → APPROVE PEMINJAMAN
    // ============================================================
public function konfirmasi($id)
{
    $p = Peminjaman::find($id);

    if (!$p) {
        return response()->json([
            "success" => false,
            "message" => "Peminjaman tidak ditemukan"
        ], 404);
    }

    if ($p->status_pinjam !== 'pending') {
        return response()->json([
            "success" => false,
            "message" => "Peminjaman ini sudah diproses"
        ], 400);
    }

    $buku = Buku::find($p->id_buku);

    if ($buku->stok_tersedia <= 0) {
        return response()->json([
            "success" => false,
            "message" => "Stok buku tidak mencukupi"
        ], 400);
    }

    // =======================
    // FIX PALING PENTING INI !!
    // =======================
    $p->id_admin = auth()->id();  // ← WAJIB!!
    $p->status_pinjam = 'aktif';
    $p->tanggal_pinjam = now()->toDateString();
    $p->save();

    // Kurangi stok
    $buku->stok_tersedia -= 1;
    $buku->status = $buku->stok_tersedia == 0 ? 'dipinjam' : 'tersedia';
    $buku->save();

    return response()->json([
        "success" => true,
        "message" => "Peminjaman berhasil disetujui",
        "data" => $p
    ]);
}

    // ============================================================
    // ADMIN → TOLAK PEMINJAMAN
    // ============================================================
    public function reject($id)
    {
        $p = Peminjaman::find($id);

        if (!$p) {
            return response()->json([
                'success' => false,
                'message' => 'Peminjaman tidak ditemukan'
            ], 404);
        }

        if ($p->status_pinjam !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Peminjaman ini tidak dapat ditolak'
            ], 400);
        }

        $p->status_pinjam = 'ditolak';
        $p->save();

        return response()->json([
            'success' => true,
            'message' => 'Peminjaman berhasil ditolak'
        ]);
    }

    // ============================================================
    // ADMIN → SET PENGEMBALIAN
    // ============================================================
    public function pengembalian($id)
    {
        $p = Peminjaman::find($id);

        if (!$p) {
            return response()->json([
                'success' => false,
                'message' => 'Data tidak ditemukan'
            ], 404);
        }

        if ($p->status_pinjam !== 'aktif') {
            return response()->json([
                'success' => false,
                'message' => 'Peminjaman belum aktif atau sudah dikembalikan'
            ], 400);
        }

        $buku = Buku::find($p->id_buku);

        // Update status
        $p->status_pinjam = 'selesai';
        $p->tanggal_jatuh_tempo = now()->toDateString();
        $p->save();

        // Tambah stok
        $buku->stok_tersedia += 1;
        $buku->status = 'tersedia';
        $buku->save();

        return response()->json([
            'success' => true,
            'message' => 'Pengembalian berhasil diproses'
        ]);
    }
}
