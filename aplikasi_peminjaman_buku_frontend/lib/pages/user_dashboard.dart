import 'package:flutter/material.dart';
import 'book/book_list_page.dart';
import 'book/book_search_page.dart';
import 'book/my_loans__page.dart';

class UserDashboard extends StatelessWidget {
  final String username;
  final int? userId;

  const UserDashboard({super.key, required this.username, this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Aplikasi Peminjaman Buku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =======================
            // PROFILE HEADER
            // =======================
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade600,
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Halo, $username 👋',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // =======================
            // SEARCH BAR
            // =======================
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookSearchPage(userId: userId),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.blue.shade100),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.06),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.blue.shade400),
                    const SizedBox(width: 10),
                    Text(
                      'Cari...',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =======================
            // GRID MENU
            // =======================
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  _ActionCard(
                    icon: Icons.library_books,
                    title: 'Lihat Buku',
                    subtitle: 'Jelajahi koleksi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookListPage(userId: userId),
                        ),
                      );
                    },
                  ),

                  _ActionCard(
                    icon: Icons.add_shopping_cart,
                    title: 'Peminjaman Buku',
                    subtitle: 'Ajukan peminjaman',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookListPage(userId: userId),
                        ),
                      );
                    },
                  ),

                  _ActionCard(
                    icon: Icons.pending_actions,
                    title: 'Status Peminjaman',
                    subtitle: 'Riwayat & status',
                    onTap: () {
                      if (userId == null) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("User ID tidak ditemukan"),
                            content: const Text(
                              "Pastikan proses login mengirimkan userId ke dashboard.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              )
                            ],
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyLoansPage(userId: userId!),
                        ),
                      );
                    },
                  ),

                  _ActionCard(
                    icon: Icons.person,
                    title: 'Pengembalian Buku',
                    subtitle: 'Status Pengembalian',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur profil belum dibuat'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// CARD COMPONENT
// =======================================================================
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: Icon(icon, color: Colors.blue, size: 22),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
