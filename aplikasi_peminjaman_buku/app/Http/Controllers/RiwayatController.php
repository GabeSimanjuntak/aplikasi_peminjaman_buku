<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class RiwayatController extends Controller
{
    // =========================================
    // ADMIN - SEMUA RIWAYAT
    // =========================================
    public function index()
{
    $today = Carbon::today();

    $data = DB::table('peminjaman AS p')
        ->leftJoin('pengembalian AS pg', 'p.id', '=', 'pg.id_peminjaman')
        ->leftJoin('users AS u', 'p.id_user', '=', 'u.id')
        ->leftJoin('buku AS b', 'p.id_buku', '=', 'b.id')
        ->where('p.status_pinjam', 'dikembalikan')
        ->whereDate('p.tanggal_pengembalian_dipilih', '<=', $today)
        ->orderBy('pg.tanggal_kembali', 'DESC')
        ->select(
            'p.id AS id_peminjaman',
            'u.nama AS nama_user',
            'b.judul AS judul_buku',
            'p.tanggal_pinjam',
            'p.tanggal_jatuh_tempo',
            'pg.tanggal_kembali',
            'p.status_pinjam'
        )
        ->get();

    return response()->json([
        'success' => true,
        'data' => $data
    ]);
}




    // =========================================
    // USER - RIWAYAT BERDASARKAN USER
    // =========================================
    public function showByUser($id_user)
    {
        $data = DB::table('view_riwayat_peminjaman')
            ->where('id_user', $id_user)
            ->orderBy('id_peminjaman', 'DESC')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }
}
