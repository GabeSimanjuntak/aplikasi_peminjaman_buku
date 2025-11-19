<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run()
    {
        // Cek apakah user admin sudah ada
        User::firstOrCreate(
            ['username' => 'admin'],   // kolom unik yang dicek dulu
            [
                'nama' => 'Admin',
                'email' => 'admin@example.com',
                'password' => Hash::make('admin123'),
                'role_id' => 1,
            ]
        );
    }
}
