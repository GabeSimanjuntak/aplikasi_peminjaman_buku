import 'package:flutter/material.dart';
import 'user_home.dart';
import 'user_search.dart';
import 'user_loans.dart';
import 'user_profile.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _currentIndex = 0;

  // List Halaman dipisah ke file masing-masing
  final List<Widget> _pages = [
    const UserHomePage(),
    const UserSearchPage(),
    const UserLoansPage(),
    const UserProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perpustakaan Digital"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _pages[_currentIndex], // Render halaman sesuai index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Cari"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Pinjaman"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}