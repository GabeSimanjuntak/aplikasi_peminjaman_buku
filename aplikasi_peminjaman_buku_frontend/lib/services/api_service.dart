import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";
  static String? authToken;

  // Load token dari SharedPreferences
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString("token");
  }

  // =============================
  // LOGIN
  // =============================
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Accept": "application/json"},
      body: {
        "username": username,
        "password": password,
      },
    );
    return json.decode(response.body);
  }

  // =============================
  // REGISTER
  // =============================
    static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String username,
    required String password,
    required int roleId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Accept": "application/json"},
      body: {
        "nama": nama,
        "email": email,
        "username": username,
        "password": password,
                "role_id": roleId.toString(),
      },
    );

    return json.decode(response.body);
  }

  // =============================
  // LOGOUT
  // =============================
  static Future<Map<String, dynamic>> logout(String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/logout"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return json.decode(response.body);
  }

    // SEND OTP
  static Future<Map<String, dynamic>> sendOtp(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/forgot-password"),
      body: {"email": email},
    );
    return json.decode(res.body);
  }

  // VERIFY OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/verify-otp"),
      body: {"email": email, "otp": otp},
    );
    return json.decode(res.body);
  }

  // RESET PASSWORD
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/reset-password"),
      body: {"email": email, "password": password},
    );
    return json.decode(res.body);
  }

  // ======================= BUKU CRUD =======================

  static Future<List<dynamic>> getBooks() async {
        final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/buku"),      // ← perbaikan di sini
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    final json = jsonDecode(response.body);
    return json["data"] ?? [];
  }

  static Future<Map<String, dynamic>> createBook(String token, Map data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/buku"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
      body: data, // ← jangan jsonEncode!
    );

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateBook(int id, Map data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.post(
      Uri.parse("$baseUrl/buku/$id?_method=PUT"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
      body: data,
    );

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteBook(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.delete(
      Uri.parse("$baseUrl/buku/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    return jsonDecode(response.body);
  }

  // ======================= KATEGORI CRUD =======================

  // GET ALL KATEGORI
  static Future<List<dynamic>> getKategori(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/kategori"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return json.decode(response.body)["data"];
  }

  static Future<Map<String, dynamic>> createKategori(Map data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/kategori"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",   // ← INI YANG WAJIB!
      },
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateKategori(int id, Map<String, String> data) async {
    await loadToken();

    final response = await http.post(
      Uri.parse("$baseUrl/kategori/$id?_method=PUT"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $authToken",
      },
      body: data,
    );

    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> deleteKategori(int id) async {
    await loadToken();

    final response = await http.delete(
      Uri.parse("$baseUrl/kategori/$id"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $authToken",
      },
    );

    return json.decode(response.body);
  }

  // ======================= USERS (untuk peminjaman) =======================

  static Future<List<dynamic>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("$baseUrl/users"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    return jsonDecode(res.body)["data"];
  }

  // ======================= PEMINJAMAN =======================

  static Future<Map<String, dynamic>> createPeminjaman(Map data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.post(
      Uri.parse("$baseUrl/peminjaman"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
      body: data,
    );

    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getPeminjamanAktif() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/peminjaman"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final res = json.decode(response.body);

    if (res["success"] == true) {
      return res["data"];
    }
    return [];
  }


  static Future<Map<String, dynamic>> kembalikanBuku(int idPeminjaman) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.post(
      Uri.parse("$baseUrl/pengembalian"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
      body: {
        "id_peminjaman": idPeminjaman.toString(),
      },
    );

    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/pengembalian"), // pastikan endpoint ini mengembalikan semua history
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['data'] ?? [];
    } else {
      throw Exception('Gagal mengambil data history');
    }
  }

  // Ambil semua riwayat peminjaman untuk admin
static Future<List<dynamic>> getHistoryAdmin() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  final response = await http.get(
    Uri.parse("$baseUrl/riwayat"), // endpoint RiwayatController@index
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    if (jsonData['success'] == true) {
      return jsonData['data'] ?? [];
    } else {
      return [];
    }
  } else {
    throw Exception('Gagal mengambil data history admin');
  }
}

// ========================== PENGERJAAN AIRIN ===================================
  
  // [USER] Ambil daftar buku untuk user
  static Future<List<dynamic>> getBooksUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/buku-user"), // Sesuai route Laravel: Route::get('/buku-user', ...)
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json["data"] ?? [];
    } else {
      return [];
    }
  }

  // [USER] Ambil history peminjaman user
  static Future<List<dynamic>> getLoanHistoryUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/riwayat/user/$userId"), // Sesuai route Laravel
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json["data"] ?? [];
    } else {
      return [];
    }
  }

  // [USER] Get User Profile
  static Future<Map<String, dynamic>> getUserProfile(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/profile/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["data"];
    } else {
      throw Exception("Gagal mengambil profil");
    }
  }

  // [USER] Update Photo Profile
  static Future<bool> updateProfile({
    required int id,
    String? nama,
    String? email,
    String? username,
    String? filePath, // Path foto dari galeri
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    // Gunakan MultipartRequest karena ada potensi upload file
    var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/profile/update"));

    // Header Auth
    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    // Masukkan data teks jika ada
    if (nama != null) request.fields['nama'] = nama;
    if (email != null) request.fields['email'] = email;
    if (username != null) request.fields['username'] = username;

    // Masukkan file jika ada
    if (filePath != null) {
      // PENTING: Key harus 'foto', sesuai dengan $request->file('foto') di Laravel
      request.files.add(await http.MultipartFile.fromPath('foto', filePath));
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Gagal update: $responseBody"); // Untuk debugging
        return false;
      }
    } catch (e) {
      print("Error API: $e");
      return false;
    }
  }


// ================================
// APPROVE PEMINJAMAN (ADMIN)
// ================================
// static Future<Map<String, dynamic>> approvePeminjaman(int idPeminjaman) async {
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString("token");

//   final url = Uri.parse("$baseUrl/peminjaman/$idPeminjaman/approve");

//   final response = await http.put(
//     url,
//     headers: {
//       "Accept": "application/json",
//       "Authorization": "Bearer $token"
//     },
//   );

//   final jsonData = jsonDecode(response.body);

//   return {
//     "success": jsonData["success"] ?? false,
//     "message": jsonData["message"] ?? "Terjadi kesalahan"
//   };
// }



// Kembalikan buku
// static Future<Map<String, dynamic>> kembalikanBuku(int idPeminjaman) async {
//   final url = Uri.parse("$baseUrl/pengembalian");

//   final response = await http.post(
//     url,
//     body: {
//       "id_peminjaman": idPeminjaman.toString(),
//     },
//   );

//   return jsonDecode(response.body);
// }


static Future<List<dynamic>> getSemuaPeminjaman() async {
  final url = Uri.parse("$baseUrl/peminjaman");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["data"];
  }
  return [];
}

// ==========================
  // GET Semua Data Peminjaman
  // ==========================
  static Future<List<dynamic>> getPeminjaman() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/peminjaman"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body["data"];
    } else {
      throw Exception("Gagal load peminjaman");
    }
  }

  // ==========================
// APPROVE PEMINJAMAN
// ==========================
static Future<bool> approvePeminjaman(int id) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    if (token.isEmpty) {
      print("Token tidak tersedia");
      return false;
    }

    final url = Uri.parse("$baseUrl/peminjaman/$id/approve");
    final response = await http.put(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final resBody = jsonDecode(response.body);
      // Jika API mengirim success field
      if (resBody['success'] == true) {
        return true;
      } else {
        print("API gagal: ${resBody['message'] ?? 'Unknown error'}");
        return false;
      }
    } else {
      print("HTTP Error: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("Exception approvePeminjaman: $e");
    return false;
  }
}

}