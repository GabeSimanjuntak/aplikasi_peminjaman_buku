import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class KategoriEditPage extends StatefulWidget {
  final Map kategori;

  const KategoriEditPage({super.key, required this.kategori});

  @override
  State<KategoriEditPage> createState() => _KategoriEditPageState();
}

class _KategoriEditPageState extends State<KategoriEditPage> {
  late TextEditingController namaController;

  @override
  void initState() {
    super.initState();
    namaController =
        TextEditingController(text: widget.kategori["nama_kategori"]);
  }

  void updateKategori() async {
    final data = {"nama_kategori": namaController.text};

    final res = await ApiService.updateKategori(widget.kategori["id"], data);

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
      appBar: AppBar(title: const Text("Edit Kategori")),
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
              onPressed: updateKategori,
              child: const Text("Update"),
            )
          ],
        ),
      ),
    );
  }
}
