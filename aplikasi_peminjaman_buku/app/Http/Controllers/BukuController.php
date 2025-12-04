<?php

namespace App\Http\Controllers;

use App\Models\Buku;
use Illuminate\Http\Request;

class BukuController extends Controller
{
    // GET semua buku
    public function index()
    {
        return response()->json([
            'success' => true,
            'data' => Buku::with('kategori')->get()
        ]);
    }

    // GET detail buku
    public function show($id)
    {
        $buku = Buku::with('kategori')->find($id);

        if (!$buku) {
            return response()->json([
                'success' => false,
                'message' => 'Buku tidak ditemukan'
            ], 404);
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
            'judul' => 'required',
            'penulis' => 'required',
            'id_kategori' => 'required|integer',
            'stok' => 'required|integer|min:0',
        ]);

        $buku = Buku::create([
            'judul' => $request->judul,
            'penulis' => $request->penulis,
            'penerbit' => $request->penerbit,
            'tahun' => $request->tahun,
            'deskripsi' => $request->deskripsi,
            'id_kategori' => $request->id_kategori,
            'stok' => $request->stok,
            'status' => 'tersedia'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Buku berhasil ditambahkan',
            'data' => $buku
        ]);
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

        $buku->update([
            'judul' => $request->judul,
            'penulis' => $request->penulis,
            'penerbit' => $request->penerbit,
            'tahun' => $request->tahun,
            'deskripsi' => $request->deskripsi,
            'id_kategori' => $request->id_kategori,
            'stok' => $request->stok,
        ]);

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

        $buku->delete();

        return response()->json([
            'success' => true,
            'message' => 'Buku berhasil dihapus'
        ]);
    }

    // GET buku serupa berdasarkan kategori
    public function bukuSerupa($id)
    {
        $buku = Buku::find($id);

        if (!$buku) {
            return response()->json([
                'success' => false,
                'message' => 'Buku tidak ditemukan'
            ], 404);
        }

        $serupa = Buku::where('id_kategori', $buku->id_kategori)
            ->where('id', '!=', $id)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $serupa
        ]);
    }
}
