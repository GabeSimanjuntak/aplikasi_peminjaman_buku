import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const statusMap = {
  "pending": "menunggu_persetujuan",
  "aktif": "dipinjam",
  "diajukan": "pengajuan_kembali",
  "selesai": "dikembalikan",
};

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";
  static String? authToken;

  // Load token
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString("token");
  }

  // ============================= LOGIN =============================
  static Future<Map<String, dynamic>> login(String login, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Accept": "application/json"},
      body: {
        "login": login,
        "password": password,
      },
    );
    return json.decode(response.body);
  }

  // ============================= REGISTER =============================
  static Future<dynamic> register({
    required String nama,
    required String username,
    required String email,
    required String nim,
    required String prodi,
    required String angkatan,
    required String password,
    required int roleId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Accept": "application/json"},
        body: {
          'nama': nama,
          'username': username, 
          'email': email,
          'nim': nim,
          'prodi': prodi,
          'angkatan': angkatan,
          'password': password,
          'role_id': roleId.toString(),
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ============================= LOGOUT =============================
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

  // ======================== OTP ============================
  static Future<Map<String, dynamic>> sendOtp(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/forgot-password"),
      body: {"email": email},
    );
    return json.decode(res.body);
  }

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
      Uri.parse("$baseUrl/buku"),
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
      body: data, 
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

    static Future<List<dynamic>> getBukuSerupa(int id) async {
    final res = await http.get(Uri.parse("$baseUrl/buku-serupa/$id"));
    return jsonDecode(res.body)["data"];
  }

  // ======================= KATEGORI CRUD =======================

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
        "Authorization": "Bearer $token",
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

  // ======================= USERS =======================

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

  // ======================= HISTORY =======================

  static Future<List<dynamic>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/pengembalian"),
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

  static Future<List<dynamic>> getHistoryAdmin() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  print("TOKEN: $token");

  final response = await http.get(
    Uri.parse("$baseUrl/riwayat"),
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  print("STATUS CODE: ${response.statusCode}");
  print("BODY: ${response.body}");

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


  // ======================= USER SIDE =======================

static Future<List<dynamic>> getBooksUser() async {
  final response = await http.get(
    Uri.parse("$baseUrl/buku"),
    headers: {
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

  static Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("token");
}

static Future<List<dynamic>> getLoanHistoryUser(int userId) async {
  final url = Uri.parse("${baseUrl}/riwayat/user/$userId");

  final response = await http.get(
    url,
    headers: {
      "Authorization": "Bearer ${await getToken()}",
      "Accept": "application/json",
    },
  );

  print("RIWAYAT USER RESPONSE: ${response.body}");

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    if (body["data"] is List) {
      return body["data"];
    }
  }

  return [];
}





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
      final resJson = jsonDecode(response.body);
      return resJson.containsKey("data") ? resJson["data"] : resJson;
    } else {
      throw Exception("Gagal mengambil profil");
    }
  }

  // ============================= APPROVE =============================

Future<Map<String, dynamic>> approvePeminjaman(int id) async {
  final url = Uri.parse("${ApiService.baseUrl}/peminjaman/$id/konfirmasi");

  final response = await http.post(
    url,
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer ${ApiService.authToken}",
    },
  );

  print("STATUS CODE: ${response.statusCode}");
  print("BODY: ${response.body}");

  return jsonDecode(response.body);
}

  // ============================= UPLOAD FOTO PROFIL =============================

  static Future<String> uploadProfilePhoto(int userId, File photoFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/profile/$userId/update-photo"),
    );

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    request.files.add(
      await http.MultipartFile.fromPath("foto", photoFile.path),
    );

    var response = await request.send();
    var body = await response.stream.bytesToString();

    final jsonRes = jsonDecode(body);

    if (jsonRes["success"] == true) {
      return jsonRes["foto_url"]; // pastikan backend mengirim foto_url
    } else {
      throw Exception(jsonRes["message"] ?? "Upload gagal");
    }
  }

  static Future<Map<String, dynamic>> refreshUser(int userId) async {
    return await getUserProfile(userId);
  }

  static Future<Map<String, dynamic>> updateUserPhoto({
    required int userId,
    required File newPhoto,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/user/update-photo/$userId"),
    );

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    request.files.add(
      await http.MultipartFile.fromPath("photo", newPhoto.path),
    );

    final response = await request.send();
    final body = jsonDecode(await response.stream.bytesToString());

    return body;
  }

  // ======================= GET BOOK DETAIL =======================
static Future<Map<String, dynamic>> getBookDetail(int id) async {
  final response = await http.get(
    Uri.parse("$baseUrl/buku/$id"),
    headers: {"Accept": "application/json"},
  );

  print("DETAIL BOOK STATUS: ${response.statusCode}");
  print("DETAIL BOOK BODY: ${response.body}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body)["data"];
  }

  throw Exception("Gagal memuat detail buku");
}

  /// Buat peminjaman baru untuk user
static Future<Map<String, dynamic>> pinjamBuku(int id) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token"); // ← ini pasti ada
  final userId = prefs.getInt("user_id");

  print("TOKEN TERKIRIM SAAT PINJAM: $token");

  final response = await http.post(
    Uri.parse("$baseUrl/peminjaman"),
    headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    },
    body: {
      "id_user": userId.toString(),
      "id_buku": id.toString(),
    },
  );

  return jsonDecode(response.body);
}

  // ===============================
  // Ajukan Pengembalian Dengan Tanggal
  // ===============================
  static Future<Map<String, dynamic>> ajukanPengembalianWithDate(int id, DateTime tanggal) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/pengembalian/ajukan"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: {
        "id_peminjaman": id.toString(),
        "tanggal_pengembalian":
            "${tanggal.year}-${tanggal.month.toString().padLeft(2,'0')}-${tanggal.day.toString().padLeft(2,'0')}"
      },
    );

    return jsonDecode(response.body);
  }

  static Future<bool> approvePengembalian(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.put(
      Uri.parse("$baseUrl/peminjaman/$id/approve-pengembalian"),
      headers: {
        "Accept": "application/json", // ✅ perbaikan
        "Authorization": "Bearer $token",
      },
    );

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    return response.statusCode == 200;
  }


static Future<dynamic> updatePeminjamanStatus(int idPeminjaman, String status) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.put(
      Uri.parse("$baseUrl/peminjaman/$idPeminjaman/status"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "status": status,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Gagal update status → ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error update status: $e");
    return null;
  }
}

static Future<Map<String, dynamic>> getProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? "";

  final response = await http.get(
    Uri.parse("$baseUrl/profile"),
    headers: {"Authorization": "Bearer $token"},
  );

  print("PROFILE RESPONSE: ${response.body}");

  return jsonDecode(response.body);
}


static Future<Map<String, dynamic>> pinjamBukuDenganForm(Map data) async {
  final response = await http.post(
    Uri.parse("$baseUrl/peminjaman/form"),
    headers: await getHeaders(),
    body: jsonEncode(data),
  );
  return jsonDecode(response.body);
}

static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

static Future<dynamic> getUserLoans() async {
  try {
    final headers = await getHeaders();

    final response = await http.get(
      Uri.parse("$baseUrl/peminjaman/user"),
      headers: headers,
    );

    return jsonDecode(response.body);
  } catch (e) {
    print("ERROR GET USER LOANS: $e");
    return null;
  }
}

static Future<Map<String, dynamic>> cancelPeminjaman(int id) async {
  final url = "$baseUrl/cancel-peminjaman/$id";
  final headers = await getHeaders();

  final response = await http.post(Uri.parse(url), headers: headers);

  return jsonDecode(response.body);
}

}
