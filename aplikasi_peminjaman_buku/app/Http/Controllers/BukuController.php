<?php

namespace App\Http\Controllers;

use App\Models\Buku;
use Illuminate\Http\Request;

class BukuController extends Controller
{
    public function index()
{
    $books = Buku::with('kategori')->get()->map(function($buku) {
        return [
            'id' => $buku->id,
            'judul' => $buku->judul,
            'penulis' => $buku->penulis,
            'penerbit' => $buku->penerbit,
            'tahun' => $buku->tahun,
            'deskripsi' => $buku->deskripsi,
            'stok' => $buku->stok,                 // total stok
            'stok_tersedia' => $buku->stok_tersedia, // stok tersedia saat ini
            'status' => $buku->status,
            'kategori' => $buku->kategori,
        ];
    });

    return response()->json([
        'success' => true,
        'data' => $books
    ]);
}

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
        'data' => [
            'id' => $buku->id,
            'judul' => $buku->judul,
            'penulis' => $buku->penulis,
            'penerbit' => $buku->penerbit,
            'tahun' => $buku->tahun,
            'deskripsi' => $buku->deskripsi,
            'stok' => $buku->stok,
            'stok_tersedia' => $buku->stok_tersedia,
            'status' => $buku->status,
            'kategori' => $buku->kategori,
        ]
    ]);
}


    // POST tambah buku
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
        'stok_tersedia' => $request->stok, // inisialisasi stok tersedia sama dengan stok total
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
        // Jika stok dikurangi, sesuaikan stok_tersedia agar tidak lebih dari stok
        'stok_tersedia' => min($buku->stok_tersedia, $request->stok),
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

    // cek apakah buku masih ada di peminjaman
    $peminjaman = \App\Models\Peminjaman::where('id_buku', $id)->exists();
    if ($peminjaman) {
        return response()->json([
            'success' => false,
            'message' => 'Buku ini tidak bisa dihapus karena masih dipinjam'
        ]);
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
