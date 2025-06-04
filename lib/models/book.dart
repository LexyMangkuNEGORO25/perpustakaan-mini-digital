class Book {
  final int id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String category;
  final int? tahunTerbit;
  final double? rating;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.category,
    this.tahunTerbit,
    this.rating,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? 0,
      title: json['judul'] ?? '',
      author: json['penulis'] ?? '',
      description: json['deskripsi'] ?? '',
      coverUrl: json['url_gambar'] ?? '',
      category: json['kategori'] ?? '',
      tahunTerbit: json['tahun_terbit'] != null ? int.tryParse(json['tahun_terbit'].toString()) : null,
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': title,
      'penulis': author,
      'deskripsi': description,
      'url_gambar': coverUrl,
      'kategori': category,
      'tahun_terbit': tahunTerbit,
      'rating': rating,
    };
  }
}
