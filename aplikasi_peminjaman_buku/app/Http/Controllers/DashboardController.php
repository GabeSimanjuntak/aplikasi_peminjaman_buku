<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Book;
use App\Models\Loan;

class DashboardController extends Controller
{
    // Mendapatkan total buku
    public function totalBuku()
    {
        $total = Book::count();
        return response()->json([
            'total' => $total
        ]);
    }

    // Mendapatkan total peminjaman
    public function totalPeminjaman()
    {
        $total = Loan::count();
        return response()->json([
            'total' => $total
        ]);
    }
}
