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

      loans = data
        .where((e) => e['status_pinjam'] != 'dibatalkan')
        .map<Map<String, dynamic>>(
          (e) => Map<String, dynamic>.from(e),
        )
        .toList();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat data: $e")),
      );
    }
  }

  // ================= CANCEL PEMINJAMAN =================
  Future<void> _cancelPeminjaman(int idPeminjaman) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Batalkan Peminjaman"),
        content:
            const Text("Apakah Anda yakin ingin membatalkan peminjaman ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Tidak"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Ya"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isSubmitting = true);

    try {
      final res = await ApiService.cancelPeminjaman(idPeminjaman);

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Peminjaman berhasil dibatalkan")),
        );
        _loadLoans();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Gagal membatalkan")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
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

    setState(() => isSubmitting = true);

    try {
      final result = await ApiService.ajukanPengembalianWithDate(
        int.parse(loan['id_peminjaman'].toString()),
        pickedDate,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Pengajuan pengembalian berhasil. Menunggu persetujuan")),
        );
        _loadLoans();
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
        title: const Text(
          "Riwayat Peminjaman",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2C3E50),
                Color(0xFF3498DB),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5F9FF),
              Color(0xFFE8F0F7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF3498DB),
                ),
              )
            : loans.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3498DB).withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF3498DB).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            size: 50,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Belum ada riwayat peminjaman",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF2C3E50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Pinjam buku terlebih dahulu untuk melihat riwayat",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadLoans,
                    color: const Color(0xFF3498DB),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: loans.length,
                      itemBuilder: (context, index) {
                        return _loanCard(loans[index]);
                      },
                    ),
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

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'menunggu_persetujuan':
        statusColor = Color(0xFFF39C12); // Orange
        statusLabel = 'Menunggu Persetujuan';
        statusIcon = Icons.access_time_rounded;
        break;

      case 'pengajuan_kembali':
        statusColor = Color(0xFF27AE60); // Green
        statusLabel = 'Pengembalian Diajukan';
        statusIcon = Icons.check_circle_outline_rounded;
        break;

      case 'dikembalikan':
        statusColor = Color(0xFF95A5A6); // Grey
        statusLabel = 'Dikembalikan';
        statusIcon = Icons.done_all_rounded;
        break;

      case 'dibatalkan':
        statusColor = Color(0xFFE74C3C); // Red
        statusLabel = 'Dibatalkan';
        statusIcon = Icons.cancel_rounded;
        break;

      case 'dipinjam':
      default:
        statusColor = Color(0xFF3498DB); // Blue
        statusLabel = 'Dipinjam';
        statusIcon = Icons.book_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LoanDetailPage(item: item),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3498DB).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF3498DB).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF2C3E50),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            judul,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C3E50),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  statusIcon,
                                  size: 14,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // INFO ROWS
                _infoRow("Tanggal Pinjam", tanggalPinjam, Icons.calendar_today_rounded),
                const SizedBox(height: 8),
                _infoRow("Jatuh Tempo", jatuhTempo, Icons.schedule_rounded),

                const SizedBox(height: 20),

                // ================= BUTTON =================
                if (item['status_pinjam'] == 'dipinjam')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.assignment_return_rounded, size: 20),
                      label: const Text(
                        "Ajukan Pengembalian",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed:
                          isSubmitting ? null : () => _ajukanPengembalian(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                if (item['status_pinjam'] == 'menunggu_persetujuan')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.cancel_rounded, size: 20),
                      label: const Text(
                        "Batalkan Peminjaman",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () => _cancelPeminjaman(
                              int.parse(item['id_peminjaman'].toString())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF3498DB).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}