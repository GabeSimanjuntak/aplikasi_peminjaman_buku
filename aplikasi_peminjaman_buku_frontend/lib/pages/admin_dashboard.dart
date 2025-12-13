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
        title: const Text("Dashboard Admin"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                _buildCard(Icons.book, "Kelola Buku", Colors.blue, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BookListPage()),
                  );
                }),
                _buildCard(Icons.category, "Kategori Buku", Colors.orange, () {
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
                _buildCard(Icons.history, "Kelola Peminjaman", Colors.green, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PeminjamanListPage()),
                  );
                }),

                _buildCard(Icons.person, "History Peminjaman", Colors.purple, () {
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
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 16, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
