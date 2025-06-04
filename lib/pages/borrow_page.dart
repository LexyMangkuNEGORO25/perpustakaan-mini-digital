import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class BorrowPage extends StatefulWidget {
  final Book book;

  const BorrowPage({super.key, required this.book});

  @override
  State<BorrowPage> createState() => _BorrowPageState();
}

class _BorrowPageState extends State<BorrowPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _tanggalPinjam;
  DateTime? _tanggalJatuhTempo;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  bool _isLoading = false;

  Future<void> _pickDate(BuildContext context, bool isPinjam) async {
    final now = DateTime.now();
    final initialDate = isPinjam ? _tanggalPinjam ?? now : _tanggalJatuhTempo ?? now.add(Duration(days: 7));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        if (isPinjam) {
          _tanggalPinjam = picked;
          _tanggalJatuhTempo ??= picked.add(Duration(days: 7));
        } else {
          _tanggalJatuhTempo = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_tanggalPinjam == null || _tanggalJatuhTempo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal pinjam dan tanggal jatuh tempo wajib diisi')),
      );
      return;
    }

    if (_tanggalJatuhTempo!.isBefore(_tanggalPinjam!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal jatuh tempo harus setelah tanggal pinjam')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      int userId = 1; // Ganti sesuai user login sebenarnya

      final success = await ApiService.borrowBook(
        userId: userId,
        bookId: widget.book.id,
        tanggalPinjam: _dateFormat.format(_tanggalPinjam!),
        tanggalJatuhTempo: _dateFormat.format(_tanggalJatuhTempo!),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil meminjam buku')),
        );
        Navigator.pop(context, true); // Kembalikan true ke halaman sebelumnya (HomePage)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal meminjam buku')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pinjam Buku: ${widget.book.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ListTile(
                title: Text(_tanggalPinjam == null
                    ? 'Pilih Tanggal Pinjam'
                    : 'Tanggal Pinjam: ${_dateFormat.format(_tanggalPinjam!)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickDate(context, true),
              ),
              ListTile(
                title: Text(_tanggalJatuhTempo == null
                    ? 'Pilih Tanggal Jatuh Tempo'
                    : 'Tanggal Jatuh Tempo: ${_dateFormat.format(_tanggalJatuhTempo!)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickDate(context, false),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Konfirmasi Peminjaman'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
