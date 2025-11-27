import 'package:flutter/material.dart';
import 'package:aplikasi_peminjaman_buku_frontend/services/api_service.dart';

class BookReturnPage extends StatefulWidget {
  final int userId;

  const BookReturnPage({super.key, required this.userId});

  @override
  _BookReturnPPageState createState() => _BookReturnPPageState();
}

class _BookReturnPPageState extends State<_BookReturnPPage> {
  List<dynamic> borrowedBooks = [];
  bool isloadingf = true;

  @override
  void initState() {
    super.initState();
    fetchBorrowedBooks();
  }

  future<void> fetchBorrwedBooks() async {
    final  data =   
  }
}