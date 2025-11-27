import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool loading = false;

  // === Dropdown kategori ===
  List kategoriList = [];
  String? selectedKategori;

  @override
  void initState() {
    super.initState();

    judul = TextEditingController(text: widget.book["judul"]);
    penulis = TextEditingController(text: widget.book["penulis"]);
    penerbit = TextEditingController(text: widget.book["penerbit"]);
    tahun = TextEditingController(text: widget.book["tahun"]);
    deskripsi = TextEditingController(text: widget.book["deskripsi"]);

    selectedKategori = widget.book["id_kategori"].toString();

    loadKategori();
  }

  Future<void> loadKategori() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final data = await ApiService.getKategori(token!);

    setState(() {
      kategoriList = data;
    });
  }

  void updateBook() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kategori belum dipilih")),
      );
      return;
    }

    setState(() => loading = true);

    final data = {
      "judul": judul.text,
      "penulis": penulis.text,
      "penerbit": penerbit.text,
      "tahun": tahun.text,
      "deskripsi": deskripsi.text,
      "id_kategori": selectedKategori.toString(),
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
      appBar: AppBar(
        title: const Text("Edit Buku"),
        centerTitle: true,
      ),
      body: kategoriList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    _field(judul, "Judul", Icons.title),
                    _field(penulis, "Penulis", Icons.person),
                    _field(penerbit, "Penerbit", Icons.business),
                    _field(tahun, "Tahun", Icons.calendar_today),

                    // ======== DROPDOWN KATEGORI ========
                    DropdownButtonFormField(
                      value: selectedKategori,
                      decoration: const InputDecoration(
                        labelText: "Kategori",
                        border: OutlineInputBorder(),
                      ),
                      items: kategoriList.map((kategori) {
                        return DropdownMenuItem(
                          value: kategori["id"].toString(),
                          child: Text(kategori["nama_kategori"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedKategori = value.toString();
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    _field(deskripsi, "Deskripsi", Icons.description, maxLine: 4),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: loading ? null : updateBook,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Update Buku"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {int maxLine = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: c,
        maxLines: maxLine,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
        validator: (v) => v!.isEmpty ? "$label wajib diisi" : null,
      ),
    );
  }
}
