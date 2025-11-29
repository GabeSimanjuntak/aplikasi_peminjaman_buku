import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  String userName = "User"; // Default name
  String? userPhoto;        // Variable untuk foto
  List<dynamic> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      // Ambil nama yang tadi disimpan di Login Page
      userName = prefs.getString("nama") ?? "User";
      
      // Ambil foto profil (bisa null)
      userPhoto = prefs.getString("foto");
    });

    try {
      final fetchedBooks = await ApiService.getBooksUser();
      setState(() {
        books = fetchedBooks.take(5).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === HEADER ===
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  // UPDATE: Tampilkan Foto Profil User
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        // Logika: Jika ada foto URL (dan valid http), pakai itu. Jika tidak, pakai icon default.
                        image: (userPhoto != null && userPhoto!.startsWith('http'))
                            ? NetworkImage(userPhoto!) as ImageProvider
                            : const AssetImage("assets/default_avatar.png"), // Pastikan asset ini ada, atau ganti logic di bawah
                      ),
                    ),
                    // Fallback jika tidak punya asset gambar default, pakai child Icon:
                    child: (userPhoto == null || !userPhoto!.startsWith('http')) 
                        ? const Icon(Icons.person, color: Colors.white) 
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Selamat Datang,", style: TextStyle(color: Colors.white70)),
                      Text(
                        userName, // <--- NAMA USER MUNCUL DISINI
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // === BANNER INFO (Sama seperti sebelumnya) ===
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[800]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Jangan lupa kembalikan buku tepat waktu agar tidak terkena denda!",
                      style: TextStyle(color: Colors.orange[900]),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            // === REKOMENDASI BUKU (Sama seperti sebelumnya) ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                "Rekomendasi Buku",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 180,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : books.isEmpty 
                    ? const Center(child: Text("Belum ada buku."))
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                  ),
                                  child: const Center(child: Icon(Icons.book, size: 40, color: Colors.blue)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book['judul'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      book['penulis'],
                                      maxLines: 1,
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}