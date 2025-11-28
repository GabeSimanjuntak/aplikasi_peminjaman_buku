import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/admin_dashboard.dart';
import 'pages/user/user_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/admin': (_) => const AdminDashboard(),
        '/user': (_) => const UserDashboardPage(),
      },
    );
  }
}
