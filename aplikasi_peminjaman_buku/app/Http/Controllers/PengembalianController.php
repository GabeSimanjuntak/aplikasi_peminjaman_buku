<?php

namespace App\Http\Controllers;

use App\Models\Pengembalian;
use App\Models\Peminjaman;
use Illuminate\Http\Request;

class PengembalianController extends Controller
{
    // POST pengembalian buku
    public function store(Request $request)
    {
        $request->validate([
            'id_peminjaman' => 'required|exists:peminjaman,id'
        ]);

        // Ambil data peminjaman
        $pinjam = Peminjaman::find($request->id_peminjaman);

        if ($pinjam->status_pinjam !== 'aktif') {
            return response()->json([
                'success' => false,
                'message' => 'Peminjaman sudah selesai atau tidak aktif'
            ], 400);
        }

        // Simpan pengembalian
        $kembali = Pengembalian::create([
            'id_peminjaman' => $request->id_peminjaman,
            'tanggal_kembali' => date('Y-m-d')
        ]);

        // Trigger otomatis mengubah:
        // - status buku -> tersedia
        // - status peminjaman -> selesai

        return response()->json([
            'success' => true,
            'message' => 'Buku berhasil dikembalikan',
            'data' => $kembali
        ]);
    }
}
