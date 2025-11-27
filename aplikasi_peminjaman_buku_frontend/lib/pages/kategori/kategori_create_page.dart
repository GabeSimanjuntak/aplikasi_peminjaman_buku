import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class KategoriCreatePage extends StatefulWidget {
  const KategoriCreatePage({super.key});

  @override
  State<KategoriCreatePage> createState() => _KategoriCreatePageState();
}

class _KategoriCreatePageState extends State<KategoriCreatePage> {
  final TextEditingController namaController = TextEditingController();

  void saveKategori() async {
    final data = {"nama_kategori": namaController.text};

    final res = await ApiService.createKategori(data);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res["message"]),
        backgroundColor: res["success"] ? Colors.green : Colors.red,
      ),
    );

    if (res["success"] == true) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Kategori")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: "Nama Kategori"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveKategori,
              child: const Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }
}
