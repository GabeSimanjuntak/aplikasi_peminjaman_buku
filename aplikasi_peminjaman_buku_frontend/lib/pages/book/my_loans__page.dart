import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MyLoansPage extends StatefulWidget {
  final int userId;
  const MyLoansPage({super.key, required this.userId});

  @override
  State<MyLoansPage> createState() => _MyLoansPageState();
}

class _MyLoansPageState extends State<MyLoansPage> {
  late Future<List<dynamic>> _futureLoans;

  @override
  void initState() {
    super.initState();
    _futureLoans = ApiService.getPeminjamanUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Peminjaman Saya')),
      body: FutureBuilder<List<dynamic>>(
        future: _futureLoans,
        builder: (context, snap) {
          if (!snap.hasData) return Center(child: CircularProgressIndicator());
          final loans = snap.data!;
          if (loans.isEmpty) return Center(child: Text('Belum ada peminjaman'));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => Divider(),
            itemCount: loans.length,
            itemBuilder: (context, i) {
              final item = loans[i];
              final judul = item['buku']?['judul'] ?? item['judul'] ?? '-';
              final status = item['status'] ?? '-';
              final tanggal = item['tanggal'] ?? item['created_at'] ?? '-';
              return ListTile(
                leading: Icon(Icons.book),
                title: Text(judul),
                subtitle: Text('Status: $status\nTanggal: $tanggal'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
