import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'book_detail_page.dart';

class BookListPage extends StatefulWidget {
  final int? userId;
  const BookListPage({super.key, this.userId});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  late Future<List<dynamic>> booksFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    booksFuture = ApiService.getBooks();
  }

  void _refresh() {
    setState(() {
      booksFuture = ApiService.getBooks();
    });
  }

  Future<void> _borrowBook(int bookId) async {
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User ID tidak tersedia. Pastikan login mengirim userId.')));
      return;
    }

    final res = await ApiService.pinjamBuku(bookId: bookId, userId: widget.userId!);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Respon tidak diketahui')));
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Buku'),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _refresh)],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(hintText: 'Cari judul atau penulis...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: booksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) return Center(child: CircularProgressIndicator());
              if (!snapshot.hasData) return Center(child: Text('Tidak ada buku'));

              final list = snapshot.data!;
              final filtered = list.where((b) {
                final title = (b['judul'] ?? '').toString().toLowerCase();
                final author = (b['penulis'] ?? '').toString().toLowerCase();
                final q = _query.toLowerCase();
                return title.contains(q) || author.contains(q);
              }).toList();

<<<<<<< HEAD
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
                    "Kategori : ${buku["kategori"]?["nama_kategori"] ?? "-"}",
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
=======
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.65),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final buku = filtered[i];
                  return _BookCard(
                    buku: buku,
                    onTapDetail: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailPage(buku: buku, userId: widget.userId))),
                    onBorrow: () => _borrowBook(buku['id']),
                  );
                },
>>>>>>> 3aba5ebf764f2980e493f25f9514645b946bca18
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Map<String, dynamic> buku;
  final VoidCallback onTapDetail;
  final VoidCallback onBorrow;

  const _BookCard({required this.buku, required this.onTapDetail, required this.onBorrow});

  @override
  Widget build(BuildContext context) {
    final title = buku['judul'] ?? '-';
    final author = buku['penulis'] ?? '-';
    final category = buku['kategori']?['nama'] ?? '-';

    return GestureDetector(
      onTap: onTapDetail,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Container(height: 120, width: double.infinity, decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.book, size: 56, color: Colors.blue.shade400)),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(author, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            const SizedBox(height: 6),
            Text(category, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            Spacer(),
            Row(children: [Expanded(child: ElevatedButton(onPressed: onBorrow, child: Text('Pinjam')))]),
          ]),
        ),
      ),
    );
  }
}
