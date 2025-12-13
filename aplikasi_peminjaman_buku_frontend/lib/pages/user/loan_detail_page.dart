import 'package:flutter/material.dart';

class LoanDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const LoanDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final judul = item['judul_buku']?.toString() ?? '-';
    final penulis = item['penulis']?.toString() ?? '-';
    final kategori = item['kategori']?.toString() ?? '-';
    final tanggalPinjam = item['tanggal_pinjam']?.toString() ?? '-';
    final jatuhTempo = item['tanggal_jatuh_tempo']?.toString() ?? '-';
    final tanggalPengembalian = item['tanggal_pengembalian_dipilih']?.toString() ?? '-';
    final status = item['status_pengembalian'] ?? item['status_pinjam'];
    final catatan = item['catatan']?.toString() ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Peminjaman"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // JUDUL BUKU
            Text(
              judul,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _info("Penulis", penulis),
            _info("Kategori", kategori),

            const Divider(height: 30),

            _info("Tanggal Pinjam", tanggalPinjam),
            _info("Jatuh Tempo", jatuhTempo),
            _info("Tanggal Pengembalian yang Dipilih", tanggalPengembalian),

            const Divider(height: 30),

            _statusBox(status),

            const SizedBox(height: 20),

            _info("Catatan", catatan),
          ],
        ),
      ),
    );
  }

  // Widget informasi
  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // Widget status
  Widget _statusBox(String status) {
    Color color;
    String label;

    switch (status) {
      case 'menunggu_persetujuan':
        color = Colors.orange;
        label = 'Menunggu Persetujuan';
        break;

      case 'pengajuan_kembali':
        color = Colors.green;
        label = 'Pengembalian Diajukan';
        break;

      case 'dikembalikan':
        color = Colors.grey;
        label = 'Sudah Dikembalikan';
        break;

      default:
        color = Colors.blue;
        label = 'Sedang Dipinjam';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
