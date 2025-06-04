import 'package:flutter/material.dart';
import '../models/book.dart';

class AdminFormPage extends StatefulWidget {
  final Book? book;
  final void Function(Book book) onSave;

  const AdminFormPage({super.key, this.book, required this.onSave});

  @override
  State<AdminFormPage> createState() => _AdminFormPageState();
}

class _AdminFormPageState extends State<AdminFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController descriptionController;
  late TextEditingController coverUrlController;
  late TextEditingController yearController;
  late TextEditingController ratingController;
  late String category;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    titleController = TextEditingController(text: book?.title ?? '');
    authorController = TextEditingController(text: book?.author ?? '');
    descriptionController = TextEditingController(text: book?.description ?? '');
    coverUrlController = TextEditingController(text: book?.coverUrl ?? '');
    yearController = TextEditingController(text: book?.tahunTerbit != null ? book!.tahunTerbit.toString() : '');
    ratingController = TextEditingController(text: book?.rating != null ? book!.rating.toString() : '');
    category = book?.category ?? 'Teknologi';
  }

  // Validator untuk URL gambar
  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL gambar wajib diisi';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || (!uri.isAbsolute)) {
      return 'URL gambar tidak valid';
    }
    return null;
  }

  // Validator untuk Tahun Terbit
  String? _validateYear(String? value) {
    if (value == null || value.isEmpty) return 'Tahun terbit wajib diisi';
    final year = int.tryParse(value);
    if (year == null || year < 1000 || year > DateTime.now().year) {
      return 'Tahun terbit tidak valid';
    }
    return null;
  }

  // Validator untuk Rating
  String? _validateRating(String? value) {
    if (value == null || value.isEmpty) return null; // opsional
    final rating = double.tryParse(value);
    if (rating == null || rating < 0 || rating > 5) {
      return 'Rating harus antara 0 sampai 5';
    }
    return null;
  }

  // Fungsi submit untuk menambahkan atau memperbarui buku
  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newBook = Book(
        id: widget.book?.id ?? DateTime.now().millisecondsSinceEpoch,
        title: titleController.text,
        author: authorController.text,
        description: descriptionController.text,
        coverUrl: coverUrlController.text,
        category: category,
        tahunTerbit: int.tryParse(yearController.text),
        rating: double.tryParse(ratingController.text),
      );
      widget.onSave(newBook); // Menyimpan data buku

      // Menampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buku berhasil ditambahkan')),
      );

      // Kembali ke halaman sebelumnya setelah sukses simpan
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFAEC8A4),
        title: Text(widget.book == null ? 'Tambah Buku' : 'Edit Buku', style: const TextStyle(color: Colors.white)),
      ),
      backgroundColor: const Color(0xFFE7EFC7),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Buku',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.book),
                ),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: authorController,
                decoration: InputDecoration(
                  labelText: 'Penulis',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: coverUrlController,
                decoration: InputDecoration(
                  labelText: 'URL Gambar Sampul',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.image),
                ),
                validator: _validateUrl,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tahun Terbit',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                validator: _validateYear,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: ratingController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Rating (0 - 5)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.star),
                ),
                validator: _validateRating,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: ['Teknologi', 'Fiksi', 'Sejarah', 'Bisnis', 'Pendidikan'].map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => category = value);
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B3B1A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                icon: const Icon(Icons.save),
                label: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
