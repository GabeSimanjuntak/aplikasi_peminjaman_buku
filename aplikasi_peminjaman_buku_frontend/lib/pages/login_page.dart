import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'admin_dashboard.dart';
import 'user_dashboard.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final result = await ApiService.login(
      usernameController.text,
      passwordController.text,
    );

    // Jika gagal login
    if (result["success"] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Login gagal"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => loading = false);
      return;
    }

    // Jika login sukses
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("token", result["token"]);
    prefs.setInt("role_id", result["user"]["role_id"]);
    prefs.setInt("user_id", result["user"]["id"]);

    // Arahkan berdasarkan role
    if (result["user"]["role_id"] == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserDashboard()),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header Section
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.book_rounded,
                          size: 60,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Selamat Datang",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Aplikasi Peminjaman Buku",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Login Form Section
                Expanded(
                  flex: 3,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Username Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: "Username",
                              labelStyle: TextStyle(color: Colors.grey.shade600),
                              prefixIcon: Icon(Icons.person, color: Colors.blue.shade600),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username harus diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Password Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(color: Colors.grey.shade600),
                              prefixIcon: Icon(Icons.lock, color: Colors.blue.shade600),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey.shade500,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password harus diisi';
                              }
                              if (value.length < 3) {
                                return 'Password terlalu pendek';
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: loading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: loading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    "Masuk",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Forgot Password
                        TextButton(
                          onPressed: () {
                            // Add forgot password functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Fitur lupa password belum tersedia"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                          child: Text(
                            "Lupa Password?",
                            style: TextStyle(
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    "© 2024 Aplikasi Peminjaman Buku",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}