<?php

namespace App\Http\Controllers;

use App\Models\Peminjaman;
use App\Models\Buku;
use App\Models\User;
use Illuminate\Http\Request;
use Carbon\Carbon;

class PeminjamanController extends Controller
{
    public function index()
{
    $today = Carbon::today(); // YYYY-MM-DD, pukul 00:00

    $data = Peminjaman::leftJoin('buku', 'peminjaman.id_buku', '=', 'buku.id')
        ->leftJoin('users', 'peminjaman.id_user', '=', 'users.id')
        ->leftJoin('pengembalian', 'peminjaman.id', '=', 'pengembalian.id_peminjaman')
        ->select(
            'peminjaman.id as id_peminjaman',
            'buku.judul as judul_buku',
            'users.nama as nama_user',
            'peminjaman.tanggal_pinjam',
            'peminjaman.tanggal_jatuh_tempo',
            'peminjaman.tanggal_pengembalian_dipilih',
            'pengembalian.tanggal_kembali',
            'peminjaman.status_pinjam'
        )
        ->where(function ($query) use ($today) {
            $query->whereNotIn('peminjaman.status_pinjam', ['dikembalikan'])
                ->orWhere(function ($q) use ($today) {
                    // tetap tampil jika status dikembalikan tapi tanggal_pengembalian_dipilih >= hari ini
                    $q->where('peminjaman.status_pinjam', 'dikembalikan')
                      ->whereDate('peminjaman.tanggal_pengembalian_dipilih', '>=', $today);
                });
        })
        ->orderBy('peminjaman.id', 'DESC')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $data
    ]);
}


    public function store(Request $request)
{
    $request->validate([
        'id_user' => 'required|exists:users,id',
        'id_buku' => 'required|exists:buku,id',
    ]);

    $user = User::find($request->id_user);
    if ($user->role_id == 1) {
        return response()->json([
            'success' => false,
            'message' => 'Admin tidak boleh meminjam buku'
        ], 403);
    }

    $buku = Buku::find($request->id_buku);

    if ($buku->stok_tersedia <= 0) {
        return response()->json([
            'success' => false,
            'message' => 'Stok buku habis'
        ], 400);
    }

    // Periksa duplikat berdasarkan status baru
    $cekDuplikat = Peminjaman::where('id_user', $request->id_user)
        ->where('id_buku', $request->id_buku)
        ->whereIn('status_pinjam', ['menunggu_persetujuan', 'dipinjam'])
        ->first();

    if ($cekDuplikat) {
        return response()->json([
            'success' => false,
            'message' => 'Anda sudah meminjam / sedang menunggu persetujuan untuk buku ini'
        ], 400);
    }

    $tanggalPinjam = now()->toDateString();
    $tanggalTempo = now()->addDays(7)->toDateString();

    $peminjaman = Peminjaman::create([
        'id_user' => $request->id_user,
        'id_buku' => $request->id_buku,
        'tanggal_pinjam' => $tanggalPinjam,
        'tanggal_jatuh_tempo' => $tanggalTempo,
        'status_pinjam' => 'menunggu_persetujuan' // <<-- PENTING (sebelumnya 'pending')
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Peminjaman menunggu persetujuan admin',
        'data' => $peminjaman
    ]);
}

public function konfirmasi($id)
{
    $peminjaman = Peminjaman::find($id);

    if (!$peminjaman) {
        return response()->json(['message' => 'Data tidak ditemukan'], 404);
    }

    if ($peminjaman->status_pinjam !== 'menunggu_persetujuan') {
        return response()->json([
            'message' => 'Peminjaman tidak dalam status menunggu_persetujuan'
        ], 400);
    }

    $buku = Buku::find($peminjaman->id_buku);
    if (!$buku) {
        return response()->json(['message' => 'Buku tidak ditemukan'], 404);
    }

    // Cek stok tersedia sebelum approve
    if ($buku->stok_tersedia <= 0) {
        return response()->json(['message' => 'Stok buku tidak mencukupi'], 400);
    }

    // Kurangi stok tersedia
    $buku->stok_tersedia -= 1;
    $buku->save();

    // Update status peminjaman
    $peminjaman->status_pinjam = 'dipinjam'; // atau 'aktif' sesuai kebutuhan
    $peminjaman->save();

    return response()->json([
        'success' => true,
        'data' => $peminjaman
    ]);
}


public function reject($id)
{
    $p = Peminjaman::find($id);

    if (!$p) {
        return response()->json([
            'success' => false,
            'message' => 'Peminjaman tidak ditemukan'
        ], 404);
    }

    if ($p->status_pinjam !== 'menunggu_persetujuan') {
        return response()->json([
            'success' => false,
            'message' => 'Peminjaman ini tidak dapat ditolak'
        ], 400);
    }

    $p->status_pinjam = 'ditolak'; // atau 'tolak' sesuai preferensi
    $p->save();

    return response()->json([
        'success' => true,
        'message' => 'Peminjaman berhasil ditolak'
    ]);
}

    // public function approvePengembalian($id)
    // {
    //     $p = Peminjaman::find($id);

    //     if (!$p) {
    //         return response()->json([
    //             'success' => false,
    //             'message' => 'Data peminjaman tidak ditemukan'
    //         ], 404);
    //     }

    //     if ($p->status_pinjam !== 'pengajuan_kembali') {
    //         return response()->json([
    //             'success' => false,
    //             'message' => 'Peminjaman belum diajukan pengembalian'
    //         ], 400);
    //     }

    //     // ✅ update status jadi SELESAI
    //     $p->status_pinjam = 'dikembalikan';
    //     $p->tanggal_kembali = now()->toDateString();
    //     $p->save();

    //     // ✅ update stok buku
    //     $buku = Buku::find($p->id_buku);
    //     if ($buku) {
    //         $buku->stok_tersedia += 1;
    //         $buku->status = 'tersedia';
    //         $buku->save();
    //     }

    //     return response()->json([
    //         'success' => true,
    //         'message' => 'Pengembalian disetujui',
    //         'data' => $p
    //     ]);
    // }

    public function riwayatUser($id_user)
    {
        if (auth()->id() != $id_user) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak'
            ], 403);
        }

        $data = Peminjaman::with('buku')
            ->where('id_user', $id_user)
            ->orderBy('id', 'DESC')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    public function peminjamanUser(Request $request)
    {
        $userId = $request->user()->id;

        $data = Peminjaman::join('buku', 'peminjaman.id_buku', '=', 'buku.id')
            ->select(
                'peminjaman.id as id_peminjaman',
                'buku.judul as judul_buku',
                'peminjaman.tanggal_pinjam',
                'peminjaman.tanggal_jatuh_tempo',
                'peminjaman.status_pinjam'
            )
            ->where('peminjaman.id_user', $userId)
            ->orderBy('peminjaman.id', 'DESC')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    private function updateStatusTerlambat()
    {
        Peminjaman::where('status_pinjam', 'aktif')
            ->whereDate('tanggal_jatuh_tempo', '<', now()->toDateString())
            ->update([
                'status_pinjam' => 'terlambat'  // pastikan constraint menerima nilai ini
            ]);
    }

    public function ajukanPengembalian(Request $request)
{
    $request->validate([
        "id_peminjaman" => "required|exists:peminjaman,id",
        "tanggal_pengembalian" => "required|date"
    ]);

    $p = Peminjaman::find($request->id_peminjaman);

    if ($p->status_pinjam !== 'dipinjam') {
        return response()->json([
            "success" => false,
            "message" => "Peminjaman tidak dalam status dipinjam"
        ], 400);
    }

    // ubah status
    $p->status_pinjam = 'pengajuan_kembali';
    $p->tanggal_pengembalian_dipilih = $request->tanggal_pengembalian;
    $p->save();

    return response()->json([
        "success" => true,
        "message" => "Pengajuan pengembalian berhasil dikirim"
    ]);
}



    public function getLoansUser($userId)
{
    $data = Peminjaman::with(['buku.kategori'])
        ->where('id_user', $userId)
        ->get()
        ->map(function ($loan) {
            return [
                'id_peminjaman' => $loan->id,
                'judul_buku' => $loan->buku->judul,
                'penulis' => $loan->buku->penulis,
                'kategori' => $loan->buku->kategori->nama ?? '-',
                'tanggal_pinjam' => $loan->tanggal_pinjam,
                'tanggal_jatuh_tempo' => $loan->tanggal_jatuh_tempo,
                'tanggal_pengembalian_dipilih' => $loan->tanggal_pengembalian_dipilih,
                'status_pinjam' => $loan->status_pinjam,
                'catatan' => $loan->catatan,
            ];
        });

    return response()->json($data);
}



    public function getByUser($id)
    {
        $loans = DB::table('peminjaman')
            ->join('buku', 'buku.id', '=', 'peminjaman.id_buku')
            ->select(
                'peminjaman.id as id_peminjaman',
                'buku.judul as judul_buku',
                'peminjaman.status_pinjam',
                'peminjaman.status_pengembalian',
                'peminjaman.tanggal_pinjam',
                'peminjaman.tanggal_jatuh_tempo',
                'peminjaman.tanggal_pengembalian_dipilih',
                'peminjaman.catatan'
            )
            ->where('id_user', $id)
            ->orderBy('peminjaman.id', 'DESC')
            ->get();

        return response()->json($loans);
    }

    public function cancelPeminjaman($id)
{
    $p = Peminjaman::find($id);

    if (!$p) {
        return response()->json([
            'success' => false,
            'message' => 'Data tidak ditemukan'
        ], 404);
    }

    // ❗ hanya boleh cancel jika BELUM approve admin
    if ($p->status_pinjam !== 'menunggu_persetujuan') {
        return response()->json([
            'success' => false,
            'message' => 'Peminjaman tidak dapat dibatalkan'
        ], 400);
    }

    $p->update([
        'status_pinjam' => 'dibatalkan',
        'tanggal_pengembalian_dipilih' => null
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Peminjaman berhasil dibatalkan'
    ]);
}


public function storeForm(Request $request)
{
    $request->validate([
        'id_buku' => 'required|exists:buku,id',
        'tanggal_pinjam' => 'required|date',
        'tanggal_jatuh_tempo' => 'required|date|after_or_equal:tanggal_pinjam',
    ]);

    // ambil user dari token (auth:sanctum middleware wajib aktif pada route)
    $userId = $request->user()->id;

    $user = User::find($userId);
    if ($user->role_id == 1) {
        return response()->json([
            'success' => false,
            'message' => 'Admin tidak boleh meminjam buku'
        ], 403);
    }

    $buku = Buku::find($request->id_buku);
    if ($buku->stok_tersedia <= 0) {
        return response()->json([
            'success' => false,
            'message' => 'Stok buku habis'
        ], 400);
    }

    $cekDuplikat = Peminjaman::where('id_user', $userId)
        ->where('id_buku', $request->id_buku)
        ->whereIn('status_pinjam', ['menunggu_persetujuan', 'dipinjam'])
        ->first();

    if ($cekDuplikat) {
        return response()->json([
            'success' => false,
            'message' => 'Anda sudah meminjam / menunggu persetujuan untuk buku ini'
        ], 400);
    }

    $peminjaman = Peminjaman::create([
        'id_user' => $userId,
        'id_buku' => $request->id_buku,
        'tanggal_pinjam' => $request->tanggal_pinjam,
        'tanggal_jatuh_tempo' => $request->tanggal_jatuh_tempo,
        'status_pinjam' => 'menunggu_persetujuan',
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Pengajuan peminjaman berhasil dikirim',
        'data' => $peminjaman
    ]);
}


}
