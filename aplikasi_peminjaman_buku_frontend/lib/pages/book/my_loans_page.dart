import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MyLoansPage extends StatefulWidget {
  final int? userId;
  const MyLoansPage({Key? key, this.userId}) : super(key: key);

  @override
  State<MyLoansPage> createState() => _MyLoansPageState();
}

class _MyLoansPageState extends State<MyLoansPage> {
  List<dynamic> history = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() => loading = true);
    try {
      // ApiService.getHistory uses ApiService.authToken (make sure ApiService.loadToken() was called on login)
      final data = await ApiService.getHistory();
      // filter by user id if available
      final uid = widget.userId;
      if (uid != null) {
        history = data.where((h) {
          // common keys: 'id_user' or 'user_id' or nested. handle both
          final idUser = h['id_user'] ?? h['user_id'] ?? h['user']?['id'];
          if (idUser == null) return false;
          return idUser.toString() == uid.toString();
        }).toList();
      } else {
        history = data;
      }
    } catch (e) {
      history = [];
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> refresh() async {
    await loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Peminjaman")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? const Center(child: Text("Belum ada riwayat peminjaman"))
              : RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: history.length,
                    itemBuilder: (context, i) {
                      final h = history[i];
                      final judul = h['judul_buku'] ?? h['buku']?['judul'] ?? h['judul'] ?? "-";
                      final status = h['status'] ?? h['keterangan'] ?? "-";
                      final tgl = h['tgl_pinjam'] ?? h['created_at'] ?? "-";
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(judul),
                          subtitle: Text("Tanggal: $tgl\nStatus: $status"),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
