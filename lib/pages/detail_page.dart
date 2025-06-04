import 'package:flutter/material.dart';
import 'borrow_page.dart';
import '../models/book.dart';

class DetailPage extends StatelessWidget {
  final Book book;
  final bool isBorrowed;

  const DetailPage({
    super.key,
    required this.book,
    this.isBorrowed = false,
  });

  Widget _buildRatingStars(double? rating) {
    if (rating == null) return const SizedBox.shrink();
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))
                ], borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.hardEdge,
                child: Image.network(
                  book.coverUrl,
                  height: 250,
                  width: 170,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(height: 250, width: 170, color: Colors.grey[300], child: const Icon(Icons.book, size: 100, color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Judul: ${book.title}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text('Penulis: ${book.author}', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Tahun Terbit: ${book.tahunTerbit ?? '-'}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(width: 24),
                _buildRatingStars(book.rating),
                const SizedBox(width: 8),
                Text(book.rating != null ? book.rating!.toStringAsFixed(1) : '-', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 20),
            Text(book.description, style: const TextStyle(fontSize: 16, height: 1.5), textAlign: TextAlign.justify),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 6,
                      backgroundColor: Colors.blue.shade700,
                      shadowColor: Colors.blue.shade300,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BorrowPage(book: book)),
                      );
                    },
                    child: const Text('Pinjam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),

                if (isBorrowed)
                  const SizedBox(width: 24),

                if (isBorrowed)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 6,
                        backgroundColor: Colors.green.shade700,
                        shadowColor: Colors.green.shade300,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/return');
                      },
                      child: const Text('Kembalikan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
