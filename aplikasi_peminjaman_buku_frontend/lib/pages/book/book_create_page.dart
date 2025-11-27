import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class BookCreatePage extends StatefulWidget {
  const BookCreatePage({super.key});

  @override
  State<BookCreatePage> createState() => _BookCreatePageState();
}

class _BookCreatePageState extends State<BookCreatePage> {
  final formKey = GlobalKey<FormState>();

  final judul = TextEditingController();
  final penulis = TextEditingController();
  final penerbit = TextEditingController();
  final tahun = TextEditingController();
  final deskripsi = TextEditingController();

  List kategoriList = [];
  String? selectedKategori;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadKategori();
  }

  Future<void> loadKategori() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    kategoriList = await ApiService.getKategori(token!);

    setState(() {});
  }

  Future<void> saveBook() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kategori belum dipilih")),
      );
      return;
    }

    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token")!;

    final res = await ApiService.createBook(token, {
      "judul": judul.text,
      "penulis": penulis.text,
      "penerbit": penerbit.text,
      "tahun": tahun.text,
      "deskripsi": deskripsi.text,
      "id_kategori": selectedKategori,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res["message"]),
        backgroundColor: res["success"] == true ? Colors.green : Colors.red,
      ),
    );

    if (res["success"] == true) Navigator.pop(context);

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Buku Baru")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              field(judul, "Judul", Icons.title),
              field(penulis, "Penulis", Icons.person),
              field(penerbit, "Penerbit", Icons.store),
              field(tahun, "Tahun", Icons.calendar_month,
                  type: TextInputType.number),

              DropdownButtonFormField(
                value: selectedKategori,
                decoration: const InputDecoration(
                    labelText: "Kategori", border: OutlineInputBorder()),
                items: kategoriList.map((k) {
                  return DropdownMenuItem(
                    value: k["id"].toString(),
                    child: Text(k["nama_kategori"]),
                  );
                }).toList(),
                onChanged: (v) => setState(() => selectedKategori = v),
                validator: (v) => v == null ? "Pilih kategori" : null,
              ),
              const SizedBox(height: 20),

              field(deskripsi, "Deskripsi", Icons.description, maxLines: 4),
              const SizedBox(height: 30),

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

  Widget field(TextEditingController c, String label, IconData icon,
      {int maxLines = 1, TextInputType type = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: type,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) => v!.isEmpty ? "$label wajib diisi" : null,
      ),
    );
  }
}
