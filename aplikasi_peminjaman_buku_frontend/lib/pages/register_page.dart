import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  bool obscurePass = true;
  
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _textOpacityAnimation; // ✅ Tambah animation untuk text

  final namaCtrl = TextEditingController();
  final usernameCtrl = TextEditingController(); // ✅
  final emailCtrl = TextEditingController();
  final nimCtrl = TextEditingController();
  final prodiCtrl = TextEditingController();
  final angkatanCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  
  final FocusNode _namaFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _nimFocusNode = FocusNode();
  final FocusNode _prodiFocusNode = FocusNode();
  final FocusNode _angkatanFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutBack),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );
    
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: const Color(0xFFF0F8FF),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    // ✅ Tambah animation untuk text GAIRMOS LIBRARY
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _namaFocusNode.dispose();
    _emailFocusNode.dispose();
    _nimFocusNode.dispose();
    _prodiFocusNode.dispose();
    _angkatanFocusNode.dispose();
    _passwordFocusNode.dispose();
    namaCtrl.dispose();
    usernameCtrl.dispose();
    emailCtrl.dispose();
    nimCtrl.dispose();
    prodiCtrl.dispose();
    angkatanCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);
    
    // Button press animation
    _controller.animateTo(0.8, duration: const Duration(milliseconds: 200));
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      final res = await ApiService.register(
        nama: namaCtrl.text.trim(),
        username: usernameCtrl.text.trim(), // ✅ FIX UTAMA
        email: emailCtrl.text.trim(),
        nim: nimCtrl.text.trim(),
        prodi: prodiCtrl.text.trim(),
        angkatan: angkatanCtrl.text.trim(),
        password: passCtrl.text.trim(),
        roleId: 2,
      );

      if (res["success"] == true) {
        if (!mounted) return;

        // Success animation
        _controller.animateTo(1.0, duration: const Duration(milliseconds: 500));
        
        // Add success visual feedback
        await Future.delayed(const Duration(milliseconds: 300));
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Pendaftaran berhasil! Silakan login.",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back with animation
        await Future.delayed(const Duration(milliseconds: 500));
        
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginPage(),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      } else {
        // Error animation
        await _shakeAnimation();
        _showErrorSnackbar(res["message"] ?? "Pendaftaran gagal");
      }
    } catch (e) {
      await _shakeAnimation();
      _showErrorSnackbar("Error: $e");
    } finally {
      _controller.animateTo(1.0, duration: const Duration(milliseconds: 300));
      setState(() => loading = false);
    }
  }

  Future<void> _shakeAnimation() async {
    const shakeDuration = Duration(milliseconds: 50);
    for (int i = 0; i < 4; i++) {
      await _controller.animateTo(0.9, duration: shakeDuration);
      await _controller.animateTo(1.1, duration: shakeDuration);
    }
    await _controller.animateTo(1.0, duration: shakeDuration);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error,
                color: Colors.red,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildAnimatedBookIcon() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2C3E50),
                  Color(0xFF3498DB),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3498DB).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 3,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Book pages effect
                Positioned(
                  top: 20,
                  left: 35,
                  child: Container(
                    width: 70,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                
                // Book spine
                Positioned(
                  left: 30,
                  top: 20,
                  child: Container(
                    width: 15,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2C3E50).withOpacity(0.9),
                          const Color(0xFF2C3E50),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      ),
                    ),
                  ),
                ),
                
                // Book icon (gunakan icon register)
                const Center(
                  child: Icon(
                    Icons.app_registration_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                
                // Shine effect
                Positioned(
                  top: 25,
                  left: 45,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Container(
                      width: 40,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingBook({
    required double left,
    required double top,
    required Color color,
    required double size,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = 20 * (1 - _controller.value);
          final opacity = _controller.value;
          
          return Transform.translate(
            offset: Offset(0, offset),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.book,
                  color: color,
                  size: size * 0.6,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    required TextInputAction textInputAction,
    required VoidCallback onSubmitted,
    required String? Function(String?)? validator,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onToggleObscure,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText ?? false,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: (_) => onSubmitted(),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF3498DB),
            width: 2,
          ),
        ),
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF3498DB),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
        suffixIcon: isPassword && onToggleObscure != null
            ? AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  onPressed: onToggleObscure,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: obscureText!
                        ? const Icon(
                            Icons.visibility_off_rounded,
                            key: ValueKey('visible_off'),
                            color: Color(0xFF3498DB),
                          )
                        : const Icon(
                            Icons.visibility_rounded,
                            key: ValueKey('visible_on'),
                            color: Color(0xFF3498DB),
                          ),
                  ),
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
<<<<<<< HEAD
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // FULL NAME
                  TextFormField(
                    controller: namaCtrl,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Full name required" : null,
                  ),
                  const SizedBox(height: 14),

                  // EMAIL
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (v) {
                      if (v!.isEmpty) return "Email required";
                      if (!v.contains("@")) return "Email invalid";
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // NIM
                  TextFormField(
                    controller: nimCtrl,
                    decoration: const InputDecoration(
                      labelText: "NIM",
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      usernameCtrl.text = value; // ✅ username = NIM
                    },
                    validator: (v) =>
                        v!.isEmpty ? "NIM required" : null,
                  ),
                  const SizedBox(height: 14),

                  // PRODI
                  TextFormField(
                    controller: prodiCtrl,
                    decoration: const InputDecoration(
                      labelText: "Prodi",
                      prefixIcon: Icon(Icons.school),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Prodi required" : null,
                  ),
                  const SizedBox(height: 14),

                  // PASSWORD
                  TextFormField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (v) =>
                        v!.length < 6 ? "Minimum 6 characters" : null,
                  ),
                  const SizedBox(height: 20),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : const Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        color: Color(0xFF667EEA),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
=======
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  _colorAnimation.value ?? const Color(0xFFF0F8FF),
>>>>>>> 02ae15b6b4125cadb747b4770eaa8ed77f698c2c
                ],
              ),
            ),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              // Floating decorative books
              _buildFloatingBook(
                left: 30,
                top: 100,
                color: Colors.blue.shade400,
                size: 35,
              ),
              _buildFloatingBook(
                left: MediaQuery.of(context).size.width - 70,
                top: 150,
                color: Colors.green.shade400,
                size: 30,
              ),
              _buildFloatingBook(
                left: 50,
                top: MediaQuery.of(context).size.height - 200,
                color: Colors.orange.shade400,
                size: 40,
              ),
              _buildFloatingBook(
                left: MediaQuery.of(context).size.width - 80,
                top: MediaQuery.of(context).size.height - 250,
                color: Colors.purple.shade400,
                size: 28,
              ),
              
              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo section dengan GAIRMOS LIBRARY
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 1000),
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFF3498DB).withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Animated book icon
                                _buildAnimatedBookIcon(),
                                
                                // Success indicator
                                Positioned(
                                  right: 10,
                                  bottom: 10,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                                      CurvedAnimation(
                                        parent: _controller,
                                        curve: const Interval(0.8, 1.0),
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(0.5),
                                            blurRadius: 15,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // ✅ GAIRMOS LIBRARY Text dengan animasi (sama seperti Login Page)
                            AnimatedOpacity(
                              opacity: _textOpacityAnimation.value,
                              duration: const Duration(milliseconds: 800),
                              child: Column(
                                children: [
                                  Text(
                                    "GAIRMOS LIBRARY",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF2C3E50),
                                      letterSpacing: 1.2,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Daftar Akun Baru",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Register form
                        Material(
                          elevation: 25,
                          borderRadius: BorderRadius.circular(25),
                          shadowColor: const Color(0xFF3498DB).withOpacity(0.2),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: double.infinity,
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  const Color(0xFFF8FAFF),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Form header
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF2C3E50),
                                              Color(0xFF3498DB),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF3498DB).withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.app_registration_rounded,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Formulir Pendaftaran",
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF2C3E50),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "Lengkapi data di bawah ini",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 30),
                                  
                                  // Nama Lengkap
                                  _buildTextField(
                                    controller: namaCtrl,
                                    focusNode: _namaFocusNode,
                                    label: "Nama Lengkap",
                                    icon: Icons.person_outline_rounded,
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: () => _emailFocusNode.requestFocus(),
                                    validator: (v) => v!.isEmpty ? "Nama lengkap wajib diisi" : null,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Email
                                  _buildTextField(
                                    controller: emailCtrl,
                                    focusNode: _emailFocusNode,
                                    label: "Email",
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: () => _nimFocusNode.requestFocus(),
                                    validator: (v) {
                                      if (v!.isEmpty) return "Email wajib diisi";
                                      if (!v.contains("@") || !v.contains(".")) {
                                        return "Format email tidak valid";
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // NIM
                                  _buildTextField(
                                    controller: nimCtrl,
                                    focusNode: _nimFocusNode,
                                    label: "NIM",
                                    icon: Icons.numbers_rounded,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: () => _prodiFocusNode.requestFocus(),
                                    validator: (v) => v!.isEmpty ? "NIM wajib diisi" : null,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Prodi
                                  _buildTextField(
                                    controller: prodiCtrl,
                                    focusNode: _prodiFocusNode,
                                    label: "Program Studi",
                                    icon: Icons.school_outlined,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: () => _angkatanFocusNode.requestFocus(),
                                    validator: (v) => v!.isEmpty ? "Program studi wajib diisi" : null,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Angkatan
                                  _buildTextField(
                                    controller: angkatanCtrl,
                                    focusNode: _angkatanFocusNode,
                                    label: "Angkatan",
                                    icon: Icons.calendar_today_outlined,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: () => _passwordFocusNode.requestFocus(),
                                    validator: (v) {
                                      if (v!.isEmpty) return "Angkatan wajib diisi";
                                      if (v.length != 4) return "Gunakan format 4 digit";
                                      if (int.tryParse(v) == null) return "Harus berupa angka";
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Password
                                  _buildTextField(
                                    controller: passCtrl,
                                    focusNode: _passwordFocusNode,
                                    label: "Password",
                                    icon: Icons.lock_outline_rounded,
                                    keyboardType: TextInputType.visiblePassword,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: register,
                                    validator: (v) => v!.length < 6 ? "Minimal 6 karakter" : null,
                                    isPassword: true,
                                    obscureText: obscurePass,
                                    onToggleObscure: () {
                                      setState(() => obscurePass = !obscurePass);
                                    },
                                  ),
                                  
                                  const SizedBox(height: 30),
                                  
                                  // Register button
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: loading
                                            ? [Colors.grey[400]!, Colors.grey[500]!]
                                            : [
                                                const Color(0xFF2C3E50),
                                                const Color(0xFF3498DB),
                                              ],
                                      ),
                                      boxShadow: loading
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: const Color(0xFF2C3E50).withOpacity(0.4),
                                                blurRadius: 15,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(15),
                                      child: InkWell(
                                        onTap: loading ? null : register,
                                        borderRadius: BorderRadius.circular(15),
                                        splashColor: Colors.white.withOpacity(0.3),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            AnimatedOpacity(
                                              opacity: loading ? 0 : 1,
                                              duration: const Duration(milliseconds: 200),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "DAFTAR SEKARANG",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.white,
                                                      letterSpacing: 1.2,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  AnimatedContainer(
                                                    duration: const Duration(milliseconds: 300),
                                                    transform: Matrix4.translationValues(
                                                      loading ? 20 : 0,
                                                      0,
                                                      0,
                                                    ),
                                                    child: const Icon(
                                                      Icons.arrow_forward_rounded,
                                                      color: Colors.white,
                                                      size: 22,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (loading)
                                              const SizedBox(
                                                width: 26,
                                                height: 26,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 3,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 25),
                                  
                                  // Divider
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey[300],
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        child: Text(
                                          "atau",
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey[300],
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 25),
                                  
                                  // Login button
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF3498DB),
                                        width: 2,
                                      ),
                                      color: Colors.transparent,
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (_, __, ___) => const LoginPage(),
                                              transitionsBuilder: (_, animation, __, child) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                              transitionDuration: const Duration(milliseconds: 500),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        splashColor: const Color(0xFF3498DB).withOpacity(0.1),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.login_rounded,
                                              color: Color(0xFF3498DB),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "SUDAH PUNYA AKUN? MASUK",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF3498DB),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                      ],
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
}