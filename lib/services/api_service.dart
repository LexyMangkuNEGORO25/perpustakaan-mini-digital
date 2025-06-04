import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api'; // Ganti sesuai backend
  static String? token;

  // Simpan token JWT ke SharedPreferences
  static Future<void> saveToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', newToken);
    token = newToken;
  }

  // Ambil token JWT dari SharedPreferences
  static Future<String?> getToken() async {
    if (token != null) return token;
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('jwt_token');
    return token;
  }

  // Login user, simpan token jika sukses
  static Future<bool> login({required String usernameOrEmail, required String kataSandi}) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final body = jsonEncode({'usernameOrEmail': usernameOrEmail, 'kata_sandi': kataSandi});
    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return true;
    }
    return false;
  }

  // Registrasi user peminjam
  static Future<bool> register({
    required String username,
    required String email,
    required String kataSandi,
    required String namaLengkap,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final body = jsonEncode({
      'username': username,
      'email': email,
      'kata_sandi': kataSandi,
      'peran': 'peminjam',
      'nama_lengkap': namaLengkap,
    });
    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);
    return response.statusCode == 201;
  }

  // Ambil daftar buku
  static Future<List<Book>> fetchBooks() async {
    final url = Uri.parse('$baseUrl/books');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> booksJson = jsonDecode(response.body);
      return booksJson.map<Book>((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data buku');
    }
  }

  // Tambah buku baru (admin only, butuh token)
  static Future<bool> addBook(Book book) async {
  final url = Uri.parse('$baseUrl/books');
  final t = await getToken();
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      if (t != null) 'Authorization': 'Bearer $t', // Kirim token di header
    },
    body: jsonEncode(book.toJson()),
  );

  if (response.statusCode == 201) {
    return true;
  } else {
    print('Error: ${response.body}'); // Debugging response error
    return false;
  }
}


  // Update buku berdasarkan id (admin only)
  static Future<bool> updateBook(int id, Book book) async {
    final url = Uri.parse('$baseUrl/books/$id');
    final t = await getToken();
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (t != null) 'Authorization': 'Bearer $t', // Kirim token di header
      },
      body: jsonEncode(book.toJson()),
    );
    return response.statusCode == 200;
  }

  // Hapus buku berdasarkan id (admin only)
  static Future<bool> deleteBook(int id) async {
    final url = Uri.parse('$baseUrl/books/$id');
    final t = await getToken();
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (t != null) 'Authorization': 'Bearer $t', // Kirim token di header
      },
    );
    return response.statusCode == 200;
  }

  // Pinjam buku (butuh token)
  static Future<bool> borrowBook({
    required int userId,
    required int bookId,
    required String tanggalPinjam,
    required String tanggalJatuhTempo,
  }) async {
    final url = Uri.parse('$baseUrl/transactions/pinjam');
    final t = await getToken(); // Pastikan token valid
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (t != null) 'Authorization': 'Bearer $t', // Kirim token di header
      },
      body: jsonEncode({
        'id_pengguna': userId,
        'id_buku': bookId,
        'tanggal_pinjam': tanggalPinjam,
        'tanggal_jatuh_tempo': tanggalJatuhTempo,
      }),
    );

    // Cek apakah peminjaman berhasil
    if (response.statusCode == 201) {
      return true;
    } else {
      print('Error: ${response.body}'); // Debugging response error
      return false;
    }
  }

  // Kembalikan buku (butuh token)
  static Future<bool> returnBook({required int peminjamanId}) async {
    final url = Uri.parse('$baseUrl/transactions/kembali/$peminjamanId');
    final t = await getToken();
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (t != null) 'Authorization': 'Bearer $t', // Kirim token di header
      },
      body: jsonEncode({}),
    );
    return response.statusCode == 200;
  }

  // Ambil riwayat peminjaman (butuh token)
  static Future<List<dynamic>> fetchBorrowHistory(int userId) async {
    final url = Uri.parse('$baseUrl/transactions/riwayat/$userId');
    final t = await getToken();
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (t != null) 'Authorization': 'Bearer $t', // Kirim token di header
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil riwayat peminjaman');
    }
  }

  // Filter buku yang sedang dipinjam user
  static Future<List<dynamic>> fetchBorrowedBooks(int userId) async {
    final allHistory = await fetchBorrowHistory(userId);
    return allHistory.where((h) => h['status'] == 'dipinjam').toList();
  }

  // Logout, hapus token
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    token = null;
  }
}


