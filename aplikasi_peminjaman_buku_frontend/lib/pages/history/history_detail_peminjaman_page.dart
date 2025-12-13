import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryDetailPeminjamanPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const HistoryDetailPeminjamanPage({super.key, required this.item});

  String _formatTanggal(String? tanggal) {
    if (tanggal == null) return "-";
    try {
      DateTime dt = DateTime.parse(tanggal);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return tanggal;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Tepat Waktu":
        return Colors.green;
      case "Terlambat":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "Tepat Waktu":
        return Icons.check_circle;
      case "Terlambat":
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    /// ================= HITUNG STATUS =================
    String statusPengembalian = "-";
    String keterangan = "-";

    if (item["tanggal_kembali"] != null &&
        item["tanggal_jatuh_tempo"] != null) {
      DateTime kembali = DateTime.parse(item["tanggal_kembali"]);
      DateTime tempo = DateTime.parse(item["tanggal_jatuh_tempo"]);

      if (kembali.isAfter(tempo)) {
        statusPengembalian = "Terlambat";
        int selisihHari = kembali.difference(tempo).inDays;
        keterangan = "Terlambat $selisihHari hari";
      } else {
        statusPengembalian = "Tepat Waktu";
        keterangan = "Dikembalikan sesuai batas waktu";
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Detail Peminjaman"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===== JUDUL BUKU =====
                Text(
                  item["judul_buku"] ?? "-",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),
                const Divider(),

                /// ===== INFO PEMINJAMAN =====
                _infoRow(Icons.person, "Peminjam", item["nama_user"]),
                _infoRow(Icons.login, "Tanggal Pinjam",
                    _formatTanggal(item["tanggal_pinjam"])),
                _infoRow(Icons.event, "Jatuh Tempo",
                    _formatTanggal(item["tanggal_jatuh_tempo"])),
                _infoRow(Icons.logout, "Tanggal Kembali",
                    _formatTanggal(item["tanggal_kembali"])),

                const SizedBox(height: 16),

                /// ===== STATUS =====
                Row(
                  children: [
                    const Text(
                      "Status Pengembalian",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _statusColor(statusPengembalian).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _statusIcon(statusPengembalian),
                            size: 16,
                            color: _statusColor(statusPengembalian),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusPengembalian,
                            style: TextStyle(
                              color: _statusColor(statusPengembalian),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// ===== KETERANGAN =====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Keterangan : ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        keterangan,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
