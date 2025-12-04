import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../login_page.dart';
import 'dart:convert';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isLoading = true;
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    String? token = prefs.getString('token');

    if (userId == null || token == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final data = await ApiService.getUserProfile(userId);
      print("DEBUG PROFILE DATA: $data");
      setState(() {
        userProfile = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat profil: $e")),
      );
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    File photoFile = File(picked.path);

    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');
      if (userId == null) return;

      final newPhotoUrl = await ApiService.uploadProfilePhoto(userId, photoFile);

      setState(() {
        userProfile?['foto'] = newPhotoUrl;
      });
      await prefs.setString('foto', newPhotoUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto profil berhasil diperbarui")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upload foto: $e")),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) await ApiService.logout(token);
    await prefs.clear();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (userProfile == null) return const Center(child: Text("Gagal memuat data profil"));

    String? photoUrl = userProfile?['foto'];
    String nama = userProfile?['nama'] ?? "-";
    String email = userProfile?['email'] ?? "-";
    String nim = userProfile?['nim'] ?? "-";
    String statusUser = (userProfile?['role_id'] == 1) ? "Admin" : "Mahasiswa";
    String prodi = userProfile?['prodi'] ?? "-";

    ImageProvider imageProvider = (photoUrl != null && photoUrl.contains("http"))
        ? NetworkImage(photoUrl)
        : const AssetImage("assets/default_avatar.png") as ImageProvider;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickAndUploadPhoto,
            child: Stack(
              children: [
                CircleAvatar(radius: 65, backgroundImage: imageProvider),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(nama, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(email, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                _buildProfileItem(Icons.person_outline, "Nama", nama),
                const Divider(height: 1),
                _buildProfileItem(Icons.credit_card, "NIM", nim),
                const Divider(height: 1),
                _buildProfileItem(Icons.school_outlined, "Prodi", prodi),
                const Divider(height: 1),
                _buildProfileItem(Icons.flag_circle_outlined, "Status", statusUser),
                const Divider(height: 1),
                _buildProfileItem(Icons.email_outlined, "Email", email),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout),
              label: const Text("Keluar Aplikasi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
