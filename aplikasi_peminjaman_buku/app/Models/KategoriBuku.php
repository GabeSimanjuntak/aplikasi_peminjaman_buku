<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class KategoriBuku extends Model
{
    protected $table = 'kategori_buku';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'nama_kategori'
    ];
}
