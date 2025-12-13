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
        title: const Text("Tambah Kategori Buku"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              field(
                namaKategori,
                "Nama Kategori",
                Icons.category,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: loading ? null : saveKategori,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Simpan",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
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
