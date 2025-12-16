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

  String safeDate(dynamic value) {
    if (value == null) return "-";
    try {
      return value.toString().substring(0, 10);
    } catch (_) {
      return value.toString();
    }
  }

  bool isPastReturn(Map<String, dynamic> item) {
    final tanggalUsulan = item["tanggal_pengembalian_dipilih"];
    if (tanggalUsulan == null) return false;
    try {
      final limit =
          DateTime.parse(tanggalUsulan).add(const Duration(hours: 23, minutes: 59));
      return DateTime.now().isAfter(limit);
    } catch (_) {
      return false;
    }
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
        final List<dynamic> allLoans = jsonData["data"] ?? [];

        final filteredLoans = allLoans.where((item) {
          final status = item["status_pinjam"];
          if (status == "menunggu_persetujuan" ||
              status == "dipinjam" ||
              status == "pengajuan_kembali") {
            return true;
          }

          if (status == "dikembalikan") {
            return !isPastReturn(item);
          }

          return false;
        }).toList();

        setState(() {
          peminjamanList = filteredLoans;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetch peminjaman: $e");
      setState(() => isLoading = false);
    }
  }

  Map<String, dynamic> getStatusInfo(Map<String, dynamic> item) {
    final status = item["status_pinjam"];
    switch (status) {
      case "menunggu_persetujuan":
        return {
          "label": "Menunggu Persetujuan",
          "color": Colors.orange,
          "icon": Icons.hourglass_top
        };
      case "dipinjam":
        return {
          "label": "Sedang Dipinjam",
          "color": Colors.blue,
          "icon": Icons.book
        };
      case "pengajuan_kembali":
        return {
          "label": "Pengembalian Diajukan",
          "color": Colors.green,
          "icon": Icons.assignment_turned_in
        };
      case "dikembalikan":
        return {
          "label": "Sudah Dikembalikan",
          "color": Colors.grey,
          "icon": Icons.history
        };
      default:
        return {
          "label": status ?? "-",
          "color": Colors.red,
          "icon": Icons.error
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Peminjaman"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryPeminjamanPage()),
              );
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : peminjamanList.isEmpty
              ? const Center(child: Text("Tidak ada data peminjaman"))
              : RefreshIndicator(
                  onRefresh: fetchPeminjaman,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: peminjamanList.length,
                    itemBuilder: (context, index) =>
                        _loanCard(peminjamanList[index]),
                  ),
                ),
    );
  }

  Widget _loanCard(Map<String, dynamic> item) {
    final statusInfo = getStatusInfo(item);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PeminjamanDetailPage(item: item),
            ),
          );
          if (result == true) fetchPeminjaman();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(
                  item["judul_buku"] ?? "-",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusInfo["color"].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  Icon(statusInfo["icon"],
                      size: 14, color: statusInfo["color"]),
                  const SizedBox(width: 6),
                  Text(
                    statusInfo["label"],
                    style: TextStyle(
                        fontSize: 12,
                        color: statusInfo["color"],
                        fontWeight: FontWeight.w600),
                  ),
                ]),
              )
            ]),
            const SizedBox(height: 12),
            _infoRow(Icons.person, "Peminjam", item["nama_user"]),
            _infoRow(Icons.date_range, "Tanggal Pinjam",
                safeDate(item["tanggal_pinjam"])),
            _infoRow(Icons.event, "Jatuh Tempo",
                safeDate(item["tanggal_jatuh_tempo"])),
            const Divider(height: 24),
            _infoRow(Icons.assignment_return, "Tanggal Pengembalian",
                safeDate(item["tanggal_pengembalian_dipilih"])),
          ]),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text("$label: ",
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Expanded(
          child: Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}
