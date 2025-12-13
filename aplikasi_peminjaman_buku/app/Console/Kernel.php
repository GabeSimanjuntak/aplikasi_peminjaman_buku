<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

// ==== IMPORT MODEL (WAJIB) ====
use App\Models\Peminjaman;
use App\Models\Pengembalian;
use Illuminate\Support\Facades\Log;

class Kernel extends ConsoleKernel
{
    /**
     * Define the application's command schedule.
     */
    protected function schedule(Schedule $schedule)
{
    $schedule->call(function () {
        Log::info('Scheduler running at '.now());

        // logikanya tetap sama
        $today = now()->format('Y-m-d');
        $list = Peminjaman::where('status_pinjam', 'dikembalikan')
            ->whereDate('tanggal_pengembalian_dipilih', '<=', $today)
            ->get();

        foreach ($list as $p) {
            if (!$p->pengembalian) {
                Pengembalian::create([
                    'id_peminjaman' => $p->id,
                    'tanggal_kembali' => now(),
                ]);
            }

            $buku = $p->buku;
            if ($buku && $buku->stok_tersedia < $buku->stok) {
                $buku->stok_tersedia += 1;
                $buku->save();
            }
        }
    })->everyMinute();
}


    /**
     * Register the commands for the application.
     */
    protected function commands()
    {
        $this->load(__DIR__ . '/Commands');

        require base_path('routes/console.php');
    }
}
