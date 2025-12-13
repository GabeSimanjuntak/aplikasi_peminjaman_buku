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
              onPressed: () => deleteBook(book["id"]),
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
        title: const Text("Daftar Buku"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookCreatePage()),
          );
          loadBooks();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: loadBooks,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : books.isEmpty
                ? const Center(child: Text("Belum ada buku tersedia"))
                : ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, i) => buildBookCard(books[i]),
                  ),
      ),
    );
  }
}
