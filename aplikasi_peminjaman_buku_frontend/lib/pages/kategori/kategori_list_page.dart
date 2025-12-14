import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'kategori_create_page.dart';
import 'kategori_edit_page.dart';

class KategoriListPage extends StatefulWidget {
  const KategoriListPage({super.key});

  @override
  State<KategoriListPage> createState() => _KategoriListPageState();
}

class _KategoriListPageState extends State<KategoriListPage> {
  late Future<List<dynamic>> kategoriList;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    setState(() {
      kategoriList = ApiService.getKategori(token!);
    });
  }

  void deleteKategori(int id) async {
    final res = await ApiService.deleteKategori(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res["message"]),
        backgroundColor: res["success"] ? Colors.green : Colors.red,
      ),
    );

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Kategori")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KategoriCreatePage()),
          ).then((_) => loadData());
        },
      ),
      body: FutureBuilder(
        future: kategoriList,
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text("Belum ada kategori"));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final kategori = data[i];
              return ListTile(
                title: Text(kategori["nama_kategori"]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                KategoriEditPage(kategori: kategori),
                          ),
                        ).then((_) => loadData());
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteKategori(kategori["id"]),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
