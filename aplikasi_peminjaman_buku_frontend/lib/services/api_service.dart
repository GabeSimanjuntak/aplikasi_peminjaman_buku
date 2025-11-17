import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  // LOGIN
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Accept": "application/json"},
      body: {"username": username, "password": password},
    );

    return json.decode(response.body);
  }
}
