import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard User")),
      body: Center(
        child: Text("Selamat datang, User!", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
