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

  // ===============================
  // LOAD DETAIL BUKU
  // ===============================
  Future<void> loadBookDetail() async {
    try {
      final fetchedBook = await ApiService.getBookDetail(widget.bookId);

      setState(() {
        book = fetchedBook;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        book = null;
        isLoading = false;
      });
    }
  }

  // ===============================
  // KONFIRMASI PEMINJAMAN
  // ===============================
  void _confirmAjukanPeminjaman() {
    if ((book!['stok_tersedia'] ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Stok buku habis, tidak bisa meminjam"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2C3E50),
                Color(0xFF3498DB),
              ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.library_add_rounded,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                "Ajukan Peminjaman",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3498DB).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.book_rounded,
                  size: 40,
                  color: Color(0xFF3498DB),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Ajukan peminjaman buku ini?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2C3E50),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                book!['judul'] ?? '-',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Pengajuan akan menunggu persetujuan admin",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7FB3D5),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3498DB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Batal",
                      style: TextStyle(
                        color: Color(0xFF3498DB),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
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
                          backgroundColor: res["success"] == true ? Colors.green : Colors.red,
                        ),
                      );

                      if (res["success"] == true) {
                        loadBookDetail(); // refresh stok
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Ajukan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF3498DB),
              ),
            )
          : book == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3498DB).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF3498DB).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.book_rounded,
                          size: 60,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Buku tidak ditemukan",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Buku mungkin telah dihapus atau tidak tersedia",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 220,
                      pinned: true,
                      backgroundColor: const Color(0xFF2C3E50),
                      foregroundColor: Colors.white,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF2C3E50),
                                Color(0xFF3498DB),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.menu_book_rounded,
                                    size: 45,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  book!['judul'] ?? "-",
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 3,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ================= CONTENT =================
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _infoCard(),
                            const SizedBox(height: 20),
                            _descriptionCard(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

      // ================= FLOATING BUTTON =================
      floatingActionButton: (book == null || (book!['stok_tersedia'] ?? 0) <= 0)
          ? null
          : Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton.extended(
                onPressed: _confirmAjukanPeminjaman,
                icon: const Icon(Icons.bookmark_add_rounded, size: 24),
                label: const Text(
                  "Ajukan Peminjaman",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                backgroundColor: const Color(0xFF2C3E50),
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
    );
  }

  // ================= INFO CARD =================
  Widget _infoCard() {
    final int stokTotal = book!['stok'] ?? 0;
    final int stokTersedia = book!['stok_tersedia'] ?? 0;
    final bool isAvailable = stokTersedia > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _infoRow(Icons.person_rounded, "Penulis", book!['penulis'] ?? "-"),
            _infoRow(Icons.store_rounded, "Penerbit", book!['penerbit'] ?? "-"),
            _infoRow(Icons.calendar_month_rounded, "Tahun", book!['tahun'].toString()),
            _infoRow(
              Icons.category_rounded,
              "Kategori",
              book!['kategori']?['nama_kategori'] ?? "-",
            ),
            _infoRow(Icons.inventory_2_rounded, "Total Stok", stokTotal.toString()),
            _infoRow(
              Icons.check_circle_rounded,
              "Stok Tersedia",
              stokTersedia.toString(),
            ),
            const SizedBox(height: 15),

            // BADGE STOK
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isAvailable
                    ? const Color(0xFF27AE60).withOpacity(0.1)
                    : const Color(0xFFE74C3C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isAvailable
                      ? const Color(0xFF27AE60).withOpacity(0.3)
                      : const Color(0xFFE74C3C).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAvailable ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: isAvailable ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAvailable ? "Tersedia ($stokTersedia)" : "Stok Habis",
                    style: TextStyle(
                      color: isAvailable ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DESCRIPTION =================
  Widget _descriptionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.description_rounded,
                  color: Color(0xFF2C3E50),
                  size: 22,
                ),
                SizedBox(width: 10),
                Text(
                  "Deskripsi Buku",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              book!['deskripsi'] ?? "-",
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= INFO ROW =================
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}