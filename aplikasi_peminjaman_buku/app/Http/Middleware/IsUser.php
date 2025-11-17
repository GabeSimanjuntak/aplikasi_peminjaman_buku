<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class IsUser
{
    public function handle(Request $request, Closure $next)
    {
        if ($request->user()->role_id != 2) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied (User only)'
            ], 403);
        }

        return $next($request);
    }
}
