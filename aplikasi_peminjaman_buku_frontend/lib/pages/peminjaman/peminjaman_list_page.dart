import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PeminjamanListPage extends StatefulWidget {
  const PeminjamanListPage({super.key});

  @override
  State<PeminjamanListPage> createState() => _PeminjamanListPageState();
}

class _PeminjamanListPageState extends State<PeminjamanListPage> {
  late Future<List<dynamic>> peminjamanList;

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  void refreshList() {
    peminjamanList = ApiService.getPeminjamanAktif();
    setState(() {});
  }

  void kembalikan(int idPeminjaman) async {
    final res = await ApiService.kembalikanBuku(idPeminjaman);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res["message"]),
        backgroundColor: res["success"] ? Colors.green : Colors.red,
      ),
    );

    if (res["success"]) refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Peminjaman")),
      body: FutureBuilder(
        future: peminjamanList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada peminjaman"));
          }

          final data = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (_, i) {
              final p = data[i];

              return Card(
                child: ListTile(
                  title: Text(p["judul_buku"]),
                  subtitle: Text(
                    "Peminjam: ${p["nama_user"]}\n"
                    "Jatuh Tempo: ${p["tanggal_jatuh_tempo"]}",
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => kembalikan(p["id_peminjaman"]),
                    child: const Text("Kembalikan"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
