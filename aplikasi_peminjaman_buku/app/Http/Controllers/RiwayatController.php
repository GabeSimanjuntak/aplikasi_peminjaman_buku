<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;

class RiwayatController extends Controller
{
    // GET semua riwayat
    public function index()
    {
        $data = DB::table('view_riwayat_peminjaman')->get();

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    // GET riwayat berdasarkan user tertentu
    public function showByUser($id_user)
    {
        $data = DB::table('view_riwayat_peminjaman')
            ->where('id_user', $id_user)
            ->get();

        if ($data->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Riwayat tidak ditemukan untuk user ini'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }
}
