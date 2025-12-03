import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'peminjaman_detail_page.dart';
import '../history/history_peminjaman_page.dart';

class PeminjamanListPage extends StatefulWidget {
  const PeminjamanListPage({super.key});

  @override
  State<PeminjamanListPage> createState() => _PeminjamanListPageState();
}

class _PeminjamanListPageState extends State<PeminjamanListPage> {
  List<dynamic> peminjamanList = [];
  bool isLoading = true;
  final String baseUrl = "http://10.0.2.2:8000/api";

  @override
  void initState() {
    super.initState();
    fetchPeminjaman();
  }

  Future<void> fetchPeminjaman() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("$baseUrl/peminjaman"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          peminjamanList = (jsonData["data"] ?? [])
              .where((e) =>
                  e["status_pinjam"] == "aktif" ||
                  e["status_pinjam"] == "disetujui")
              .toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetch peminjaman: $e");
    }
  }

  Future<void> approvePeminjaman(int id) async {
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
          final idx = peminjamanList.indexWhere((e) => e["id_peminjaman"] == id);
          if (idx != -1) {
            peminjamanList[idx]["status_pinjam"] = "disetujui";
            peminjamanList[idx]["is_approved"] = true;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Peminjaman disetujui!")),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Gagal approve")));
      }
    } catch (e) {
      print("Error approve: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Terjadi error: $e")));
    }
  }

  Future<void> pengembalianPeminjaman(Map<String, dynamic> item) async {
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
        body: jsonEncode({"id_peminjaman": item["id_peminjaman"]}),
      );

      if (response.statusCode == 200) {
        final tanggalJatuhTempo = DateTime.parse(item['tanggal_jatuh_tempo']);
        final tanggalSekarang = DateTime.now();
        bool terlambat = tanggalSekarang.isAfter(tanggalJatuhTempo);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(terlambat
                ? "Pengembalian berhasil! Status: TERLAMBAT"
                : "Pengembalian berhasil! Status: TEPAT WAKTU"),
          ),
        );

        setState(() {
          peminjamanList.removeWhere(
              (e) => e["id_peminjaman"] == item["id_peminjaman"]);
        });
      } else {
        final resBody = jsonDecode(response.body);
        final message = resBody['message'] ?? 'Gagal melakukan pengembalian';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      print("Error pengembalian: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Terjadi error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Peminjaman"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Lihat History",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryPeminjamanPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : peminjamanList.isEmpty
              ? const Center(
                  child: Text("Tidak ada data peminjaman aktif",
                      style: TextStyle(fontSize: 16)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: peminjamanList.length,
                  itemBuilder: (context, index) {
                    final item = peminjamanList[index];
                    final isApproved = item['status_pinjam'] == "disetujui";

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final updatedItem = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PeminjamanDetailPage(item: item),
                            ),
                          );

                          if (updatedItem != null && updatedItem is Map<String, dynamic>) {
                            setState(() {
                              if (updatedItem["status_pinjam"] == "selesai") {
                                peminjamanList.removeWhere(
                                    (e) => e["id_peminjaman"] == updatedItem["id_peminjaman"]);
                              } else {
                                final idx = peminjamanList.indexWhere(
                                    (e) => e["id_peminjaman"] == updatedItem["id_peminjaman"]);
                                if (idx != -1) peminjamanList[idx] = updatedItem;
                              }
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["judul_buku"] ?? "Judul tidak tersedia",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text("Peminjam: ${item['nama_user'] ?? '-'}"),
                              Text("Tanggal Pinjam: ${item['tanggal_pinjam'] ?? '-'}"),
                              Text("Jatuh Tempo: ${item['tanggal_jatuh_tempo'] ?? '-'}"),
                              const SizedBox(height: 4),
                              Text(
                                "Status: ${item['status_pinjam']}",
                                style: TextStyle(
                                  color: isApproved ? Colors.blue : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (!isApproved)
                                    ElevatedButton(
                                      onPressed: () =>
                                          approvePeminjaman(item["id_peminjaman"]),
                                      child: const Text("Approve"),
                                    ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    onPressed: isApproved
                                        ? () => pengembalianPeminjaman(item)
                                        : null,
                                    child: const Text(
                                      "Kembalikan",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
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
}
