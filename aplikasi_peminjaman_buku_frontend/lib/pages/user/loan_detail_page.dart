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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Peminjaman",
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3498DB).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF3498DB).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF2C3E50),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            judul,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C3E50),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Penulis: $penulis",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // STATUS BOX
              _statusBox(status),

              const SizedBox(height: 25),

              // INFO SECTION
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "📋 Informasi Peminjaman",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _infoWithIcon(Icons.calendar_today_rounded, "Tanggal Pinjam", tanggalPinjam),
                    const SizedBox(height: 15),
                    _infoWithIcon(Icons.schedule_rounded, "Jatuh Tempo", jatuhTempo),
                    const SizedBox(height: 15),
                    _infoWithIcon(Icons.event_available_rounded, "Tanggal Pengembalian", tanggalPengembalian),
                    const SizedBox(height: 15),
                    _infoWithIcon(Icons.category_rounded, "Kategori", kategori),
                  ],
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  // Widget status dengan styling premium
  Widget _statusBox(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'menunggu_persetujuan':
        color = const Color(0xFFF39C12); // Orange
        label = 'Menunggu Persetujuan';
        icon = Icons.access_time_rounded;
        break;

      case 'pengajuan_kembali':
        color = const Color(0xFF27AE60); // Green
        label = 'Pengembalian Diajukan';
        icon = Icons.check_circle_outline_rounded;
        break;

      case 'dikembalikan':
        color = const Color(0xFF95A5A6); // Grey
        label = 'Sudah Dikembalikan';
        icon = Icons.done_all_rounded;
        break;

      default:
        color = const Color(0xFF3498DB); // Blue
        label = 'Sedang Dipinjam';
        icon = Icons.book_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Status Peminjaman",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget informasi dengan icon
  Widget _infoWithIcon(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF3498DB).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}