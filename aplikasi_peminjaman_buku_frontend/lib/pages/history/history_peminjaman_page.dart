import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class HistoryPeminjamanPage extends StatefulWidget {
  const HistoryPeminjamanPage({super.key});

  @override
  State<HistoryPeminjamanPage> createState() => _HistoryPeminjamanPageState();
}

class _HistoryPeminjamanPageState extends State<HistoryPeminjamanPage> {
  List history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final data = await ApiService.getHistory();
      setState(() {
        history = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil data: $e")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History Peminjaman"),
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

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["judul_buku"] ?? "-",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text("Peminjam : ${item["nama_user"]}"),
                            Text("Tgl Pinjam : ${item["tanggal_pinjam"]}"),
                            Text("Jatuh Tempo : ${item["tanggal_jatuh_tempo"]}"),
                            Text("Tgl Kembali : ${item["tanggal_kembali"] ?? '-'}"),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 10),
                              decoration: BoxDecoration(
                                color: _statusColor(item["status_pinjam"])
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _statusColor(item["status_pinjam"]),
                                ),
                              ),
                              child: Text(
                                item["status_pinjam"].toUpperCase(),
                                style: TextStyle(
                                  color: _statusColor(item["status_pinjam"]),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
