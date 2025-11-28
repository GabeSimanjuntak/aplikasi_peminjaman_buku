import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../pages/login_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isLoading = true;
  Map<String, dynamic>? userProfile;
  File? _localPhoto;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("user_id");

    if (userId != null) {
      try {
        final data = await ApiService.getUserProfile(userId);
        setState(() {
          userProfile = data;
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

Future<void> _uploadFoto() async {
    final picker = ImagePicker();
    // 2. Ambil gambar dari galeri
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    // 3. OPTIMISTIC UPDATE: Tampilkan foto lokal langsung agar UI berubah instan
    setState(() {
      _localPhoto = File(picked.path); 
      // Kita set isLoading true HANYA untuk proses background, 
      // tapi gambar sudah berubah di mata user
    });

    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("user_id");

    if (userId == null) return;

    // Kirim ke backend di background
    bool success = await ApiService.updateProfile(
      id: userId,
      filePath: picked.path,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui!")),
      );
      // _loadProfile(); <--- Tidak wajib dipanggil lagi jika kita sudah pakai _localPhoto,
      // tapi boleh dipanggil untuk memastikan data sinkron nanti.
    } else {
      // Jika GAGAL, kembalikan ke foto lama
      setState(() {
        _localPhoto = null; 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengupload foto")),
      );
    }
  }
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Panggil API Logout agar token di server dihapus juga (Best Practice)
    String? token = prefs.getString("token");
    if (token != null) {
      await ApiService.logout(token);
    }

    await prefs.clear(); // Hapus data lokal

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && userProfile == null) {
      // Loading hanya muncul saat pertama kali buka halaman (data kosong)
      return const Center(child: CircularProgressIndicator());
    }

    String? photoUrl = userProfile?['foto'];

    // 4. LOGIKA PENENTUAN GAMBAR (PENTING!)
    // Prioritas 1: Jika user baru pilih foto (_localPhoto ada), pakai itu.
    // Prioritas 2: Jika ada URL dari server, pakai NetworkImage.
    // Prioritas 3: Pakai aset default.
    ImageProvider imageProvider;
    
    if (_localPhoto != null) {
      imageProvider = FileImage(_localPhoto!);
    } else if (photoUrl != null && photoUrl.contains('http')) {
      imageProvider = NetworkImage(photoUrl);
    } else {
      imageProvider = const AssetImage("assets/default_avatar.png");
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      )
                    ],
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: imageProvider, // <--- Gunakan provider yang sudah dipilih di atas
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _uploadFoto,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // === NAMA & EMAIL ===
            Text(
              userProfile?['nama'] ?? "Nama Pengguna",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              userProfile?['email'] ?? "email@contoh.com",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // === INFO CARD ===
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  _buildProfileItem(Icons.person_outline, "Username", userProfile?['username'] ?? "-"),
                  const Divider(height: 1),
                  _buildProfileItem(Icons.badge_outlined, "Role ID", userProfile?['role_id'].toString() ?? "-"),
                  const Divider(height: 1),
                  _buildProfileItem(Icons.date_range, "Bergabung", userProfile?['created_at']?.substring(0, 10) ?? "-"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // === TOMBOL LOGOUT ===
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50], // Warna background merah muda
                  foregroundColor: Colors.red, // Warna text/icon merah
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Keluar Aplikasi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 15),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}