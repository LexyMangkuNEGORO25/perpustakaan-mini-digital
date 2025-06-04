import 'book.dart';

class Borrowing {
  final int id; // ID peminjaman, dibutuhkan untuk proses pengembalian
  final Book book;
  final String tanggalPinjam;
  final String tanggalJatuhTempo;
  final String status;

  Borrowing({
    required this.id,
    required this.book,
    required this.tanggalPinjam,
    required this.tanggalJatuhTempo,
    required this.status,
  });

  factory Borrowing.fromJson(Map<String, dynamic> json) {
    return Borrowing(
      id: json['id'],
      book: Book.fromJson(json['buku']), // 'buku' adalah nested object
      tanggalPinjam: json['tanggal_pinjam'],
      tanggalJatuhTempo: json['tanggal_jatuh_tempo'],
      status: json['status'],
    );
  }
}
