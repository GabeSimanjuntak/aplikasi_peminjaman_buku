<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Buku;
use App\Models\KategoriBuku;
use Faker\Factory as Faker;

class BukuSeeder extends Seeder
{
    public function run()
    {
        $faker = Faker::create('id_ID'); // Pakai locale Indonesia biar namanya lokal

        // Ambil semua ID kategori yang ada
        $kategoriIds = KategoriBuku::pluck('id')->toArray();

        // Cek jika belum ada kategori, stop seeder
        if (empty($kategoriIds)) {
            $this->command->info('Harap jalankan KategoriSeeder terlebih dahulu!');
            return;
        }

        // Buat 20 buku dummy
        for ($i = 1; $i <= 20; $i++) {
            Buku::create([
                'judul'       => $faker->sentence(3), // Judul 3 kata
                'penulis'     => $faker->name,
                'penerbit'    => $faker->company,
                'tahun'       => $faker->year,
                'deskripsi'   => $faker->paragraph,
                'status'      => 'tersedia',
                'id_kategori' => $faker->randomElement($kategoriIds),
                
            ]);
        }
    }
}
