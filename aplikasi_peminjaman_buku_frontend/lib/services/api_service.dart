import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Map<String, String> defaultHeaders = {
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

  static dynamic safeJsonDecode(String body) {
    try {
      if (body.isEmpty) return {};
      return json.decode(body);
    } catch (_) {
      return {"error": "Invalid JSON"};
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Accept": "application/json"},
        body: {
          "username": username,
          "password": password,
        },
      );
      return safeJsonDecode(response.body);
    } catch (e) {
      return {"status": false, "message": "Gagal terhubung ke server"};
    }
  }

  // REGISTER
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String username,
    required String password,
    required int roleId,
  }) async {
    try {
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
      return safeJsonDecode(response.body);
    } catch (e) {
      return {"status": false, "message": "Gagal terhubung ke server"};
    }
  }

  // LOGOUT
  static Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/logout"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      return safeJsonDecode(response.body);
    } catch (e) {
      return {"status": false, "message": "Gagal logout"};
    }
  }

  // FORGOT / OTP / RESET
  static Future<Map<String, dynamic>> forgotPassword({
    required String username,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/forgot-password"),
        headers: {"Accept": "application/json"},
        body: {"username": username, "password": newPassword},
      );
      return safeJsonDecode(response.body);
    } catch (e) {
      return {"status": false, "message": "Gagal mengubah password"};
    }
  }

  static Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final res = await http.post(Uri.parse("$baseUrl/forgot-password"), body: {"email": email});
      return safeJsonDecode(res.body);
    } catch (e) {
      return {"status": false, "message": "Gagal mengirim OTP"};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await http.post(Uri.parse("$baseUrl/verify-otp"), body: {"email": email, "otp": otp});
      return safeJsonDecode(res.body);
    } catch (e) {
      return {"status": false, "message": "Gagal verifikasi OTP"};
    }
  }

  static Future<Map<String, dynamic>> resetPassword({required String email, required String password}) async {
    try {
      final res = await http.post(Uri.parse("$baseUrl/reset-password"), body: {"email": email, "password": password});
      return safeJsonDecode(res.body);
    } catch (e) {
      return {"status": false, "message": "Gagal reset password"};
    }
  }

  // BUKU CRUD
  static Future<List<dynamic>> getBooks() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/buku"));
      final body = safeJsonDecode(res.body);
      return body["data"] ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createBook(Map<String, String> data) async {
    try {
      final res = await http.post(Uri.parse("$baseUrl/buku"), headers: {"Accept": "application/json"}, body: data);
      return safeJsonDecode(res.body);
    } catch (e) {
      return {"status": false, "message": "Gagal menambah buku"};
    }
  }

  static Future<Map<String, dynamic>> updateBook(int id, Map<String, String> data) async {
    try {
      final res = await http.post(Uri.parse("$baseUrl/buku/$id?_method=PUT"), headers: {"Accept": "application/json"}, body: data);
      return safeJsonDecode(res.body);
    } catch (e) {
      return {"status": false, "message": "Gagal mengupdate buku"};
    }
  }

  static Future<Map<String, dynamic>> deleteBook(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/buku/$id"));
      return safeJsonDecode(res.body);
    } catch (e) {
      return {"status": false, "message": "Gagal menghapus buku"};
    }
  }

  // PEMINJAMAN
  static Future<Map<String, dynamic>> pinjamBuku({required int bookId, required int userId}) async {
    try {
      // send both keys in case backend expects "book_id" or "buku_id"
      final bodyMap = {
        "book_id": bookId.toString(),
        "buku_id": bookId.toString(),
        "user_id": userId.toString(),
      };

      final res = await http.post(Uri.parse("$baseUrl/peminjaman"), headers: {"Accept": "application/json"}, body: bodyMap);
      return safeJsonDecode(res.body);
    } catch (e) {
      return {"status": false, "message": "Gagal meminjam buku"};
    }
  }

  static Future<List<dynamic>> getPeminjamanUser(int userId) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/peminjaman/user/$userId"), headers: {"Accept": "application/json"});
      final body = safeJsonDecode(res.body);
      return body["data"] ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getAllPeminjaman() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/peminjaman"), headers: {"Accept": "application/json"});
      final body = safeJsonDecode(res.body);
      return body["data"] ?? [];
    } catch (e) {
      return [];
    }
  }
}
