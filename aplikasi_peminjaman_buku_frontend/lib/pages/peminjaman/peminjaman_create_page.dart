import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PeminjamanCreatePage extends StatefulWidget {
  const PeminjamanCreatePage({super.key});

  @override
  State<PeminjamanCreatePage> createState() => _PeminjamanCreatePageState();
}

class _PeminjamanCreatePageState extends State<PeminjamanCreatePage> {
  List users = [];
  List books = [];

  Map? selectedUser;
  Map? selectedBuku;

  final tanggalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadOptions();
  }

  Future<void> loadOptions() async {
    users = await ApiService.getUsers();
    books = await ApiService.getBooks();

    // filter hanya buku "tersedia"
    books = books.where((b) => b["status"] == "tersedia").toList();

    setState(() {});
  }

  Future<void> submit() async {
    if (selectedUser == null || selectedBuku == null) return;

    final res = await ApiService.createPeminjaman({
      "id_user": selectedUser!["id"].toString(),
      "id_buku": selectedBuku!["id"].toString(),
      "tanggal_jatuh_tempo": tanggalController.text,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res["message"]),
        backgroundColor: res["success"] ? Colors.green : Colors.red,
      ),
    );

    if (res["success"]) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Peminjaman")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Map>(
              hint: const Text("Pilih User"),
              value: selectedUser,
              items: users.map<DropdownMenuItem<Map>>((u) {
                return DropdownMenuItem(
                  value: u,
                  child: Text(u["nama"]),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedUser = val),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<Map>(
              hint: const Text("Pilih Buku"),
              value: selectedBuku,
              items: books.map<DropdownMenuItem<Map>>((b) {
                return DropdownMenuItem(
                  value: b,
                  child: Text(b["judul"]),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedBuku = val),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: tanggalController,
              decoration: const InputDecoration(
                labelText: "Tanggal Jatuh Tempo (YYYY-MM-DD)",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: submit,
              child: const Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }
}
