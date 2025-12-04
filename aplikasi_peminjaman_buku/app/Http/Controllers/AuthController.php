<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;

class AuthController extends Controller
{
    // ============================================================
    // REGISTER USER
    // ============================================================
public function register(Request $request)
{
    $request->validate([
        'nama' => 'required|string|max:100',
        'email' => 'required|email|unique:users,email',
        'nim' => 'required|string|max:20|unique:users,nim',
        'prodi' => 'required|string|max:100',
        'password' => 'required|min:6',
    ]);

    $roleId = 2;

    $user = User::create([
        'nama' => $request->nama,
        'email' => $request->email,
        'nim' => $request->nim,
        'prodi' => $request->prodi,
        'password' => Hash::make($request->password),
        'role_id' => $roleId,
        'foto' => 'default-profile.png'
    ]);

    // Kirim email konfirmasi
    try {
        Mail::raw("
            Halo {$user->nama},

            Akun Anda berhasil didaftarkan di sistem.

            Nama  : {$user->nama}
            NIM   : {$user->nim}
            Prodi : {$user->prodi}
            Email : {$user->email}

            Terima kasih telah bergabung!

        ", function ($message) use ($user) {
            $message->to($user->email)
                    ->subject('Registrasi Berhasil');
        });
    } catch (\Exception $e) {
        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil, tetapi email gagal dikirim.',
            'error' => $e->getMessage(),
            'data' => $user
        ], 201);
    }

    return response()->json([
        'success' => true,
        'message' => 'Registrasi berhasil! Email konfirmasi telah dikirim.',
        'data' => $user
    ], 201);
}

    // ============================================================
    // LOGIN USER
    // ============================================================
public function login(Request $request)
{
    $request->validate([
        'login' => 'required',     // bisa nama atau nim
        'password' => 'required'
    ]);

    // Cari berdasarkan nama atau NIM
    $user = User::where('nama', $request->login)
                ->orWhere('nim', $request->login)
                ->first();

    if (!$user) {
        return response()->json([
            'success' => false,
            'message' => 'Nama atau NIM tidak ditemukan'
        ], 404);
    }

    // Cek password
    if (!Hash::check($request->password, $user->password)) {
        return response()->json([
            'success' => false,
            'message' => 'Password salah'
        ], 401);
    }

    // Generate token
    $token = $user->createToken('auth_token')->plainTextToken;

    // Foto URL
    $fotoUrl = $user->foto
        ? ($user->foto == 'default-profile.png'
            ? url('default-profile.png')
            : url('storage/' . $user->foto))
        : url('default-profile.png');

    return response()->json([
        'success' => true,
        'message' => 'Login berhasil',
        'token' => $token,
        'user' => [
            'id' => $user->id,
            'nama' => $user->nama,
            'nim' => $user->nim,
            'email' => $user->email,
            'prodi' => $user->prodi,
            'role_id' => $user->role_id,
            'foto' => $fotoUrl
        ]
    ], 200);
}

    // ============================================================
    // LOGOUT
    // ============================================================
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Berhasil logout'
        ]);
    }

    // ============================================================
    // GET PROFILE USER
    // ============================================================
    public function profile($id)
    {
        $user = User::with('role')->find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        // FOTO DEFAULT
        $fotoUrl = $user->foto
            ? ($user->foto == 'default-profile.png'
                ? url('default-profile.png')
                : url('storage/' . $user->foto))
            : url('default-profile.png');

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'nama' => $user->nama,
                'nim' => $user->nim,
                'prodi' => $user->prodi,
                'username' => $user->username,
                'email' => $user->email,
                'role' => $user->role,
                'foto' => $fotoUrl
            ]
        ], 200);
    }

    // ============================================================
    // FORGOT PASSWORD (tanpa OTP)
    // ============================================================
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
            'message' => 'Password berhasil direset!'
        ]);
    }

    // ============================================================
    // SEND OTP
    // ============================================================
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
            Mail::raw("Kode OTP Anda: $otp", function ($message) use ($request) {
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

    // ============================================================
    // VERIFY OTP
    // ============================================================
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

    // ============================================================
    // RESET PASSWORD
    // ============================================================
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

    // ============================================================
    // UPDATE PROFILE (nama, username, email, foto)
    // ============================================================
    public function updateProfile(Request $request)
    {
        $user = auth()->user();

        $request->validate([
            'nama' => 'nullable|string|max:100',
            'username' => 'nullable|string|max:50|unique:users,username,' . $user->id,
            'email' => 'nullable|email|unique:users,email,' . $user->id,
            'foto' => 'nullable|image|mimes:jpg,jpeg,png|max:2048'
        ]);

        // UPLOAD FOTO BARU
        if ($request->hasFile('foto')) {

            // Hapus foto lama jika bukan default
            if ($user->foto &&
                $user->foto != 'default-profile.png' &&
                file_exists(storage_path('app/public/' . $user->foto))) {

                unlink(storage_path('app/public/' . $user->foto));
            }

            $path = $request->file('foto')->store('foto-profil', 'public');
            $user->foto = $path;
        }

        // UPDATE DATA USER
        $user->nama = $request->nama ?? $user->nama;
        $user->username = $request->username ?? $user->username;
        $user->email = $request->email ?? $user->email;

        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui',
            'data' => $user
        ]);
    }
}
