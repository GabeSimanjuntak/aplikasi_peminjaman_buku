<?php

namespace App\Http\Controllers;

use App\Models\Pengembalian;
use App\Models\Peminjaman;
use Illuminate\Http\Request;
use Carbon\Carbon;
use App\Models\Buku;

class PengembalianController extends Controller
{
    // =========================
    // USER AJUKAN PENGEMBALIAN
    // =========================
    public function store(Request $request)
    {
        $request->validate([
            'id_peminjaman' => 'required|exists:peminjaman,id'
        ]);

        $pinjam = Peminjaman::find($request->id_peminjaman);

        if ($pinjam->status_pinjam !== 'dipinjam') {
            return response()->json([
                'success' => false,
                'message' => 'Peminjaman tidak dalam status dipinjam'
            ], 400);
        }

        // user mengajukan pengembalian
        $pinjam->status_pinjam = 'pengajuan_kembali';
        $pinjam->save();

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan pengembalian berhasil'
        ]);
    }

    // =========================
    // LIST HISTORY PENGEMBALIAN (ADMIN)
    // =========================
    public function index()
    {
        $data = Peminjaman::with(['buku', 'user'])
            ->where('status_pinjam', 'dikembalikan')
            ->orderByDesc('tanggal_pengembalian_dipilih') // ✅ kolom VALID
            ->get();

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    // =========================
    // APPROVE PENGEMBALIAN (ADMIN)
    // =========================
    public function approvePengembalian($id)
    {
        $p = Peminjaman::find($id);

        if (!$p) {
            return response()->json([
                'success' => false,
                'message' => 'Data peminjaman tidak ditemukan'
            ], 404);
        }

        if ($p->status_pinjam !== 'pengajuan_kembali') {
            return response()->json([
                'success' => false,
                'message' => 'Belum diajukan pengembalian'
            ], 400);
        }

        // ✅ ADMIN HANYA UBAH STATUS
        $p->status_pinjam = 'dikembalikan';
        $p->save();

        // ✅ SIMPAN DATA REAL KE TABEL PENGEMBALIAN
        Pengembalian::create([
            'id_peminjaman' => $p->id,
            'tanggal_kembali' => $p->tanggal_pengembalian_dipilih, // 🔥 PAKAI TANGGAL USULAN
            'status_pengembalian' => 'dikembalikan'
        ]);

        // ✅ KEMBALIKAN STOK BUKU
        $buku = Buku::find($p->id_buku);
        if ($buku) {
            $buku->stok_tersedia = min(
                $buku->stok_tersedia + 1,
                $buku->stok
            );
            $buku->save();
        }

        return response()->json([
            'success' => true,
            'message' => 'Pengembalian disetujui'
        ]);
    }

    // =========================
    // HISTORY ADMIN (ALTERNATIF)
    // =========================
    public function history()
    {
        return response()->json([
            'success' => true,
            'data' => Peminjaman::where('status_pinjam', 'dikembalikan')
                ->orderByDesc('tanggal_pengembalian_dipilih') // ✅ FIX
                ->get()
        ]);
    }
}
