import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'history_detail_peminjaman_page.dart';

class HistoryPeminjamanPage extends StatefulWidget {
  const HistoryPeminjamanPage({super.key});

  @override
  State<HistoryPeminjamanPage> createState() => _HistoryPeminjamanPageState();
}

class _HistoryPeminjamanPageState extends State<HistoryPeminjamanPage> {
  List<dynamic> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() => isLoading = true);

    try {
      // Panggil API
      final data = await ApiService.getHistoryAdmin();

      // Debug: lihat respon dari backend
      print("History admin response: $data");

      // Simpan data ke state
      setState(() {
        history = data;
        isLoading = false;
      });
    } catch (e) {
      // Debug error jika gagal
      print("Error load history: $e");

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil data history")),
      );
    }
  }


  Color _statusColor(String status) {
    switch (status) {
      case "selesai":
        return Colors.green;
      case "terlambat":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "selesai":
        return Icons.check_circle;
      case "terlambat":
        return Icons.warning;
      default:
        return Icons.timelapse;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "History Peminjaman",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? const Center(child: Text("Belum ada riwayat peminjaman"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final status = item["status_pinjam"] ?? "aktif";

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                HistoryDetailPeminjamanPage(item: item),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// ===== JUDUL =====
                              Text(
                                item["judul_buku"] ?? "-",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),

                              /// ===== PEMINJAM =====
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item["nama_user"] ?? "-",
                                      style:
                                          const TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),

                              const Divider(height: 20),

                              /// ===== TANGGAL =====
                              _infoRow(
                                Icons.login,
                                "Tgl Pinjam",
                                item["tanggal_pinjam"],
                              ),
                              _infoRow(
                                Icons.event,
                                "Jatuh Tempo",
                                item["tanggal_jatuh_tempo"],
                              ),
                              _infoRow(
                                Icons.logout,
                                "Tgl Kembali",
                                item["tanggal_kembali"] ?? "-",
                              ),

                              const SizedBox(height: 12),

                              /// ===== STATUS =====
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(status)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _statusIcon(status),
                                        size: 16,
                                        color: _statusColor(status),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          color: _statusColor(status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            "$label : ",
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
