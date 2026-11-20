
import 'package:flutter/material.dart';
import 'role_selection.dart';
import '../clients/musician_client.dart';
import '../clients/owner_client.dart';
import '../models/musician_models.dart';
import '../models/owner_models.dart';
import '../services/token_storage.dart';
import 'musician_dashboard.dart';
import 'owner_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color orange = Colors.deepOrange;
  static const Color background = Colors.black;
  static const Color fieldColor = Color(0xFF202026);
  static const Color textColor = Color(0xFFE8E4F0);
  static const Color secondaryText = Color(0xFFBDB8C9);

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isOwner = false;

  // Navigate to role selection
  void openRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RoleSelectionPage(),
      ),
    );
  }

  void login() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      if (isOwner) {
        final token = await OwnerClient.instance.login(
          OwnerLoginRequest(
            email: emailController.text.trim(),
            password: passwordController.text,
          ),
        );
        await TokenStorage.saveOwnerToken(token);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const owner_dashboard()),
          );
        }
      } else {
        final token = await MusicianClient.instance.login(
          LoginRequest(
            email: emailController.text.trim(),
            password: passwordController.text,
          ),
        );
        await TokenStorage.saveMusicianToken(token);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const musician_dashboard()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }


  Widget buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD8BFB5),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          keyboardType: isPassword
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your ${label.toLowerCase()}';
            }

            if (!isPassword &&
                !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                    .hasMatch(value.trim())) {
              return 'Please enter a valid email address';
            }

            if (isPassword && value.length < 8) {
              return 'Password must contain at least 8 characters';
            }

            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF45444D),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              icon,
              color: secondaryText,
              size: 25,
            ),
            suffixIcon: isPassword
                ? IconButton(
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
              icon: Icon(
                isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_outlined,
                color: secondaryText,
                size: 25,
              ),
            )
                : null,
            filled: true,
            fillColor: fieldColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 22,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: orange,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Colors.redAccent,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMusicBars() {
    final heights = [22.0, 32.0, 43.0, 27.0, 15.0, 33.0, 42.0, 24.0];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(heights.length, (index) {
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: 8,
          height: heights[index],
          decoration: BoxDecoration(
            color: index < 4
                ? orange
                : (index == 4
                ? secondaryText
                : Colors.white24),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 18,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 36,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/band_bunker_logo.jpeg',
                          width: 220,
                          height: 105,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Center(
                        child: Image.asset(
                          'assets/images/band_bunker_written.jpeg',
                          width: 200,
                          height: 85,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 0),

                      // Heading
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Sign in to connect with the local musicians.',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 22),

                      buildMusicBars(),

                      const SizedBox(height: 45),

                      // Email
                      buildInputField(
                        label: 'Email Address',
                        hint: 'user@gmail.com',
                        icon: Icons.email_outlined,
                        controller: emailController,
                      ),

                      const SizedBox(height: 25),


                      const SizedBox(height: 8),

                      buildInputField(
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        controller: passwordController,
                        isPassword: true,
                      ),

                      const SizedBox(height: 35),

                      // Role toggle
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Musician'),
                            selected: !isOwner,
                            onSelected: (_) => setState(() => isOwner = false),
                          ),
                          const SizedBox(width: 10),
                          ChoiceChip(
                            label: const Text('Owner'),
                            selected: isOwner,
                            onSelected: (_) => setState(() => isOwner = true),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 65,
                        child: ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(
                                Icons.bolt,
                                size: 25,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Bottom registration link
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 15,
                              ),
                            ),
                            TextButton(
                              onPressed: openRegistration,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                              ),
                              child: const Text(
                                'Create an Account',
                                style: TextStyle(
                                  color: orange,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
