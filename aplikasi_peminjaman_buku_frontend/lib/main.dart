import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/admin_dashboard.dart';
import 'pages/user_dashboard.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/login',
    routes: {
      '/login': (_) => LoginPage(),
      '/admin': (_) => AdminDashboard(),
      '/user': (_) => UserDashboard(),
      
    },
  ));
}
