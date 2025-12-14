<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Buku extends Model
{
    protected $table = 'buku';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'judul',
        'penulis',
        'penerbit',
        'tahun',
        'deskripsi',
        'id_kategori',
        'stok_total',
        'stok_tersedia',
        'status'
    ];

    public function kategori()
    {
        return $this->belongsTo(KategoriBuku::class, 'id_kategori');
    }
}
