import 'package:flutter/material.dart';
import 'pages/landing_page.dart'; // <--- Tambahkan halaman ini
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'admin/admin_login_page.dart';

void main() => runApp(const MiniLibraryApp());

class MiniLibraryApp extends StatelessWidget {
  const MiniLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChimpLib',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B3B1A),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFEFE9D5),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B3B1A),
            foregroundColor: const Color(0xFFFFFFFF),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const LandingPage(), // <--- Ganti jadi landing page
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        // Tambahkan route admin jika ada
        '/admin_login': (context) => const AdminLoginPage(), // <-- contoh
      },
    );
  }
}
