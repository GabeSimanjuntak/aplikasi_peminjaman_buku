import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class UserLoansPage extends StatefulWidget {
  const UserLoansPage({super.key});

  @override
  State<UserLoansPage> createState() => _UserLoansPageState();
}

class _UserLoansPageState extends State<UserLoansPage> {
  List<dynamic> loans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  // Fungsi reload untuk "Pull to Refresh"
  Future<void> _loadLoans() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("user_id");

    if (userId != null) {
      try {
        final data = await ApiService.getLoanHistoryUser(userId);
        setState(() {
          // Kita balik urutannya biar yang terbaru ada di atas
          loans = data.reversed.toList();
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _loadLoans,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : loans.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: loans.length,
                    itemBuilder: (context, index) {
                      final item = loans[index];
                      // Menangani null safety jika buku sudah dihapus admin
                      final judulBuku = item['buku'] != null ? item['buku']['judul'] : 'Buku dihapus';
                      final String status = item['status_pinjam'] ?? 'unknown';

                      return _buildLoanCard(item, judulBuku, status);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_edu, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text("Belum ada riwayat peminjaman.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLoanCard(Map item, String judul, String status) {
    // Tentukan warna berdasarkan status
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (status == 'aktif') {
      statusColor = Colors.orange;
      statusLabel = "Sedang Dipinjam";
      statusIcon = Icons.timer;
    } else if (status == 'selesai') {
      statusColor = Colors.green;
      statusLabel = "Dikembalikan";
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.red;
      statusLabel = status.toUpperCase();
      statusIcon = Icons.error;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    judul,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn("Tanggal Pinjam", item['tanggal_pinjam']),
                _buildInfoColumn("Jatuh Tempo", item['tanggal_jatuh_tempo']),
                // Jika sudah kembali, tampilkan tanggal kembali
                if (item['tanggal_kembali'] != null)
                   _buildInfoColumn("Dikembalikan", item['tanggal_kembali']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value ?? "-", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}