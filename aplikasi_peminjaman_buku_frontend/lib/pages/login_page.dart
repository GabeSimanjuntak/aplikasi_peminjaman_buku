import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'register_page.dart';
import 'admin_dashboard.dart';
import 'user_dashboard.dart';
import 'forgot_password_email_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePass = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1200));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.0, 0.6, curve: Curves.easeIn)));
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.3, 0.8, curve: Curves.easeOut)));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.5, 1.0, curve: Curves.elasticOut)));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void loginUser() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    await _animationController.reverse();

    final response = await ApiService.login(usernameController.text.trim(), passwordController.text.trim());

    setState(() => isLoading = false);
    print(">>> LOGIN RESPONSE: $response");

    if (response.containsKey("token")) {
      // ambil role
      int roleId = response["user"]?["role_id"] ?? response["user"]?["role"] ?? 2;
      final username = response["user"]?["nama"] ?? usernameController.text.trim();
      final userId = response["user"]?["id"];

      // success animation (simple)
      _animationController.forward();

      if (roleId == 1) {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/user', arguments: {'username': username, 'userId': userId});
      }
    } else {
      // error
      _animationController.forward();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Login gagal"),
          backgroundColor: Colors.blue.shade700,
          behavior: SnackBarBehavior.floating,
          elevation: 6,
        ),
      );
    }
  }

  void _navigateToRegister() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade100, Colors.blue.shade50, Colors.white],
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(begin: Offset(0, -0.5), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.2, 0.6, curve: Curves.easeOut))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.blue.shade600, Colors.blue.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 20, offset: Offset(0, 8))],
                                  ),
                                  child: Icon(Icons.book_rounded, size: 60, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 24),
                              AnimatedText(text: "Selamat Datang", animation: _fadeAnimation, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                              const SizedBox(height: 8),
                              AnimatedText(text: "Aplikasi Peminjaman Buku", animation: _fadeAnimation, style: TextStyle(fontSize: 16, color: Colors.blue.shade700)),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 3,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.4, 0.8, curve: Curves.easeOut))),
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  // Username
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 500),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.shade300, width: 1.5), boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 15, offset: Offset(0, 5))]),
                                    child: TextFormField(
                                      controller: usernameController,
                                      decoration: InputDecoration(
                                        labelText: "Username",
                                        prefixIcon: Icon(Icons.person_outline, color: Colors.blue.shade600),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        hintText: "Masukkan username Anda",
                                      ),
                                      validator: (v) => v!.isEmpty ? "Username tidak boleh kosong" : null,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Password
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 500),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.shade300, width: 1.5), boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 15, offset: Offset(0, 5))]),
                                    child: TextFormField(
                                      controller: passwordController,
                                      obscureText: obscurePass,
                                      decoration: InputDecoration(
                                        labelText: "Password",
                                        prefixIcon: Icon(Icons.lock_outline, color: Colors.blue.shade600),
                                        suffixIcon: IconButton(icon: Icon(obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.blue.shade500), onPressed: () => setState(() => obscurePass = !obscurePass)),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        hintText: "Masukkan password Anda",
                                      ),
                                      validator: (v) => v!.isEmpty ? "Password tidak boleh kosong" : null,
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  Align(alignment: Alignment.centerRight, child: GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordEmailPage())), child: Text("Lupa Password?", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)))),

                                  const SizedBox(height: 16),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : loginUser,
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, elevation: 8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                      child: isLoading ? CircularProgressIndicator(color: Colors.white) : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded)]),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.6, 1.0, curve: Curves.easeOut))),
                                      child: Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.shade200, width: 1.5)),
                                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                          Text("Belum punya akun?", style: TextStyle(color: Colors.blue.shade700)),
                                          SizedBox(width: 8),
                                          GestureDetector(onTap: _navigateToRegister, child: Container(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade400]), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))]), child: Row(children: [Text("Daftar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)), SizedBox(width: 6), Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white)]))),
                                        ]),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AnimatedText extends StatelessWidget {
  final String text;
  final Animation<double> animation;
  final TextStyle style;

  const AnimatedText({Key? key, required this.text, required this.animation, required this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: animation, builder: (context, child) {
      return Opacity(opacity: animation.value, child: Transform.translate(offset: Offset(0, (1 - animation.value) * 20), child: Text(text, style: style, textAlign: TextAlign.center)));
    });
  }
}
