import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'register_page.dart';
import 'admin_dashboard.dart';
import 'user/user_dashboard.dart';
import 'forgot_password_email_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  // Controllers
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Animation Controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _gradientAnimation;

  // State Variables
  bool isLoading = false;
  bool obscurePass = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _gradientAnimation = ColorTween(
      begin: const Color(0xFF667EEA),
      end: const Color(0xFF764BA2),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> loginUser() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await ApiService.login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      print("LOGIN RESPONSE: $response");

      // CEK GAGAL LOGIN
      if (response["status"] == false || !response.containsKey("token")) {
        _showErrorSnackbar(response["message"] ?? "Login gagal");
        return;
      }

      // LOGIN SUKSES
      await _saveUserData(response);
      _redirectUser(response["user"]["role_id"]);
    } catch (e) {
      _showErrorSnackbar("Terjadi kesalahan: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", response["token"]);
    await prefs.setInt("role_id", response["user"]["role_id"]);
    await prefs.setInt("user_id", response["user"]["id"]);
    await prefs.setString("nama", response["user"]["nama"]); 
    await prefs.setString("foto", response["user"]["foto"]);
  }

  void _redirectUser(int roleId) {
    final page = roleId == 1 
    ? const AdminDashboard() 
    : UserDashboardPage();
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RegisterPage(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.fastEaseInToSlowEaseOut,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ForgotPasswordEmailPage(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.fastEaseInToSlowEaseOut,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _gradientAnimation.value!,
                  const Color(0xFF764BA2),
                  const Color(0xFF667EEA),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Background Elements
                  _buildBackgroundElements(),
                  
                  // Content
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          
                          // Header Section
                          _buildHeaderSection(),
                          
                          const SizedBox(height: 60),
                          
                          // Form Section
                          _buildFormSection(),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Positioned.fill(
      child: Column(
        children: [
          // Animated Circles
          ...List.generate(3, (index) => _buildFloatingCircle(index)),
          
          // Gradient Overlay
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.03),
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCircle(int index) {
    final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1 + (index * 0.2), 1.0, curve: Curves.easeOut),
      ),
    );

    return Expanded(
      child: FadeTransition(
        opacity: delayedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(index.isEven ? -0.5 : 0.5, 0.0),
            end: Offset.zero,
          ).animate(delayedAnimation),
          child: Align(
            alignment: index == 0 
                ? Alignment.topLeft 
                : index == 1 
                    ? Alignment.topRight 
                    : Alignment.centerLeft,
            child: Container(
              width: 120 + (index * 40),
              height: 120 + (index * 40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
        )),
        child: Column(
          children: [
            // App Icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 20),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 50,
                  color: const Color(0xFF667EEA),
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              "Welcome Back",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle
            Text(
              "Sign in to continue to your library",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.4),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
        )),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  // Username Field
                  _buildModernTextField(
                    controller: usernameController,
                    label: "Username",
                    icon: Icons.person_outline_rounded,
                    validator: (value) => value!.isEmpty ? "Username tidak boleh kosong" : null,
                    index: 0,
                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  _buildModernPasswordField(),

                  const SizedBox(height: 16),

                  // Forgot Password
                  _buildModernForgotPassword(),

                  const SizedBox(height: 30),

                  // Login Button
                  _buildModernLoginButton(),

                  const SizedBox(height: 24),

                  // Divider
                  _buildDivider(),

                  const SizedBox(height: 24),

                  // Register Link
                  _buildModernRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required int index,
  }) {
    final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.5 + (index * 0.15), 1.0, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: delayedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.5, 0.0),
          end: Offset.zero,
        ).animate(delayedAnimation),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              floatingLabelStyle: TextStyle(
                color: const Color(0xFF667EEA),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.grey.shade500,
                size: 22,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              hintText: "Enter your $label",
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernPasswordField() {
    final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: delayedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.5, 0.0),
          end: Offset.zero,
        ).animate(delayedAnimation),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: passwordController,
            obscureText: obscurePass,
            validator: (value) => value!.isEmpty ? "Password tidak boleh kosong" : null,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: "Password",
              labelStyle: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              floatingLabelStyle: TextStyle(
                color: const Color(0xFF667EEA),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: Colors.grey.shade500,
                size: 22,
              ),
              suffixIcon: ScaleTransition(
                scale: _animationController,
                child: IconButton(
                  icon: Icon(
                    obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
                  onPressed: () => setState(() => obscurePass = !obscurePass),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              hintText: "Enter your password",
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernForgotPassword() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: _navigateToForgotPassword,
          child: Text(
            "Forgot Password?",
            style: TextStyle(
              color: const Color(0xFF667EEA),
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernLoginButton() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading ? null : loginUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: const Color(0xFF667EEA).withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Stack(
            children: [
              // Button Text
              AnimatedOpacity(
                opacity: isLoading ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                    ),
                  ],
                ),
              ),
              
              // Loading Indicator
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    opacity: isLoading ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "OR",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ],
    );
  }

  Widget _buildModernRegisterLink() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account?",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _navigateToRegister,
            child: Text(
              "Sign Up",
              style: TextStyle(
                color: const Color(0xFF667EEA),
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}