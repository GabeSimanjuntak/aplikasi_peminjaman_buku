import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class BookEditPage extends StatefulWidget {
  final Map book;
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
  late TextEditingController stok;
  late TextEditingController deskripsi;

  List kategoriList = [];
  String? selectedKategori;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    judul = TextEditingController(text: widget.book["judul"]);
    penulis = TextEditingController(text: widget.book["penulis"]);
    penerbit = TextEditingController(text: widget.book["penerbit"]);
    tahun = TextEditingController(text: widget.book["tahun"].toString());
    stok = TextEditingController(text: widget.book["stok"].toString());
    deskripsi = TextEditingController(text: widget.book["deskripsi"]);

    selectedKategori = widget.book["id_kategori"]?.toString();
    loadKategori();
  }

  Future<void> loadKategori() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    kategoriList = await ApiService.getKategori(token!);

    // jika selectedKategori null atau tidak ada di list, pakai default pertama
    if (kategoriList.isNotEmpty &&
        !kategoriList.any((k) => k["id"].toString() == selectedKategori)) {
      selectedKategori = kategoriList.first["id"].toString();
    }

    setState(() {});
  }

  Future<void> updateBook() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await ApiService.updateBook(
      widget.book["id"],
      {
        "judul": judul.text,
        "penulis": penulis.text,
        "penerbit": penerbit.text,
        "tahun": tahun.text,
        "stok": stok.text,
        "deskripsi": deskripsi.text,
        "id_kategori": selectedKategori ?? kategoriList.first["id"].toString(),
      },
    );

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
      appBar: AppBar(
        title: const Text(
          "Edit Buku",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2C3E50),
                Color(0xFF3498DB),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5F9FF),
              Color(0xFFE8F0F7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Edit Data Buku",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Mengubah: ${widget.book["judul"]}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                
                field(judul, "Judul", Icons.title),
                field(penulis, "Penulis", Icons.person),
                field(penerbit, "Penerbit", Icons.store),
                field(tahun, "Tahun", Icons.calendar_month),
                field(stok, "Stok", Icons.numbers),
                const SizedBox(height: 20),

                kategoriList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        value: kategoriList.any(
                                (k) => k["id"].toString() == selectedKategori)
                            ? selectedKategori
                            : kategoriList.first["id"].toString(),
                        decoration: const InputDecoration(
                          labelText: "Kategori",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: kategoriList.map((kategori) {
                          return DropdownMenuItem(
                            value: kategori["id"].toString(),
                            child: Text(kategori["nama_kategori"]),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => selectedKategori = v),
                      ),
                const SizedBox(height: 20),

                field(deskripsi, "Deskripsi", Icons.description, maxLines: 4),
                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Color(0xFF2C3E50)),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(color: Color(0xFF2C3E50)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: loading ? null : updateBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498DB),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Update",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget field(TextEditingController c, String label, IconData icon,
      {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
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