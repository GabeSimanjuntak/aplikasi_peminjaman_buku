import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

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

      print(">>> Sending data:");
      print({
        "nama": nama,
        "email": email,
        "username": username,
        "password": password,
        "role_id": roleId,
      });

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

      print(">>> RAW RESPONSE:");
      print(response.body);

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

  static Future<Map<String, dynamic>> forgotPassword({
    required String username,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/forgot-password"),
      headers: {"Accept": "application/json"},
      body: {
        "username": username,
        "password": newPassword,
      },
    );

    return json.decode(response.body);
  }

  // KIRIM OTP EMAIL
  static Future<Map<String, dynamic>> sendOtp(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/forgot-password"),
      body: {"email": email},
    );
    return json.decode(res.body);
  }

  // VERIFIKASI OTP
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
}
