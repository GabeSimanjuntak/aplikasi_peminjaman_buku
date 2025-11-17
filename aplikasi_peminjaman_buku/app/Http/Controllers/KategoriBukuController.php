<?php

namespace App\Http\Controllers;

use App\Models\KategoriBuku;
use Illuminate\Http\Request;

class KategoriBukuController extends Controller
{
    // GET semua kategori
    public function index()
    {
        return response()->json([
            'success' => true,
            'data' => KategoriBuku::all()
        ]);
    }

    // GET detail kategori
    public function show($id)
    {
        $kategori = KategoriBuku::find($id);

        if (!$kategori) {
            return response()->json([
                'success' => false,
                'message' => 'Kategori tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $kategori
        ]);
    }

    // POST tambah kategori
    public function store(Request $request)
    {
        $request->validate([
            'nama_kategori' => 'required|string|max:100'
        ]);

        $kategori = KategoriBuku::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Kategori berhasil ditambahkan',
            'data' => $kategori
        ], 201);
    }

    // PUT update kategori
    public function update(Request $request, $id)
    {
        $kategori = KategoriBuku::find($id);

        if (!$kategori) {
            return response()->json([
                'success' => false,
                'message' => 'Kategori tidak ditemukan'
            ], 404);
        }

        $kategori->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Kategori berhasil diperbarui',
            'data' => $kategori
        ]);
    }

    // DELETE kategori
    public function destroy($id)
    {
        $kategori = KategoriBuku::find($id);

        if (!$kategori) {
            return response()->json([
                'success' => false,
                'message' => 'Kategori tidak ditemukan'
            ], 404);
        }

        // Hapus kategori
        $kategori->delete();

        // RESET sequence ID agar mengikuti MAX(id) terbaru
        \DB::statement("
            SELECT setval('kategori_buku_id_seq', COALESCE((SELECT MAX(id) FROM kategori_buku), 1), false);
        ");

        return response()->json([
            'success' => true,
            'message' => 'Kategori berhasil dihapus'
        ]);
    }
}
