import 'package:flutter/material.dart';
import 'login_page.dart';
import '../admin/admin_login_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7EFC7),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/ChimpLib.png', width: 300, height: 300,),
              const SizedBox(height: 0),
              const Text(
                'ChimpLib.',
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Color(0xFF5A827E)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                child: const Text('Login Sebagai User'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginPage())),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B3B1A)),
                child: const Text('Login Admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
