import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/book.dart';  // Ensure that your Book model matches the API response

class ReturnPage extends StatefulWidget {
  const ReturnPage({super.key});

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  List<Book> borrowedBooks = [];  // List to store borrowed books that haven't been returned
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBorrowedBooks();
  }

  // Fetch borrowed books from the API
  Future<void> _fetchBorrowedBooks() async {
    final userId = 1; // Replace with the actual logged-in user's ID
    final url = Uri.parse('http://localhost:3000/api/peminjaman/not-returned/$userId'); // Backend API endpoint

    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          borrowedBooks = data.map((bookData) => Book.fromJson(bookData)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load borrowed books');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  // Function to handle book return
  void _returnBook(Book book) async {
    final url = Uri.parse('http://localhost:3000/api/peminjaman/return/${book.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tanggal_kembali': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        borrowedBooks.remove(book);  // Remove the returned book from the list
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Buku "${book.title}" berhasil dikembalikan!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to return the book')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengembalian Buku'),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : borrowedBooks.isEmpty
                ? const Center(child: Text('Tidak ada buku yang sedang dipinjam.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: borrowedBooks.length,
                    itemBuilder: (context, index) {
                      final book = borrowedBooks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: Colors.white,
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  book.coverUrl,
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
                                    Text(book.title,
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('Penulis: ${book.author}',
                                        style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.blue.shade200,
                                ),
                                onPressed: () => _returnBook(book),  // Trigger book return
                                child: const Text(
                                  'Kembalikan',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
