import 'package:flutter/material.dart';
import '../models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCard({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book.coverUrl,
                  width: 70,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('by ${book.author}', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(book.category, style: const TextStyle(color: Colors.teal)), // Tambahan kategori
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
