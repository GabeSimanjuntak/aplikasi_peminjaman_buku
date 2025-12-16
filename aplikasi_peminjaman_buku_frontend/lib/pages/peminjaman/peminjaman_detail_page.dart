import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class PeminjamanDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const PeminjamanDetailPage({super.key, required this.item});

  @override
  State<PeminjamanDetailPage> createState() => _PeminjamanDetailPageState();
}

class _PeminjamanDetailPageState extends State<PeminjamanDetailPage> {
  final String baseUrl = "http://10.0.2.2:8000/api";
  late Map<String, dynamic> item;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    item = Map<String, dynamic>.from(widget.item);
  }

  /// Cek apakah tanggal pengembalian sudah lewat
  bool isPastReturn() {
    final tanggalStr = item["tanggal_pengembalian_dipilih"];
    if (tanggalStr == null) return false;
    try {
      final dueDate = DateTime.parse(tanggalStr).add(const Duration(hours: 23, minutes: 59));
      return DateTime.now().isAfter(dueDate);
    } catch (_) {
      return false;
    }
  }

  /// Setujui peminjaman
  Future<void> approvePeminjaman(int id) async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.post(
      Uri.parse("$baseUrl/peminjaman/$id/konfirmasi"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      setState(() {
        item["status_pinjam"] = "dipinjam";
      });
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal konfirmasi: ${res.body}"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  /// Setujui pengembalian
  Future<void> approvePengembalian(int id) async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.put(
      Uri.parse("$baseUrl/peminjaman/$id/approve-pengembalian"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      setState(() {
        item["status_pinjam"] = "menunggu_pengembalian";
      });
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal approve pengembalian: ${res.body}"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  /// ==================== LOGIC STATUS ====================
  String displayStatus() {
    final status = item["status_pinjam"];
    final pengembalian = item["tanggal_pengembalian_dipilih"];
    DateTime? returnDate;
    if (pengembalian != null) {
      returnDate = DateTime.parse(pengembalian);
    }

    // Jika sudah dikembalikan / disetujui pengembalian
    if (status == "dikembalikan" || status == "pengembalian_disetujui") {
      if (returnDate != null && !DateTime.now().isBefore(returnDate)) {
        // hari ini atau sudah lewat → Sudah Dikembalikan
        return "Sudah Dikembalikan";
      } else {
        // belum lewat → Menunggu Pengembalian
        return "Menunggu Pengembalian";
      }
    }

    switch (status) {
      case "menunggu_persetujuan":
        return "Menunggu Persetujuan";
      case "dipinjam":
        return "Sedang Dipinjam";
      case "pengajuan_kembali":
        return "Pengajuan Pengembalian";
      case "menunggu_pengembalian":
        return "Menunggu Pengembalian";
      default:
        return status ?? "-";
    }
  }

  Color displayColor() {
    switch (displayStatus()) {
      case "Menunggu Persetujuan":
        return Colors.orange;
      case "Sedang Dipinjam":
        return Colors.blue;
      case "Pengajuan Pengembalian":
        return Colors.purple;
      case "Menunggu Pengembalian":
        return Colors.deepOrange;
      case "Sudah Dikembalikan":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pengembalianDipilih = item["tanggal_pengembalian_dipilih"];

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
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF3498DB),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // =================== CARD INFO ===================
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["judul_buku"] ?? "-",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _infoRow("Peminjam", item["nama_user"]),
                            _infoRow("Tanggal Pinjam", item["tanggal_pinjam"]),
                            _infoRow("Jatuh Tempo", item["tanggal_jatuh_tempo"]),
                            if (pengembalianDipilih != null)
                              _infoRow(
                                "Usulan Pengembalian",
                                pengembalianDipilih.substring(0, 10),
                              ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: displayColor().withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Status: ${displayStatus()}",
                                    style: TextStyle(
                                      color: displayColor(),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ==================== ACTION BUTTONS ====================
                    if (displayStatus() == "Menunggu Persetujuan")
                      _actionButton(
                        text: "Konfirmasi Peminjaman",
                        color: const Color(0xFF3498DB),
                        onPressed: () => approvePeminjaman(item["id_peminjaman"]),
                      ),

                    if (displayStatus() == "Pengajuan Pengembalian")
                      _actionButton(
                        text: "Setujui Pengembalian",
                        color: const Color(0xFF2C3E50),
                        onPressed: () => approvePengembalian(item["id_peminjaman"]),
                      ),

                    if (displayStatus() == "Menunggu Pengembalian")
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.deepOrange.withOpacity(0.3)),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.deepOrange,
                              size: 36,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Pengembalian sudah disetujui\nMenunggu tanggal pengembalian...",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (displayStatus() == "Sudah Dikembalikan")
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.check_circle_outlined,
                              color: Colors.green,
                              size: 36,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "✔ Buku sudah dikembalikan",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  // ==================== WIDGET HELPER ====================
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C3E50),
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}