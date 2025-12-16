import 'package:aplikasi_peminjaman_buku_frontend/pages/history/history_peminjaman_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import 'book/book_list_page.dart';
import 'kategori/kategori_list_page.dart';
import 'peminjaman/peminjaman_list_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard Admin",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2C3E50),
                Color(0xFF3498DB),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5F9FF),
              Color(0xFFE8F0F7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Selamat Datang, Admin!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Kelola perpustakaan digital dengan mudah",
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF2C3E50).withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 40),
              
              Row(
                children: [
                  _buildCard(Icons.book, "Kelola Buku", const Color(0xFF3498DB), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BookListPage()),
                    );
                  }),
                  _buildCard(Icons.category, "Kategori Buku", const Color(0xFFF39C12), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => KategoriListPage()),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  _buildCard(Icons.history, "Kelola Peminjaman", const Color(0xFF2ECC71), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PeminjamanListPage()),
                    );
                  }),
                  _buildCard(Icons.person, "History Peminjaman", const Color(0xFF9B59B6), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryPeminjamanPage()),
                    );
                  }),
                ],
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString("token");

                  if (token != null) {
                    await ApiService.logout(token);
                  }

                  await prefs.clear();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Keluar dari Aplikasi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}