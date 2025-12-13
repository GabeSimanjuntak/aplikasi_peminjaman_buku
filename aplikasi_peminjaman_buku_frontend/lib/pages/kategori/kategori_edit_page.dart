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
  String? selectedStok;

  final List<String> stokOptions = ["0", "1", "2", "3", "4", "5"];

  @override
  void initState() {
    super.initState();
    namaController =
        TextEditingController(text: widget.kategori["nama_kategori"]);

    // Pastikan nilai stok tidak null dan sesuai options
    String? stok = widget.kategori["stok"]?.toString();
    if (stokOptions.contains(stok)) {
      selectedStok = stok;
    } else {
      selectedStok = stokOptions.first;
    }
  }

  void updateKategori() async {
    final data = {
      "nama_kategori": namaController.text,
      "stok": selectedStok ?? stokOptions.first,
    };

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: "Nama Kategori"),
            ),
            const SizedBox(height: 20),
            Text("Stok", style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: selectedStok,
              items: stokOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedStok = val;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateKategori,
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
