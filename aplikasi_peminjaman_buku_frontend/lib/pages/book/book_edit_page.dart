import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BookEditPage extends StatefulWidget {
  final Map<String, dynamic> book;
  const BookEditPage({super.key, required this.book});

  @override
  State<BookEditPage> createState() => _BookEditPageState();
}

class _BookEditPageState extends State<BookEditPage> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController judul;
  late TextEditingController penulis;
  late TextEditingController penerbit;
  late TextEditingController tahun;
  late TextEditingController deskripsi;
  late TextEditingController idKategori;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    judul = TextEditingController(text: widget.book["judul"]);
    penulis = TextEditingController(text: widget.book["penulis"]);
    penerbit = TextEditingController(text: widget.book["penerbit"]);
    tahun = TextEditingController(text: widget.book["tahun"]);
    deskripsi = TextEditingController(text: widget.book["deskripsi"]);
    idKategori = TextEditingController(text: widget.book["id_kategori"].toString());
  }

  void updateBook() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final data = {
      "judul": judul.text,
      "penulis": penulis.text,
      "penerbit": penerbit.text,
      "tahun": tahun.text,
      "deskripsi": deskripsi.text,
      "id_kategori": idKategori.text,
    };

    final res = await ApiService.updateBook(widget.book["id"], data);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"])),
    );

    if (res["success"] == true) Navigator.pop(context);

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Buku")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
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
                onPressed: loading ? null : updateBook,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update"),
              ),
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
