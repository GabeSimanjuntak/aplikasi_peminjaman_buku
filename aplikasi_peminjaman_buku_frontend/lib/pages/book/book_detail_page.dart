import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BookDetailPage extends StatelessWidget {
  final Map<String, dynamic> buku;
  final int? userId;

  const BookDetailPage({super.key, required this.buku, this.userId});

  Future<void> _borrow(BuildContext context) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User ID tidak tersedia.')));
      return;
    }
    final res = await ApiService.pinjamBuku(bookId: buku['id'], userId: userId!);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Respon tidak diketahui')));
  }

  @override
  Widget build(BuildContext context) {
    final title = buku['judul'] ?? '-';
    final author = buku['penulis'] ?? '-';
    final desc = buku['deskripsi'] ?? '-';
    final kategori = buku['kategori']?['nama'] ?? '-';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(height: 200, width: double.infinity, decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)), child: Center(child: Icon(Icons.book, size: 80, color: Colors.blue.shade400))),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 6),
          Align(alignment: Alignment.centerLeft, child: Text('Penulis: $author')),
          const SizedBox(height: 6),
          Align(alignment: Alignment.centerLeft, child: Text('Kategori: $kategori')),
          const SizedBox(height: 12),
          Expanded(child: SingleChildScrollView(child: Text(desc))),
          Row(children: [Expanded(child: ElevatedButton(onPressed: () => _borrow(context), child: Text('Pinjam Buku')))]),
        ]),
      ),
    );
  }
}
