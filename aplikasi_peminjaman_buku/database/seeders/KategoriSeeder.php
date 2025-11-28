<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\KategoriBuku;

class KategoriSeeder extends Seeder
{
    public function run()
    {

        $data = [
            ['nama_kategori' => 'Novel'],
            ['nama_kategori' => 'Komik'],
            ['nama_kategori' => 'Teknologi'],
            ['nama_kategori' => 'Biografi'],
            ['nama_kategori' => 'Sains'],
        ];

        foreach ($data as $item) {
            KategoriBuku::create($item);
        }
    }
}
