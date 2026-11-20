
import 'package:flutter/material.dart';
import 'package:frontend/pages/login_page.dart';

class RoomOwnerRegisterPage extends StatefulWidget {
  const RoomOwnerRegisterPage({super.key});

  @override
  State<RoomOwnerRegisterPage> createState() =>
      _RoomOwnerRegisterPageState();
}

class _RoomOwnerRegisterPageState
    extends State<RoomOwnerRegisterPage> {
  static const Color orange = Colors.deepOrange;
  static const Color background = Colors.black;
  static const Color fieldColor = Color(0xFF212121);
  static const Color secondaryText = Colors.white70;

  final _formKey = GlobalKey<FormState>();

  final ownerNameController = TextEditingController();
  final studioNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedRoomType = 'Rehearsal Room';

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool acceptedTerms = false;

  final List<String> roomTypes = [
    'Rehearsal Room',
    'Jamming Studio',
    'Recording Studio',
  ];

  Widget buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isConfirmPassword = false,
  }) {
    bool isVisible = isPassword
        ? isPasswordVisible
        : isConfirmPasswordVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText:
          (isPassword || isConfirmPassword) && !isVisible,
          style: const TextStyle(color: Colors.white),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter $label';
            }

            if (label == 'Email Address' &&
                !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                    .hasMatch(value.trim())) {
              return 'Enter a valid email address';
            }

            if (label == 'Phone Number' &&
                value.trim().length < 7) {
              return 'Enter a valid phone number';
            }

            if (isPassword && value.length < 8) {
              return 'Password must be at least 8 characters';
            }

            if (isConfirmPassword &&
                value != passwordController.text) {
              return 'Passwords do not match';
            }

            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: orange),
            suffixIcon: (isPassword || isConfirmPassword)
                ? IconButton(
              icon: Icon(
                isVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.white54,
              ),
              onPressed: () {
                setState(() {
                  if (isPassword) {
                    isPasswordVisible = !isPasswordVisible;
                  } else {
                    isConfirmPasswordVisible =
                    !isConfirmPasswordVisible;
                  }
                });
              },
            )
                : null,
            filled: true,
            fillColor: fieldColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: orange,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRoomTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Room Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),
        DropdownButtonFormField<String>(
          value: selectedRoomType,
          dropdownColor: fieldColor,
          style: const TextStyle(color: Colors.white),
          iconEnabledColor: orange,
          decoration: InputDecoration(
            filled: true,
            fillColor: fieldColor,
            prefixIcon: const Icon(
              Icons.music_note,
              color: orange,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: orange,
                width: 1.5,
              ),
            ),
          ),
          items: roomTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedRoomType = value;
              });
            }
          },
        ),
      ],
    );
  }

  void createOwnerAccount() {
    if (!_formKey.currentState!.validate()) return;

    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please accept the Terms and Conditions',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Owner registration details completed!'),
      ),
    );

    // Backend/Firebase registration will be connected later.
    debugPrint('Owner: ${ownerNameController.text}');
    debugPrint('Studio: ${studioNameController.text}');
    debugPrint('Room Type: $selectedRoomType');
  }

  @override
  void dispose() {
    ownerNameController.dispose();
    studioNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'ROOM OWNER REGISTRATION',
                  style: TextStyle(
                    color: orange,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'List Your Space',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'JOIN OUR COMMUNITY AND MAKE YOUR MUSIC SPACE AVAILABLE FOR ARTISTS.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 30),

                buildInputField(
                  label: 'Owner Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                  controller: ownerNameController,
                ),

                const SizedBox(height: 20),

                buildInputField(
                  label: 'Studio / Room Name',
                  hint: 'Enter your studio name',
                  icon: Icons.storefront_outlined,
                  controller: studioNameController,
                ),

                const SizedBox(height: 20),

                buildInputField(
                  label: 'Email Address',
                  hint: 'Enter your email address',
                  icon: Icons.email_outlined,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                buildInputField(
                  label: 'Phone Number',
                  hint: 'Enter your contact number',
                  icon: Icons.phone_outlined,
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 20),

                buildInputField(
                  label: 'Studio Location',
                  hint: 'Enter your studio address',
                  icon: Icons.location_on_outlined,
                  controller: locationController,
                ),

                const SizedBox(height: 20),

                buildRoomTypeDropdown(),

                const SizedBox(height: 20),

                buildInputField(
                  label: 'Password',
                  hint: 'Create a password',
                  icon: Icons.lock_outline,
                  controller: passwordController,
                  isPassword: true,
                ),

                const SizedBox(height: 20),

                buildInputField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline,
                  controller: confirmPasswordController,
                  isConfirmPassword: true,
                ),

                const SizedBox(height: 20),

                // Terms and conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: acceptedTerms,
                      activeColor: orange,
                      onChanged: (value) {
                        setState(() {
                          acceptedTerms = value ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'I agree to the Terms and Conditions and Privacy Policy.',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Register button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: createOwnerAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'CREATE OWNER ACCOUNT',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
