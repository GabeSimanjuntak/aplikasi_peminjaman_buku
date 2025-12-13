<?php

namespace App\Http\Controllers;

use App\Models\Pengembalian;
use App\Models\Peminjaman;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;     // ✔ WAJIB ADA JIKA MEMAKAI CARBON
use App\Models\Buku;

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

    //     public function approve($id)
    // {
    //     $p = Peminjaman::findOrFail($id);

    //     if ($p->status_pinjam !== 'pengajuan_kembali') {
    //         return response()->json([
    //             'success' => false,
    //             'message' => 'Bukan pengajuan pengembalian'
    //         ], 400);
    //     }

    //     $tanggalKembali = Carbon::now();
    //     $jatuhTempo = Carbon::parse($p->tanggal_jatuh_tempo);

    //     // update peminjaman
    //     $p->status_pinjam = 'dikembalikan';
    //     $p->tanggal_kembali = $tanggalKembali;
    //     $p->save();

    //     // update stok buku
    //     $buku = Buku::find($p->id_buku);
    //     $buku->stok_tersedia += 1;
    //     $buku->save();

    //     return response()->json([
    //         'success' => true,
    //         'message' => 'Pengembalian disetujui'
    //     ]);
    // }

    // ✅ HISTORY ADMIN
    public function history()
    {
        return response()->json([
            'success' => true,
            'data' => Peminjaman::where('status_pinjam', 'dikembalikan')
                ->orderByDesc('tanggal_kembali')
                ->get()
        ]);
    }



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

        $p->status_pinjam = 'dikembalikan';
        $p->tanggal_pengembalian_dipilih = now()->toDateString();
        $p->save();

        Pengembalian::create([
            'id_peminjaman' => $p->id,
            'tanggal_kembali' => now()->toDateString(), // kolom pengembalian
            'status_pengembalian' => 'dikembalikan'
        ]);


        // update stok buku
        $buku = Buku::find($p->id_buku);
        if ($buku) {
            $buku->stok_tersedia = min($buku->stok_tersedia + 1, $buku->stok);
            $buku->save();
        }


        return response()->json([
            'success' => true,
            'message' => 'Pengembalian disetujui'
        ]);
    }

}
