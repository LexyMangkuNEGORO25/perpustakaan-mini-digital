import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tambahkan package intl di pubspec.yaml
import '../models/book.dart';

class HistoryEntry {
  final Book book;
  final DateTime borrowDate;
  final DateTime? returnDate;

  HistoryEntry({
    required this.book,
    required this.borrowDate,
    this.returnDate,
  });
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final List<HistoryEntry> history = [
      HistoryEntry(
        book: Book(
          id: 1,
          title: 'Flutter for Beginners',
          author: 'John Doe',
          description: 'Panduan lengkap belajar Flutter untuk pemula.',
          coverUrl: 'https://picsum.photos/200/300?random=1',
          category: 'Pemrograman',
        ),
        borrowDate: DateTime(2025, 5, 10),
        returnDate: DateTime(2025, 5, 20),
      ),
      HistoryEntry(
        book: Book(
          id: 2,
          title: 'Dart Programming',
          author: 'Jane Smith',
          description: 'Belajar bahasa Dart dari dasar hingga mahir.',
          coverUrl: 'https://picsum.photos/200/300?random=2',
          category: 'Pemrograman',
        ),
        borrowDate: DateTime(2025, 5, 15),
        returnDate: null,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Peminjaman'),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final entry = history[index];
            final returned = entry.returnDate != null;

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        entry.book.coverUrl,
                        width: 60,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 90,
                          color: Colors.grey[300],
                          child: const Icon(Icons.book, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.book.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Dipinjam: ${formatDate(entry.borrowDate)}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                returned ? Icons.check_circle : Icons.error,
                                color: returned ? Colors.green : Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                returned
                                    ? 'Dikembalikan: ${formatDate(entry.returnDate!)}'
                                    : 'Belum dikembalikan',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: returned ? Colors.green[700] : Colors.red[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
