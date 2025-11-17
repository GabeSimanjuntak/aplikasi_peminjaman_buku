<?php

namespace App\Http\Controllers;

use App\Models\Buku;
use Illuminate\Http\Request;

class BukuController extends Controller
{
    // GET semua buku
    public function index()
    {
        $buku = Buku::with('kategori')->get();

        return response()->json([
            'success' => true,
            'data' => $buku
        ]);
    }

    // GET detail buku
    public function show($id)
    {
        $buku = Buku::with('kategori')->find(id: $id);

        if (!$buku) {
            return response()->json([
                'success' => false,
                'message' => 'Buku tidak ditemukan'
            ], status: 404);
        }

        return response()->json([
            'success' => true,
            'data' => $buku
        ]);
    }

    // POST tambah buku
    public function store(Request $request)
    {
        $request->validate([
            'judul' => 'required|string|max:150',
            'penulis' => 'nullable|string|max:100',
            'penerbit' => 'nullable|string|max:100',
            'tahun' => 'nullable|string|max:10',
            'deskripsi' => 'nullable|string',
            'id_kategori' => 'nullable|exists:kategori_buku,id',
        ]);

        $buku = Buku::create([
            'judul' => $request->judul,
            'penulis' => $request->penulis,
            'penerbit' => $request->penerbit,
            'tahun' => $request->tahun,
            'deskripsi' => $request->deskripsi,
            'id_kategori' => $request->id_kategori,
            'status' => 'tersedia'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Buku berhasil ditambahkan',
            'data' => $buku
        ], 201);
    }

    // PUT update buku
    public function update(Request $request, $id)
    {
        $buku = Buku::find($id);

        if (!$buku) {
            return response()->json([
                'success' => false,
                'message' => 'Buku tidak ditemukan'
            ], 404);
        }

        $buku->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Buku berhasil diperbarui',
            'data' => $buku
        ]);
    }

    // DELETE buku
    public function destroy($id)
    {
        $buku = Buku::find($id);

        if (!$buku) {
            return response()->json([
                'success' => false,
                'message' => 'Buku tidak ditemukan'
            ], 404);
        }

        // Hapus buku
        $buku->delete();

        // RESET urutan ID agar kembali mengikuti ID terakhir
        \DB::statement("
            SELECT setval(
                pg_get_serial_sequence('buku', 'id'),
                COALESCE((SELECT MAX(id) FROM buku), 1),
                false
            );
        ");

        return response()->json([
            'success' => true,
            'message' => 'Buku berhasil dihapus'
        ]);
    }

}
