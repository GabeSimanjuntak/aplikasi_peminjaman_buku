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
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    // Hitung status pengembalian
    String statusPengembalian = "-";
    String keterangan = "-";

    if (item["tanggal_kembali"] != null &&
        item["tanggal_jatuh_tempo"] != null) {
      DateTime tanggalKembali = DateTime.parse(item["tanggal_kembali"]);
      DateTime tanggalJatuhTempo = DateTime.parse(item["tanggal_jatuh_tempo"]);

      if (tanggalKembali.isAfter(tanggalJatuhTempo)) {
        statusPengembalian = "Terlambat";
        int selisihHari = tanggalKembali.difference(tanggalJatuhTempo).inDays;
        keterangan = "Terlambat $selisihHari hari";
      } else {
        statusPengembalian = "Tepat Waktu";
        keterangan = "-";
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Peminjaman"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul Buku
                Text(
                  item["judul_buku"] ?? "-",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Detail Peminjaman
                _buildRow("Peminjam", item["nama_user"]),
                const SizedBox(height: 6),
                _buildRow(
                    "Tanggal Pinjam", _formatTanggal(item["tanggal_pinjam"])),
                const SizedBox(height: 6),
                _buildRow(
                    "Jatuh Tempo", _formatTanggal(item["tanggal_jatuh_tempo"])),
                const SizedBox(height: 6),
                _buildRow(
                    "Tanggal Kembali", _formatTanggal(item["tanggal_kembali"])),
                const SizedBox(height: 12),

                // Status Pengembalian dengan warna
                Row(
                  children: [
                    Text(
                      "Status Pengembalian: ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 10),
                      decoration: BoxDecoration(
                        color: _statusColor(statusPengembalian)
                            .withOpacity(0.2),
                        border: Border.all(
                            color: _statusColor(statusPengembalian)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusPengembalian,
                        style: TextStyle(
                          color: _statusColor(statusPengembalian),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Keterangan
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Keterangan: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Flexible(
                      child: Text(keterangan),
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

  Widget _buildRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Flexible(child: Text(value)),
      ],
    );
  }
}
