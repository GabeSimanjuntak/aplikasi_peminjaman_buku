import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'book_detail_page.dart';

class BookSearchPage extends StatefulWidget {
  final int? userId;
  const BookSearchPage({super.key, this.userId});

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  late Future<List<dynamic>> _futureBooks;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _futureBooks = ApiService.getBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Buku')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(decoration: InputDecoration(hintText: 'Masukkan kata kunci...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), onChanged: (v) => setState(() => _q = v))),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _futureBooks,
            builder: (context, snap) {
              if (!snap.hasData) return Center(child: CircularProgressIndicator());
              final list = snap.data!;
              final filtered = list.where((b) {
                final s = '${b['judul'] ?? ''} ${b['penulis'] ?? ''} ${b['kategori']?['nama'] ?? ''}'.toLowerCase();
                return s.contains(_q.toLowerCase());
              }).toList();

              if (filtered.isEmpty) return Center(child: Text('Tidak ditemukan'));

              return ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (context, i) {
                  final buku = filtered[i];
                  return ListTile(
                    leading: Icon(Icons.book),
                    title: Text(buku['judul'] ?? '-'),
                    subtitle: Text(buku['penulis'] ?? '-'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailPage(buku: buku, userId: widget.userId))),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}
