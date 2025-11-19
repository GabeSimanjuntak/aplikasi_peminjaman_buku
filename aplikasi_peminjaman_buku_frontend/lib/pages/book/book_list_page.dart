import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'book_create_page.dart';
import 'book_edit_page.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  late Future<List<dynamic>> books;

  @override
  void initState() {
    super.initState();
    books = ApiService.getBooks();
  }

  void refreshBooks() {
    setState(() {
      books = ApiService.getBooks();
    });
  }

  void deleteBook(int id) async {
    final res = await ApiService.deleteBook(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"])),
    );

    refreshBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Buku")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookCreatePage()),
          ).then((_) => refreshBooks());
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: books,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data!;

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final buku = list[i];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.book, size: 40),
                  title: Text(buku["judul"]),
                  subtitle: Text(
                    "Penulis : ${buku["penulis"] ?? "-"}\n"
                    "Kategori : ${buku["kategori"]?["nama"] ?? "-"}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookEditPage(book: buku),
                            ),
                          ).then((_) => refreshBooks());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteBook(buku["id"]),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
