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

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Buku"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BookCreatePage()));
          loadBooks();
        },
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, i) {
                final b = books[i];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(b["judul"]),
                    subtitle: Text("Penulis: ${b["penulis"]}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookEditPage(book: b),
                              ),
                            );
                            loadBooks();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteBook(b["id"]),
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
