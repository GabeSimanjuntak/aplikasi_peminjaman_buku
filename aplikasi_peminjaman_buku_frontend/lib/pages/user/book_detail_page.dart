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
    } catch (_) {
      setState(() {
        book = null;
        isLoading = false;
      });
    }
  }

  // ============================================================
  // KONFIRMASI PEMINJAMAN
  // ============================================================
  void _confirmAjukanPeminjaman() {
  if ((book!['stok_tersedia'] ?? 0) <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Buku tidak tersedia, tidak bisa meminjam"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Konfirmasi Peminjaman"),
      content: const Text(
        "Pengajuan akan dikirim dan menunggu persetujuan admin.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            final res = await ApiService.pinjamBuku(widget.bookId);

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  res["success"] == true
                      ? "Pengajuan berhasil dikirim"
                      : res["message"] ?? "Gagal mengajukan peminjaman",
                ),
              ),
            );

            if (res["success"] == true) loadBookDetail();
          },
          child: const Text("Ajukan"),
        ),
      ],
    ),
  );
}


  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : book == null
              ? const Center(child: Text("Buku tidak ditemukan"))
              : CustomScrollView(
                  slivers: [
                    /// ===== HEADER =====
                    SliverAppBar(
                        expandedHeight: 170,
                        pinned: true,
                        backgroundColor: Colors.blue,
                        centerTitle: false, // ✅ RATA KIRI
                        title: const Text(
                          "Detail Buku",
                          style: TextStyle(
                            color: Colors.white, // ✅ WARNA PUTIH
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue, Colors.blueAccent],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 65, 20, 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /// ===== ICON BUKU =====
                                  Icon(
                                    Icons.menu_book,
                                    size: 64,
                                    color: Colors.white.withOpacity(0.9),
                                  ),

                                  const SizedBox(height:6),

                                  /// ===== JUDUL BUKU (CENTER) =====
                                  Text(
                                    book!['judul'] ?? '-',
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),



                    /// ===== CONTENT =====
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoCard(),
                            const SizedBox(height: 16),
                            _descriptionCard(),
                            const SizedBox(height: 90),
                          ],
                        ),
                      ),
                    )
                  ],
                ),

      /// ===== BOTTOM BUTTON =====
      floatingActionButton: book == null || (book!['stok_tersedia'] ?? 0) <= 0
    ? null // tombol tidak muncul jika stok habis
    : FloatingActionButton.extended(
        onPressed: _confirmAjukanPeminjaman,
        icon: const Icon(Icons.bookmark_add),
        label: const Text("Ajukan Peminjaman"),
      ),

    );
  }

  /// ================= INFO CARD =================
  Widget _infoCard() {
    bool isAvailable = (book!['stok'] ?? 0) > 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoRow(Icons.person, "Penulis", book!['penulis']),
            _infoRow(Icons.business, "Penerbit", book!['penerbit']),
            _infoRow(Icons.date_range, "Tahun", book!['tahun'].toString()),
            _infoRow(
              Icons.category,
              "Kategori",
              book!['kategori']?['nama_kategori'] ?? "-",
            ),
            const SizedBox(height: 10),

            /// ===== STOCK BADGE =====
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAvailable ? "Stok Tersedia" : "Stok Habis",
                  style: TextStyle(
                    color: isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// ================= DESCRIPTION CARD =================
  Widget _descriptionCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity, // ✅ FULL LEBAR LAYAR
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Deskripsi",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book!['deskripsi'] ?? "-",
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= INFO ROW =================
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text(
            "$label:",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
