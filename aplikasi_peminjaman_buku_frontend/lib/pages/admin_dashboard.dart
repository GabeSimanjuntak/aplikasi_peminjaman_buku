import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard Admin")),
      body: Center(
        child: Text(
          "Selamat Datang Admin!",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
