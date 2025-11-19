import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BookCreatePage extends StatefulWidget {
  const BookCreatePage({super.key});

  @override
  State<BookCreatePage> createState() => _BookCreatePageState();
}

class _BookCreatePageState extends State<BookCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final judul = TextEditingController();
  final penulis = TextEditingController();
  final penerbit = TextEditingController();
  final tahun = TextEditingController();
  final deskripsi = TextEditingController();
  final idKategori = TextEditingController();

  bool loading = false;

  void saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final data = {
      "judul": judul.text,
      "penulis": penulis.text,
      "penerbit": penerbit.text,
      "tahun": tahun.text,
      "deskripsi": deskripsi.text,
      "id_kategori": idKategori.text,
    };

    final res = await ApiService.createBook(data);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"])),
    );

    if (res["success"] == true) Navigator.pop(context);

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Buku")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field(judul, "Judul"),
              _field(penulis, "Penulis"),
              _field(penerbit, "Penerbit"),
              _field(tahun, "Tahun"),
              _field(idKategori, "ID Kategori"),
              _field(deskripsi, "Deskripsi", maxLine: 3),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : saveBook,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {int maxLine = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: c,
        maxLines: maxLine,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) => v!.isEmpty ? "$label wajib diisi" : null,
      ),
    );
  }
}
