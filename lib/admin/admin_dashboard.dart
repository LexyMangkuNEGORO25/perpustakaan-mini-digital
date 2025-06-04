import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import 'admin_form_page.dart';
import 'package:jwt_decode/jwt_decode.dart'; // Untuk decode token JWT

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Book> bookList = [];
  bool isLoading = false;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    _fetchBooks();
  }

  // Ambil role pengguna dari token
  Future<void> _fetchUserRole() async {
    final token = await ApiService.getToken();
    if (token != null) {
      // Decode token untuk mendapatkan peran pengguna
      final decodedToken = Jwt.parseJwt(token);
      setState(() {
        userRole = decodedToken['peran']; // 'admin' or 'peminjam'
      });
    }
  }

  // Ambil daftar buku dari backend
  Future<void> _fetchBooks() async {
    setState(() {
      isLoading = true;
    });
    try {
      final books = await ApiService.fetchBooks();
      setState(() {
        bookList = books;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data buku: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk navigasi ke halaman tambah/edit buku
  void _navigateToForm([Book? book, int? index]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminFormPage(
          book: book,
          onSave: (newBook) => _addOrEditBook(newBook, index),
        ),
      ),
    );
  }

  // Admin bisa melakukan CRUD pada buku (admin hanya bisa menambah dan mengedit)
  Future<void> _addOrEditBook(Book book, [int? index]) async {
    bool success;
    if (index == null) {
      success = await ApiService.addBook(book);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil ditambahkan')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan buku')),
        );
      }
    } else {
      success = await ApiService.updateBook(book.id, book);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil diperbarui')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui buku')),
        );
      }
    }
    await _fetchBooks();
  }

  // Fungsi untuk meminjam buku
  Future<void> _borrowBook(Book book) async {
    final success = await ApiService.borrowBook(
      userId: 1, // ID pengguna, ganti dengan ID pengguna yang sesuai
      bookId: book.id,
      tanggalPinjam: DateTime.now().toString(),
      tanggalJatuhTempo: DateTime.now().add(Duration(days: 7)).toString(),
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buku berhasil dipinjam')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal meminjam buku')),
      );
    }
  }

  // Fungsi untuk menghapus buku
  Future<void> _deleteBook(int bookId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: const Text("Yakin ingin menghapus buku ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ApiService.deleteBook(bookId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buku berhasil dihapus')),
      );
      await _fetchBooks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus buku')),
      );
    }
  }

  // Membangun kartu buku berdasarkan peran
  Widget _buildBookCard(Book book) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            book.coverUrl.isNotEmpty
                ? book.coverUrl
                : 'https://via.placeholder.com/70x100.png?text=No+Image',
            width: 50,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.book),
          ),
        ),
        title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Penulis: ${book.author}\nKategori: ${book.category}'),
        isThreeLine: true,
        trailing: userRole == 'admin' 
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.amber),
                    onPressed: () => _navigateToForm(book, bookList.indexOf(book)),
                    tooltip: "Edit",
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteBook(book.id),
                    tooltip: "Hapus",
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: () => _borrowBook(book),
                child: const Text("Pinjam Buku"),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              ApiService.logout();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookList.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada buku.\nTekan tombol + untuk menambah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: bookList.length,
                  itemBuilder: (context, index) {
                    return _buildBookCard(bookList[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B3B1A),
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: "Tambah Buku",
      ),
    );
  }
}
