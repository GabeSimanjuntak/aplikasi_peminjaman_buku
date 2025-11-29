import 'package:aplikasi_peminjaman_buku_frontend/pages/user/user_dashboard.dart';
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/admin_dashboard.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/login',
    routes: {
      '/login': (_) => LoginPage(),
      '/admin': (_) => AdminDashboard(),
      '/user': (_) => UserDashboardPage(),
      
    },
  ));
}
