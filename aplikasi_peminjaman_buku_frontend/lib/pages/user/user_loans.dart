import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'loan_detail_page.dart';

class UserLoansPage extends StatefulWidget {
  const UserLoansPage({super.key});

  @override
  State<UserLoansPage> createState() => _UserLoansPageState();
}

class _UserLoansPageState extends State<UserLoansPage> {
  List<Map<String, dynamic>> loans = [];
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  // ================= LOAD DATA =================
  Future<void> _loadLoans() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final data = await ApiService.getLoanHistoryUser(userId);

      loans = data.map<Map<String, dynamic>>(
        (e) => Map<String, dynamic>.from(e),
      ).toList();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat data: $e")),
      );
    }
  }

  // ================= AJUKAN PENGEMBALIAN =================
  Future<void> _ajukanPengembalian(Map<String, dynamic> loan) async {
    final String? tglPinjamStr = loan['tanggal_pinjam'];

    if (tglPinjamStr == null || tglPinjamStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tanggal pinjam tidak ditemukan")),
      );
      return;
    }

    final tanggalPinjam = DateTime.parse(tglPinjamStr);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: tanggalPinjam.add(const Duration(days: 1)),
      firstDate: tanggalPinjam,
      lastDate: tanggalPinjam.add(const Duration(days: 30)),
    );

    if (pickedDate == null) return;

    if (pickedDate.isBefore(tanggalPinjam)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Tanggal pengembalian tidak boleh sebelum tanggal peminjaman")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final result = await ApiService.ajukanPengembalianWithDate(
        loan['id_peminjaman'],
        pickedDate,
      );

      if (result['success'] == true) {
        final index = loans.indexWhere(
            (l) => l['id_peminjaman'] == loan['id_peminjaman']);

        if (index != -1) {
          setState(() {
            loans[index]['status_pinjam'] = 'pengajuan_kembali';
            loans[index]['tanggal_pengembalian_dipilih'] =
                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pengajuan pengembalian berhasil. Menunggu persetujuan."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Peminjaman"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : loans.isEmpty
              ? const Center(child: Text("Belum ada riwayat peminjaman"))
              : RefreshIndicator(
                  onRefresh: _loadLoans,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: loans.length,
                    itemBuilder: (context, index) {
                      return _loanCard(loans[index]);
                    },
                  ),
                ),
    );
  }

  // ================= CARD =================
  Widget _loanCard(Map<String, dynamic> item) {
    final judul = item['judul_buku']?.toString() ?? '-';
    final status = item['status_pengembalian'] ?? item['status_pinjam'];

    final tanggalPinjam = item['tanggal_pinjam']?.toString();
    final jatuhTempo = item['tanggal_jatuh_tempo']?.toString();
    final tanggalPengembalianDipilih = item['tanggal_pengembalian_dipilih']?.toString();

    Color statusColor;
    String statusLabel;

    switch (status) {
      case 'menunggu_persetujuan':
        statusColor = Colors.orange;
        statusLabel = 'Menunggu Persetujuan';
        break;
      case 'pengajuan_kembali':
        statusColor = Colors.green;
        statusLabel = 'Pengembalian Diajukan';
        break;
      case 'dikembalikan':
        statusColor = Colors.grey;
        statusLabel = 'Dikembalikan';
        break;
      default:
        statusColor = Colors.blue;
        statusLabel = 'Dipinjam';
    }

    if (item['catatan'] == 'terlambat') {
      statusColor = Colors.red;
      statusLabel += ' (Terlambat)';
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LoanDetailPage(item: item),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      judul,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _infoRow("Tanggal Pinjam", tanggalPinjam),
              _infoRow("Jatuh Tempo", jatuhTempo),

              if (tanggalPengembalianDipilih != null &&
                  tanggalPengembalianDipilih.isNotEmpty) ...[
                const Divider(height: 24),
                _infoRow("Tanggal Pengembalian", tanggalPengembalianDipilih),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value ?? '-',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
