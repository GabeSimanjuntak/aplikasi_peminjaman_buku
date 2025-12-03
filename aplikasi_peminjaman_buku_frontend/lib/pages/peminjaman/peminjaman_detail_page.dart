import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../history/history_peminjaman_page.dart';

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

  Future<void> approvePeminjaman(int id) async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.put(
        Uri.parse("$baseUrl/peminjaman/$id/approve"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          item["status_pinjam"] = "disetujui";
          item["is_approved"] = true;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Peminjaman disetujui!")));
        Navigator.pop(context, item);
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Gagal approve")));
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error approve: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Terjadi error: $e")));
    }
  }

  Future<void> pengembalianPeminjaman(int id) async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("$baseUrl/pengembalian"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"id_peminjaman": id}),
      );

      if (response.statusCode == 200) {
        final tanggalJatuhTempo = DateTime.parse(item['tanggal_jatuh_tempo']);
        final tanggalSekarang = DateTime.now();
        final terlambat = tanggalSekarang.isAfter(tanggalJatuhTempo);

        setState(() {
          item["status_pinjam"] = "selesai";
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(terlambat
                ? "Pengembalian berhasil! Status: TERLAMBAT"
                : "Pengembalian berhasil! Status: TEPAT WAKTU"),
          ),
        );

        Navigator.pop(context, item);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HistoryPeminjamanPage(),
          ),
        );
      } else {
        final resBody = jsonDecode(response.body);
        final message = resBody['message'] ?? 'Gagal melakukan pengembalian';
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error pengembalian: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Terjadi error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Peminjaman")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["judul_buku"] ?? "-",
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      detailRow("ID Peminjaman", item["id_peminjaman"].toString()),
                      detailRow("Nama Peminjam", item["nama_user"]),
                      detailRow("Tanggal Pinjam", item["tanggal_pinjam"] ?? "-"),
                      detailRow("Jatuh Tempo", item["tanggal_jatuh_tempo"]),
                      detailRow(
                        "Status",
                        item["status_pinjam"],
                        valueColor: item["status_pinjam"] == "aktif"
                            ? Colors.orange
                            : item["status_pinjam"] == "disetujui"
                                ? Colors.blue
                                : Colors.green,
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          if (item["status_pinjam"] == "aktif")
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () =>
                                    approvePeminjaman(item["id_peminjaman"]),
                                style: ElevatedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14)),
                                child: const Text(
                                  "Approve Peminjaman",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          if (item["status_pinjam"] == "disetujui")
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () =>
                                    pengembalianPeminjaman(item["id_peminjaman"]),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text(
                                  "Kembalikan Buku",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          if (item["status_pinjam"] == "selesai")
                            const Text(
                              "Buku sudah dikembalikan",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
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

  Widget detailRow(String title, String? value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value ?? "-", style: TextStyle(fontSize: 16, color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }
}
