import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class KategoriCreatePage extends StatefulWidget {
  const KategoriCreatePage({super.key});

  @override
  State<KategoriCreatePage> createState() => _KategoriCreatePageState();
}

class _KategoriCreatePageState extends State<KategoriCreatePage> {
  final formKey = GlobalKey<FormState>();
  final namaKategori = TextEditingController();
  bool loading = false;

  Future<void> saveKategori() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final res = await ApiService.createKategori({
      "nama_kategori": namaKategori.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res["message"]),
        backgroundColor: res["success"] == true ? Colors.green : Colors.red,
      ),
    );

    if (res["success"] == true) {
      Navigator.pop(context);
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tambah Kategori Buku",
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
                    "Tambah Kategori Baru",
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
                    "Buat kategori baru untuk pengelompokan buku",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                field(
                  namaKategori,
                  "Nama Kategori",
                  Icons.category,
                ),

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
                        onPressed: loading ? null : saveKategori,
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

  /// ========= FIELD (SAMA DENGAN BOOK PAGE) =========
  Widget field(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) => v == null || v.isEmpty ? "$label wajib diisi" : null,
      ),
    );
  }
}