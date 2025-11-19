<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;

    class AuthController extends Controller
    {
        // REGISTER USER
        public function register(Request $request)
        {
            $request->validate([
                'nama' => 'required|string|max:100',
                'email' => 'required|email|unique:users,email',
                'username' => 'required|string|max:50|unique:users,username',
                'password' => 'required|min:6',
                'role_id' => 'required|exists:roles,id'
            ]);

            $user = User::create([
                'nama' => $request->nama,
                'email' => $request->email,
                'username' => $request->username,
                'password' => Hash::make($request->password),
                'role_id' => $request->role_id
            ]);

            // 🔵 KIRIM EMAIL KONFIRMASI REGISTER
            try {
                Mail::raw("
                    Halo {$user->nama},

                    Akun Anda berhasil didaftarkan di Aplikasi Peminjaman Buku.

                    Username : {$user->username}
                    Email    : {$user->email}

                    Terima kasih telah bergabung!

                ", function ($message) use ($user) {
                    $message->to($user->email)
                            ->subject('Registrasi Berhasil - Aplikasi Peminjaman Buku');
                });
            } catch (\Exception $e) {
                return response()->json([
                    'success' => true,
                    'message' => 'Registrasi berhasil, tetapi email gagal dikirim.',
                    'error'   => $e->getMessage(),
                    'data' => $user
                ], 201);
            }

            return response()->json([
                'success' => true,
                'message' => 'Registrasi berhasil! Email konfirmasi telah dikirim.',
                'data' => $user
            ], 201);
        }


        // LOGIN USER
        public function login(Request $request)
        {
            $request->validate([
                'username' => 'required',
                'password' => 'required'
            ]);

            $user = User::where('username', $request->username)->first();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Username tidak ditemukan'
                ], 404);
            }

            if (!Hash::check($request->password, $user->password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Password salah'
                ], 401);
            }

            // Buat token Sanctum
            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Login berhasil',
                'token' => $token,
                'user' => $user
            ], 200);
        }


        // LOGOUT USER
        public function logout(Request $request)
        {
            $request->user()->currentAccessToken()->delete();

            return response()->json([
                'success' => true,
                'message' => 'Berhasil logout'
            ]);
        }


        // GET USER BY ID (PROFILE)
        public function profile($id)
        {
            $user = User::with('role')->find($id);

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => $user
            ], 200);
        }

        public function forgotPassword(Request $request)
        {
            $request->validate([
                'username' => 'required',
                'password' => 'required|min:6'
            ]);

            $user = User::where('username', $request->username)->first();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Username tidak ditemukan'
                ], 404);
            }

            $user->password = Hash::make($request->password);
            $user->save();

            return response()->json([
                'success' => true,
                'message' => 'Password berhasil direset! Silakan login.'
            ]);
        }

        public function sendOtp(Request $request)
        {
            $request->validate(['email' => 'required|email']);

            $user = User::where('email', $request->email)->first();
            if (!$user) {
                return response()->json(['success' => false, 'message' => 'Email tidak ditemukan']);
            }

            $otp = rand(100000, 999999);

            DB::table('password_resets')->updateOrInsert(
                ['email' => $request->email],
                [
                    'otp' => $otp,
                    'expires_at' => now()->addMinutes(10),
                    'created_at' => now(),
                ]
            );

            try {
                Mail::raw("Kode OTP Anda adalah: $otp", function ($message) use ($request) {
                    $message->to($request->email)->subject('Kode Reset Password');
                });
            } catch (\Exception $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'MAIL ERROR: ' . $e->getMessage()
                ], 500);
            }

            return response()->json(['success' => true, 'message' => 'OTP telah dikirim ke email']);
        }
        public function verifyOtp(Request $request)
        {
            $request->validate([
                'email' => 'required|email',
                'otp' => 'required'
            ]);

            $reset = DB::table('password_resets')
                ->where('email', $request->email)
                ->where('otp', $request->otp)
                ->first();

            if (!$reset) {
                return response()->json(['success' => false, 'message' => 'OTP salah']);
            }

            if (now()->greaterThan($reset->expires_at)) {
                return response()->json(['success' => false, 'message' => 'OTP telah expired']);
            }

            return response()->json(['success' => true, 'message' => 'OTP valid']);
        }

        public function resetPassword(Request $request)
        {
            $request->validate([
                'email' => 'required|email',
                'password' => 'required|min:6',
            ]);

            $user = User::where('email', $request->email)->first();
            if (!$user) {
                return response()->json(['success' => false, 'message' => 'Email tidak ditemukan']);
            }

            $user->password = Hash::make($request->password);
            $user->save();

            DB::table('password_resets')->where('email', $request->email)->delete();

            return response()->json(['success' => true, 'message' => 'Password berhasil direset']);
        }

    }
