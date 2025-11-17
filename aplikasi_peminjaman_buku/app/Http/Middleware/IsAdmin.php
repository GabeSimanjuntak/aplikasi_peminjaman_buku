<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class IsAdmin
{
    public function handle(Request $request, Closure $next)
    {
        if ($request->user()->role_id != 1) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied (Admin only)'
            ], 403);
        }

        return $next($request);
    }
}
