import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/admin_dashboard.dart';
import 'pages/user_dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Peminjaman Buku',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginPage());
          case '/admin':
            return MaterialPageRoute(builder: (_) => AdminDashboard());
          case '/user':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => UserDashboard(
                username: args?['username'] ?? 'User',
                userId: args?['userId'],
              ),
            );
          default:
            return MaterialPageRoute(builder: (_) => LoginPage());
        }
      },
    );
  }
}
