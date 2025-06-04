import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../widgets/book_card.dart';
import '../pages/detail_page.dart';
import '../services/api_service.dart';
import '../pages/return_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Book> allBooks = [];
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'Semua';
  List<String> categories = ['Semua', 'Teknologi', 'Fiksi', 'Sejarah', 'Bisnis', 'Pendidikan'];
  int _selectedIndex = 0;
  bool isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchBooks();

    // Polling setiap 20 detik untuk update buku terbaru
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _fetchBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchBooks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final books = await ApiService.fetchBooks();
      setState(() {
        allBooks = books;
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

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Book> get filteredBooks {
    final query = _searchController.text.toLowerCase();
    return allBooks.where((book) {
      final matchCategory = selectedCategory == 'Semua' || book.category == selectedCategory;
      final matchSearch =
          book.title.toLowerCase().contains(query) || book.author.toLowerCase().contains(query);
      return matchCategory && matchSearch;
    }).toList();
  }

  void _showLatestBooksNotification() {
    final latestBooks = allBooks.take(3).toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notifikasi Buku Terbaru'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: latestBooks.length,
            itemBuilder: (context, index) {
              final book = latestBooks[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(book.coverUrl, width: 40, height: 60, fit: BoxFit.cover),
                ),
                title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Penulis: ${book.author}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(book: book)),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: const Color(0xFFE7EFC7),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  book.coverUrl,
                  width: 70,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 100,
                    color: const Color(0xFFE7EFC7),
                    child: const Icon(Icons.book, color: Color(0xFFE7EFC7)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style:
                          const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'by ${book.author}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      book.category,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF8A784E), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tahun Terbit: ${book.tahunTerbit ?? '-'}',
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    Text(
                      'Rating: ${book.rating != null ? book.rating!.toStringAsFixed(1) : '-'}',
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ChimpLib.',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  fontFamily: 'Orbitron',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 30),
                onPressed: _showLatestBooksNotification,
                tooltip: 'Notifikasi Buku Terbaru',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari Produk, Judul Buku, atau Penulis',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFE7EFC7),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: InputDecoration(
              labelText: 'Filter Kategori',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedCategory = value;
                });
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: filteredBooks.isEmpty
              ? const Center(child: Text('Buku tidak ditemukan.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    return _buildBookCard(book);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReturnPage() {
    return const Center(child: Text('Halaman Pengembalian (Coming Soon)'));
  }

  Widget _buildHistoryPage() {
    return const Center(child: Text('Halaman Riwayat (Coming Soon)'));
  }

  Widget _buildAccountPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 100, color: Color(0xFFFFFFFF)),
          const SizedBox(height: 16),
          const Text(
            'Akun Kamu',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_selectedIndex) {
      case 0:
        content = _buildBookList();
        break;
      case 1:
        content = _buildReturnPage();
        break;
      case 2:
        content = _buildHistoryPage();
        break;
      case 3:
        content = _buildAccountPage();
        break;
      default:
        content = _buildBookList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFAEC8A4),
      body: SafeArea(child: content),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF3B3B1A),
        unselectedItemColor: const Color(0xFF9E9E9E),
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_return), label: 'Kembali'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}
