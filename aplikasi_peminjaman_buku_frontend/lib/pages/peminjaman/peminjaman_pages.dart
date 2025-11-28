import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  bool isLoading = true;
  List<dynamic> books = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("user_id");

    final result = await ApiService.getBooks();

    setState(() {
      books = result;
      isLoading = false;
    });
  }

  Future<void> pinjamBuku(int idBuku) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID tidak ditemukan")),
      );
      return;
    }

    final data = {
      "id_user": userId.toString(),
      "id_buku": idBuku.toString(),
      "tgl_pinjam": DateTime.now().toString().substring(0, 10),
    };

    final response = await ApiService.createPeminjaman(data);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response["message"] ?? "Peminjaman berhasil!")),
    );

    loadData(); // refresh setelah pinjam
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peminjaman Buku"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul Buku
                        Text(
                          book["judul"] ?? "Tanpa Judul",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text("Penulis : ${book["penulis"]}"),
                        Text("Kategori : ${book["kategori"]["nama"]}"),
                        Text("Stok : ${book["stok"].toString()}"),

                        const SizedBox(height: 16),

                        // Tombol PINJAM
                        book["stok"] > 0
                            ? ElevatedButton(
                                onPressed: () => pinjamBuku(book["id"]),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize: const Size(double.infinity, 45),
                                ),
                                child: const Text("PINJAM BUKU"),
                              )
                            : Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Stok Habis",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
