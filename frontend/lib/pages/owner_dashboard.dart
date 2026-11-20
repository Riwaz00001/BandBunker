import 'package:flutter/material.dart';
import '../services/token_storage.dart';
import 'login_page.dart';

class owner_dashboard extends StatefulWidget {
  const owner_dashboard({super.key});

  @override
  State<owner_dashboard> createState() => _owner_dashboardState();
}

class _owner_dashboardState extends State<owner_dashboard> {
  void _logout() async {
    await TokenStorage.clearOwnerToken();
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
        title: Text("Owner DashBoard"),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
    );
  }
}
