import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookCreatePage extends StatefulWidget {
  const BookCreatePage({super.key});

  @override
  State<BookCreatePage> createState() => _BookCreatePageState();
}

class _BookCreatePageState extends State<BookCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final judul = TextEditingController();
  final penulis = TextEditingController();
  final penerbit = TextEditingController();
  final tahun = TextEditingController();
  final deskripsi = TextEditingController();

  bool loading = false;

  // Dropdown Kategori
  List kategoriList = [];
  String? selectedKategori;

  @override
  void initState() {
    super.initState();
    loadKategori();
  }

  Future<void> loadKategori() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    List data = await ApiService.getKategori(token!);

    setState(() {
      kategoriList = data;
    });
  }

  void saveBook() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kategori belum dipilih"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => loading = true);

    final data = {
      "judul": judul.text,
      "penulis": penulis.text,
      "penerbit": penerbit.text,
      "tahun": tahun.text,
      "deskripsi": deskripsi.text,
      "id_kategori": selectedKategori!,
    };

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await ApiService.createBook(token!, data);

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
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[50],
      body: kategoriList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Memuat kategori...",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        _buildSectionHeader("Informasi Buku"),
                        const SizedBox(height: 20),
                        
                        _field(judul, "Judul Buku", Icons.title),
                        _field(penulis, "Penulis", Icons.person),
                        _field(penerbit, "Penerbit", Icons.business),
                        _field(tahun, "Tahun Terbit", Icons.calendar_today,
                            keyboardType: TextInputType.number),

                        // ==========================
                        //   DROPDOWN KATEGORI
                        // ==========================
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              labelText: "Kategori",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.blue),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              prefixIcon: const Icon(Icons.category, size: 20),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            value: selectedKategori,
                            items: kategoriList.map((kategori) {
                              return DropdownMenuItem(
                                value: kategori["id"].toString(),
                                child: Text(
                                  kategori["nama_kategori"],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedKategori = value;
                              });
                            },
                            validator: (v) =>
                                v == null ? "Kategori wajib dipilih" : null,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            icon: const Icon(Icons.arrow_drop_down),
                            borderRadius: BorderRadius.circular(8),
                            isExpanded: true,
                          ),
                        ),

                        _buildSectionHeader("Deskripsi"),
                        const SizedBox(height: 10),
                        
                        _field(deskripsi, "Deskripsi Buku", Icons.description, 
                            maxLine: 4),

                        const SizedBox(height: 32),

                        // Tombol Simpan
                        Container(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: loading ? null : saveBook,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        "Simpan Buku",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Tombol Batal
                        OutlinedButton(
                          onPressed: loading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    int maxLine = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: c,
        maxLines: maxLine,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          prefixIcon: Icon(icon, size: 20),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLine > 1 ? 16 : 0,
          ),
          labelStyle: const TextStyle(fontSize: 14),
        ),
        validator: (v) => v!.isEmpty ? "$label wajib diisi" : null,
      ),
    );
  }
}