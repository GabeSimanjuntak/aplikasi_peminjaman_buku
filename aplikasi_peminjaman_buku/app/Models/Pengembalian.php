<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pengembalian extends Model
{
    protected $table = 'pengembalian';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'id_peminjaman',
        'tanggal_kembali'
    ];

}
