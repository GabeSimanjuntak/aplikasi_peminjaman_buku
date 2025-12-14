<?php

namespace App\Http\Controllers;

use App\Models\Buku;
use Illuminate\Http\Request;

class BukuController extends Controller
{
    // =========================
    // GET: daftar buku
    // =========================
    public function index()
    {
        $books = Buku::with('kategori')->get()->map(function ($buku) {
            return [
                'id' => $buku->id,
                'judul' => $buku->judul,
                'penulis' => $buku->penulis,
                'penerbit' => $buku->penerbit,
                'tahun' => $buku->tahun,
                'deskripsi' => $buku->deskripsi,

                // KONSISTEN
                'stok' => $buku->stok_total,
                'stok_tersedia' => $buku->stok_tersedia,

                'status' => $buku->status,
                'kategori' => $buku->kategori,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $books
        ]);
    }

    // =========================
    // GET: detail buku
    // =========================
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

                // KONSISTEN
                'stok' => $buku->stok_total,
                'stok_tersedia' => $buku->stok_tersedia,

                'status' => $buku->status,
                'kategori' => $buku->kategori,
            ]
        ]);
    }

    // =========================
    // POST: tambah buku
    // =========================
    public function store(Request $request)
    {
        $request->validate([
            'judul' => 'required',
            'penulis' => 'required',
            'id_kategori' => 'required|integer',
            'stok' => 'required|integer|min:1',
        ]);

        $buku = Buku::create([
            'judul' => $request->judul,
            'penulis' => $request->penulis,
            'penerbit' => $request->penerbit,
            'tahun' => $request->tahun,
            'deskripsi' => $request->deskripsi,
            'id_kategori' => $request->id_kategori,

            // ⬇⬇⬇ INI WAJIB ADA
            'stok_total' => $request->stok,
            'stok_tersedia' => $request->stok,

            'status' => 'tersedia'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Buku berhasil ditambahkan',
            'data' => $buku
        ], 201);
    }

    // =========================
    // PUT: update buku
    // =========================
    public function update(Request $request, $id)
    {
        $buku = Buku::find($id);

        if (!$buku) {
            return response()->json([
                'success' => false,
                'message' => 'Buku tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'judul' => 'required|string',
            'penulis' => 'required|string',
            'id_kategori' => 'required|integer',
            'stok' => 'required|integer|min:1',
        ]);

        $stokBaru = $request->stok;

        $buku->update([
            'judul' => $request->judul,
            'penulis' => $request->penulis,
            'penerbit' => $request->penerbit,
            'tahun' => $request->tahun,
            'deskripsi' => $request->deskripsi,
            'id_kategori' => $request->id_kategori,

            // JAGA KONSISTENSI
            'stok_total' => $stokBaru,
            'stok_tersedia' => min($buku->stok_tersedia, $stokBaru),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Buku berhasil diperbarui',
            'data' => $buku
        ]);
    }

    // =========================
    // DELETE: hapus buku
    // =========================
    public function destroy($id)
    {
        $buku = Buku::find($id);

        if (!$buku) {
            return response()->json([
                'success' => false,
                'message' => 'Buku tidak ditemukan'
            ], 404);
        }

        $masihDipinjam = \App\Models\Peminjaman::where('id_buku', $id)
            ->whereIn('status_pinjam', ['dipinjam', 'menunggu_pengembalian'])
            ->exists();

        if ($masihDipinjam) {
            return response()->json([
                'success' => false,
                'message' => 'Buku tidak bisa dihapus karena masih dipinjam'
            ]);
        }

        $buku->delete();

        return response()->json([
            'success' => true,
            'message' => 'Buku berhasil dihapus'
        ]);
    }

    // =========================
    // GET: buku serupa
    // =========================
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
