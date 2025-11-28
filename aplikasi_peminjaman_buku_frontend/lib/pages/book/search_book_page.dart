import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class BookSearchPage extends StatefulWidget {
  final int? userId;
  const BookSearchPage({Key? key, this.userId}) : super(key: key);

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  List<dynamic> allBooks = [];
  List<dynamic> filtered = [];
  bool loading = true;
  TextEditingController ctrl = TextEditingController();
  int? userId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    userId = widget.userId ?? prefs.getInt("user_id");
    await loadBooks();
  }

  Future<void> loadBooks() async {
    setState(() => loading = true);
    try {
      final data = await ApiService.getBooks();
      setState(() {
        allBooks = data;
        filtered = List.from(data);
      });
    } catch (e) {
      // ignore
    } finally {
      setState(() => loading = false);
    }
  }

  void onSearch(String q) {
    final s = q.toLowerCase();
    if (s.isEmpty) {
      setState(() => filtered = List.from(allBooks));
      return;
    }
    setState(() {
      filtered = allBooks.where((b) {
        final judul = (b['judul'] ?? "").toString().toLowerCase();
        final penulis = (b['penulis'] ?? "").toString().toLowerCase();
        final kategori = (b['kategori']?['nama'] ?? "").toString().toLowerCase();
        return judul.contains(s) || penulis.contains(s) || kategori.contains(s);
      }).toList();
    });
  }

  Future<void> pinjam(int idBuku) async {
    final uid = userId;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User ID tidak tersedia")));
      return;
    }
    final body = {
      "id_user": uid.toString(),
      "id_buku": idBuku.toString(),
      "tgl_pinjam": DateTime.now().toString().substring(0, 10),
    };

    final res = await ApiService.createPeminjaman(body);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res["message"] ?? "Respon tidak diketahui")));
    await loadBooks();
    onSearch(ctrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cari Buku")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: ctrl,
              onChanged: onSearch,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Cari judul / penulis / kategori...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          if (loading) const LinearProgressIndicator(),
          Expanded(
            child: filtered.isEmpty && !loading
                ? const Center(child: Text("Tidak ada hasil"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final b = filtered[i];
                      final judul = b['judul'] ?? "-";
                      final penulis = b['penulis'] ?? "-";
                      final stok = (b['stok'] ?? 0);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(judul),
                          subtitle: Text("Penulis: $penulis\nStok: $stok"),
                          isThreeLine: true,
                          trailing: stok > 0
                              ? ElevatedButton(
                                  onPressed: () => pinjam(b['id']),
                                  child: const Text("Pinjam"),
                                )
                              : const Text("Stok Habis"),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
