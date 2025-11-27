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

  static Future<Map<String, dynamic>> createBook(String token, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/books"); // gunakan /books

    final res = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateBook(int id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.post(
      Uri.parse("$baseUrl/buku/$id?_method=PUT"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteBook(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/buku/$id"));
    return json.decode(res.body);
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
}
