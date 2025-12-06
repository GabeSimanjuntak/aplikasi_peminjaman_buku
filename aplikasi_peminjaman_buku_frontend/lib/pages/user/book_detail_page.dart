import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BookDetailPage extends StatefulWidget {
  final int bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  Map<String, dynamic>? book;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBookDetail();
  }

  Future<void> loadBookDetail() async {
    try {
      final fetchedBook = await ApiService.getBookDetail(widget.bookId);

      setState(() {
        book = fetchedBook.isNotEmpty ? fetchedBook : null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        book = null;
        isLoading = false;
      });
    }
  }

  // ============================================================
  // POPUP KONFIRMASI PINJAM BUKU
  // ============================================================
  void _confirmBorrow() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Yakin ingin meminjam buku ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Tutup dialog

                final res = await ApiService.pinjamBuku(widget.bookId);

                if (!mounted) return;

                // PENTING: gunakan context halaman ini, bukan context dialog
                if (res["success"] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Berhasil meminjam buku!")),
                  );

                  // refresh halaman detail agar stok berubah
                  loadBookDetail();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res["message"] ?? "Gagal meminjam buku")),
                  );
                }
              },
              child: const Text("Ya"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // UI HALAMAN
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Buku")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : book == null
              ? const Center(child: Text("Buku tidak ditemukan"))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    children: [
                      // Judul
                      Text(
                        book!['judul'] ?? '-',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Penulis & Penerbit
                      Row(
                        children: [
                          Text(
                            "Penulis: ${book!['penulis'] ?? '-'}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            "Penerbit: ${book!['penerbit'] ?? '-'}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Tahun & Stok
                      Row(
                        children: [
                          Text(
                            "Tahun: ${book!['tahun'] ?? '-'}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            "Stok: ${book!['stok'] ?? '-'}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Kategori
                      Text(
                        "Kategori: ${book!['kategori']?['nama_kategori'] ?? '-'}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 15),

                      // Deskripsi
                      const Text(
                        "Deskripsi:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        book!['deskripsi'] ?? "-",
                        style: const TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 30),

                      // Tombol Pinjam
                      ElevatedButton(
                        onPressed: _confirmBorrow,
                        child: const Text("Pinjam Buku"),
                      ),
                    ],
                  ),
                ),
    );
  }
}
