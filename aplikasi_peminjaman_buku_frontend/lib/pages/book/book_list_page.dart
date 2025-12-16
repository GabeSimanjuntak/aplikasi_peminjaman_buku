import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'book_create_page.dart';
import 'book_edit_page.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  bool loading = true;
  List books = [];
  String? userRole;

  @override
  void initState() {
    super.initState();
    loadUserRole();
    loadBooks();
  }

  Future<void> loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString("role"); // misal: "admin" atau "user"
    });
  }

  Future<void> loadBooks() async {
    setState(() {
      loading = true;
    });

    final data = await ApiService.getBooks();

    setState(() {
      books = data;
      loading = false;
    });
  }

  Future<bool> showConfirmDeleteDialog(String judul) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Konfirmasi Hapus"),
            content: Text(
              "Yakin ingin menghapus buku:\n\n\"$judul\" ?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Hapus"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> deleteBook(int id) async {
    final res = await ApiService.deleteBook(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res["message"] ?? "Gagal menghapus"),
        backgroundColor: Colors.red,
      ),
    );

    loadBooks();
  }

  Widget buildBookCard(Map book) {
    final bool isAvailable = book["stok_tersedia"] > 0;
    final bool canBorrow = userRole == "user" && isAvailable;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(book["judul"], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          "Penulis: ${book["penulis"]}\nStok tersedia: ${book["stok_tersedia"]}/${book["stok"]}",
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookEditPage(book: book)),
                );
                loadBooks();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showConfirmDeleteDialog(book["judul"]);
                if (confirm) {
                  deleteBook(book["id"]);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daftar Buku",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2C3E50),
                Color(0xFF3498DB),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookCreatePage()),
          );
          loadBooks();
        },
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5F9FF),
              Color(0xFFE8F0F7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: loadBooks,
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3498DB),
                  ),
                )
              : books.isEmpty
                  ? const Center(
                      child: Text(
                        "Belum ada buku tersedia",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: books.length,
                      itemBuilder: (context, i) => buildBookCard(books[i]),
                    ),
        ),
      ),
    );
  }
}