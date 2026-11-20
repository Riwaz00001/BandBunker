import 'package:flutter/material.dart';
import '../services/token_storage.dart';
import 'login_page.dart';

class musician_dashboard extends StatefulWidget {
  const musician_dashboard({super.key});

  @override
  State<musician_dashboard> createState() => _musician_dashboardState();
}

class _musician_dashboardState extends State<musician_dashboard> {
  void _logout() async {
    await TokenStorage.clearMusicianToken();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Musicians Dashboard"),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
    );
  }
}
