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

        $pinjam = Peminjaman::find($request->id_peminjaman);

        if ($pinjam->status_pinjam !== 'aktif') {
            return response()->json([
                'success' => false,
                'message' => 'Peminjaman sudah selesai atau tidak aktif'
            ], 400);
        }

        // Cek keterlambatan
        $tanggalSekarang = date('Y-m-d');
        $statusKembali = ($tanggalSekarang > $pinjam->tanggal_jatuh_tempo) ? 'terlambat' : 'tepat waktu';

        // Simpan pengembalian
        $kembali = Pengembalian::create([
            'id_peminjaman' => $request->id_peminjaman,
            'tanggal_kembali' => $tanggalSekarang,
            'status_pengembalian' => $statusKembali
        ]);

        // Update status peminjaman menjadi selesai
        $pinjam->status_pinjam = 'selesai';
        $pinjam->save();

        // Update status buku menjadi tersedia
        $buku = $pinjam->buku;
        $buku->status = 'tersedia';
        $buku->save();

        return response()->json([
            'success' => true,
            'message' => 'Buku berhasil dikembalikan',
            'data' => $kembali
        ]);
    }

    public function index()
    {
        $data = Peminjaman::with(['buku', 'user'])
            ->where('status_pinjam', 'selesai')
            ->orderBy('tanggal_kembali', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

}
