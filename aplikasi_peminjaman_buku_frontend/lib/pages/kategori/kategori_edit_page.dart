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
    final data = {
      "nama_kategori": namaController.text,
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
      appBar: AppBar(
        title: const Text(
          "Edit Kategori",
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Edit Kategori",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Mengubah: ${widget.kategori["nama_kategori"]}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category),
                    labelText: "Nama Kategori",
                    border: OutlineInputBorder(),
                  ),
                ),
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
                      onPressed: updateKategori,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
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
    );
  }
}