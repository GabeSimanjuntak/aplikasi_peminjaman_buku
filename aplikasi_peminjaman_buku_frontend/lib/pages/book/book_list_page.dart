import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class BookListPage extends StatefulWidget {
  final int? userId;
  const BookListPage({Key? key, this.userId}) : super(key: key);

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  bool loading = true;
  List<dynamic> books = [];

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    setState(() => loading = true);
    try {
      final data = await ApiService.getBooks();
      setState(() {
        books = data;
      });
    } catch (e) {
      // ignore errors for now
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> pinjamBuku(int idBuku) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = widget.userId ?? prefs.getInt("user_id");
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID tidak ditemukan")),
      );
      return;
    }

    final body = {
      "id_user": uid.toString(),
      "id_buku": idBuku.toString(),
      "tgl_pinjam": DateTime.now().toString().substring(0, 10),
    };

    final res = await ApiService.createPeminjaman(body);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"] ?? "Peminjaman: respon tidak diketahui")),
    );

    await loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Buku")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const Center(child: Text("Tidak ada buku"))
              : RefreshIndicator(
                  onRefresh: loadBooks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: books.length,
                    itemBuilder: (context, i) {
                      final b = books[i];
                      final judul = b['judul'] ?? "-";
                      final penulis = b['penulis'] ?? "-";
                      final stok = (b['stok'] ?? 0);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(judul),
                          subtitle: Text("Penulis: $penulis\nStok: $stok"),
                          isThreeLine: true,
                          trailing: stok > 0
                              ? ElevatedButton(
                                  onPressed: () => pinjamBuku(b['id']),
                                  child: const Text("Pinjam"),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade300,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text("Stok Habis", style: TextStyle(color: Colors.white)),
                                ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
