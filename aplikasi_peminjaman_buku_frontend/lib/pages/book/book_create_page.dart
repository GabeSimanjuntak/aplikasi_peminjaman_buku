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
  final stok = TextEditingController();

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Kategori belum dipilih")));
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
      "stok": stok.text,
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
      appBar: AppBar(
        title: const Text(
          "Tambah Buku Baru",
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
                    "Form Tambah Buku",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                const Center(
                  child: Text(
                    "Isi semua data buku dengan lengkap",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                field(judul, "Judul", Icons.title),
                field(penulis, "Penulis", Icons.person),
                field(penerbit, "Penerbit", Icons.store),
                field(tahun, "Tahun", Icons.calendar_month, type: TextInputType.number),
                field(stok, "Stok", Icons.inventory, type: TextInputType.number),
                const SizedBox(height: 20),

                DropdownButtonFormField(
                  value: selectedKategori,
                  decoration: const InputDecoration(
                    labelText: "Kategori",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
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
                        onPressed: loading ? null : saveBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498DB),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Simpan",
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

  Widget field(
    TextEditingController c,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType type = TextInputType.text,
  }) {
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