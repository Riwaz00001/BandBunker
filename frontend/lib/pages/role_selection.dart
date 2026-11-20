
import 'package:flutter/material.dart';
import 'register.dart';
import 'room_owner_register.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  static const Color orange = Colors.deepOrange;
  static const Color fieldColor = Color(0xFF212121);

  Widget roleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: fieldColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: orange, size: 38),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: orange,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/band_bunker_logo.jpeg',
                  width: 120,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
              
              const SizedBox(height: 45),
              const Text(
                'Join Band Bunker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose how you want to be part of our music community.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 35),

              roleCard(
                context: context,
                icon: Icons.mic,
                title: 'I am an Artist',
                description: 'Create your musician profile and connect with bands.',
                page: const RegisterPage(),
              ),

              const SizedBox(height: 20),

              roleCard(
                context: context,
                icon: Icons.storefront,
                title: 'I own a Music Room',
                description: 'Register your studio and welcome musicians.',
                page: const RoomOwnerRegisterPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
