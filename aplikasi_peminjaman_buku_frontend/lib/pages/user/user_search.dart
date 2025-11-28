import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> allBooks = [];
  List<dynamic> filteredBooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    final books = await ApiService.getBooksUser();
    setState(() {
      allBooks = books;
      filteredBooks = books;
      isLoading = false;
    });
  }

  void _runFilter(String keyword) {
    List<dynamic> results = [];
    if (keyword.isEmpty) {
      results = allBooks;
    } else {
      results = allBooks
          .where((book) =>
              book["judul"].toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      filteredBooks = results;
    });
  }

  // === LOGIC BARU: TAMPILKAN DIALOG TANGGAL ===
  void _showPinjamDialog(Map<String, dynamic> book) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)), // Default 3 hari ke depan
      firstDate: DateTime.now(), // Tidak boleh tanggal lampau
      lastDate: DateTime.now().add(const Duration(days: 14)), // Maksimal 2 minggu
      helpText: "Pilih Tanggal Pengembalian",
    ).then((selectedDate) {
      if (selectedDate != null) {
        // Konversi ke format YYYY-MM-DD
        String formattedDate = selectedDate.toIso8601String().split('T')[0];
        _prosesPinjamBuku(book['id'], formattedDate);
      }
    });
  }

  // === LOGIC BARU: KIRIM KE API ===
  Future<void> _prosesPinjamBuku(int bukuId, String tanggalJatuhTempo) async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("user_id");

    if (userId == null) return;

    // Tampilkan loading dialog kecil
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    Map data = {
      "id_user": userId.toString(),
      "id_buku": bukuId.toString(),
      "tanggal_jatuh_tempo": tanggalJatuhTempo,
    };

    try {
      final response = await ApiService.createPeminjaman(data);
      
      // Tutup loading dialog
      Navigator.pop(context); 

      if (response['success'] == true) {
        _showSuccessDialog("Berhasil!", "Buku berhasil dipinjam. Jangan lupa kembalikan pada $tanggalJatuhTempo.");
        
        // Refresh daftar buku (karena status buku mungkin berubah jadi 'dipinjam')
        _fetchBooks(); 
      } else {
        _showErrorSnackBar(response['message'] ?? "Gagal meminjam");
      }
    } catch (e) {
      Navigator.pop(context); // Tutup loading jika error
      _showErrorSnackBar("Terjadi kesalahan sistem: $e");
    }
  }

  void _showSuccessDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.green)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: _runFilter,
            decoration: InputDecoration(
              hintText: "Cari judul, penulis...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredBooks.isEmpty
                    ? const Center(child: Text("Buku tidak ditemukan"))
                    : ListView.builder(
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = filteredBooks[index];
                          final String kategori = book['kategori'] != null 
                              ? book['kategori']['nama_kategori'] 
                              : '-';
                          
                          // Cek status buku
                          bool isAvailable = book['status'] == 'tersedia';

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon Buku (Bisa diganti Image.network nanti jika ada gambar)
                                  Container(
                                    width: 60,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.book, size: 40, color: Colors.blue),
                                  ),
                                  const SizedBox(width: 12),
                                  // Info Buku
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book["judul"],
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text("Penulis: ${book["penulis"]}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                        Text("Kategori: $kategori", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                        const SizedBox(height: 8),
                                        // Badge Status
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isAvailable ? Colors.green[50] : Colors.red[50],
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: isAvailable ? Colors.green : Colors.red),
                                          ),
                                          child: Text(
                                            isAvailable ? "Tersedia" : "Dipinjam",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isAvailable ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Tombol Pinjam
                                  if (isAvailable)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () => _showPinjamDialog(book),
                                      child: const Text("Pinjam"),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }
}