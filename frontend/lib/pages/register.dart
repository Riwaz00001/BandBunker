
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../clients/musician_client.dart';
import '../helpers/alert_helper.dart';
import '../models/musician_models.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  // COLOURS
  static const Color orange = Colors.deepOrange;
  static const Color background = Colors.black;
  static const Color fieldColor = Color(0xFF212121);
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Colors.brown;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // CONFIRM PASSWORD FIELD KEY
  final GlobalKey<FormFieldState<String>> _confirmPasswordFieldKey =
  GlobalKey<FormFieldState<String>>();

  // TEXT FIELD CONTROLLERS
  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  // PASSWORD VISIBILITY
  bool showPassword = false;
  bool showConfirmPassword = false;

  // TERMS AND CONDITIONS
  bool agreeToTerms = false;

  // REGISTRATION REQUEST IN FLIGHT
  bool isSubmitting = false;

  // SELECTED MUSICAL ROLE
  // Initially no role is selected.
  String selectedRole = '';

  // AVAILABLE MUSICAL ROLES
  final List<Map<String, String>> roles = [
    {'name': 'Vocalist', 'icon': '🎤'},
    {'name': 'Guitarist', 'icon': '🎸'},
    {'name': 'Drummer', 'icon': '🥁'},
    {'name': 'Bassist', 'icon': '🎸'},
    {'name': 'Pianist', 'icon': '🎹'},
  ];

  // DISPOSE CONTROLLERS
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // REUSABLE INPUT FIELD
  Widget buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool isConfirmPassword = false,
    String? helper,
    TextInputType keyboardType = TextInputType.text,
  }) {

    bool isObscure = isPassword
        ? !showPassword
        : isConfirmPassword
        ? !showConfirmPassword
        : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // FIELD LABEL AND HELPER TEXT
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Text(
              label,
              style: const TextStyle(
                color: primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            if (helper != null)
              Text(
                helper,
                style: const TextStyle(
                  color: secondaryText,
                  fontSize: 12,
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        // TEXT FORM FIELD
        TextFormField(

          key: isConfirmPassword
              ? _confirmPasswordFieldKey
              : null,

          controller: controller,

          obscureText: isPassword || isConfirmPassword
              ? isObscure
              : false,

          keyboardType: keyboardType,

          // AUTOMATIC CONFIRM PASSWORD VALIDATION
          autovalidateMode: isConfirmPassword
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,

          onChanged: (value) {

            // Recheck confirm password when original
            // password is changed.
            if (isPassword &&
                confirmPasswordController.text.isNotEmpty) {

              _confirmPasswordFieldKey.currentState?.validate();
            }
          },

          style: const TextStyle(
            color: primaryText,
            fontSize: 16,
          ),

          decoration: InputDecoration(

            hintText: hint,

            hintStyle: const TextStyle(
              color: Color(0xFF88746F),
              fontSize: 15,
            ),

            prefixIcon: Icon(
              icon,
              color: secondaryText,
              size: 23,
            ),

            // PASSWORD VISIBILITY BUTTON
            suffixIcon: isPassword || isConfirmPassword
                ? IconButton(
              icon: Icon(
                isObscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: secondaryText,
              ),

              onPressed: () {
                setState(() {

                  if (isPassword) {
                    showPassword = !showPassword;
                  } else {
                    showConfirmPassword =
                    !showConfirmPassword;
                  }

                });
              },
            )
                : null,

            filled: true,
            fillColor: fieldColor,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 23,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(23),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(23),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(23),
              borderSide: const BorderSide(
                color: orange,
                width: 1.5,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(23),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(23),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
          ),

          // INPUT VALIDATION
          validator: (value) {

            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }

            if (isPassword && value.length < 8) {
              return 'Password must contain at least 8 characters';
            }

            if (isConfirmPassword &&
                value != passwordController.text) {
              return 'Passwords do not match';
            }

            if (label == 'Email Address' &&
                !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                    .hasMatch(value.trim())) {
              return 'Enter a valid email address';
            }

            return null;
          },
        ),
      ],
    );
  }

  // MUSICAL ROLE SELECTION
  Widget buildRoleChip(Map<String, String> role) {

    bool isSelected = selectedRole == role['name'];

    return GestureDetector(

      onTap: () {
        setState(() {
          selectedRole = role['name']!;
        });
      },

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 200),

        padding: const EdgeInsets.symmetric(
          horizontal: 19,
          vertical: 13,
        ),

        decoration: BoxDecoration(
          color: isSelected ? orange : fieldColor,
          borderRadius: BorderRadius.circular(40),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            if (isSelected) ...[

              const Icon(
                Icons.check,
                color: Colors.white,
                size: 19,
              ),

              const SizedBox(width: 8),

              Text(
                role['icon']!,
                style: const TextStyle(fontSize: 17),
              ),

            ] else ...[

              Text(
                role['icon']!,
                style: const TextStyle(fontSize: 17),
              ),
            ],

            const SizedBox(width: 8),

            Text(
              role['name']!,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : secondaryText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CREATE ACCOUNT FUNCTION
  Future<void> createAccount() async {

    // VALIDATE ALL INPUT FIELDS
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // CHECK MUSICAL ROLE
    if (selectedRole.isEmpty) {
      AlertHelper.error(context, 'Please select your primary role.');
      return;
    }

    // CHECK TERMS AND CONDITIONS
    if (!agreeToTerms) {
      AlertHelper.error(
        context,
        'Please agree to the Terms and Conditions.',
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {

      // CALL THE BACKEND REGISTRATION ENDPOINT
      await MusicianClient.instance.register(
        RegisterRequest(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          role: selectedRole,
        ),
      );

      if (!mounted) return;

      AlertHelper.success(
        context,
        'Welcome to Band Bunker, ${nameController.text.trim()}!',
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 900),
      );

      if (!mounted) return;

      Navigator.maybePop(context);

    } on ApiException catch (e) {

      if (!mounted) return;

      AlertHelper.error(context, e.message);

    } finally {

      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  // MAIN INTERFACE
  @override
  Widget build(BuildContext context) {

    return AnnotatedRegion<SystemUiOverlayStyle>(

      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF101018),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),

      child: Scaffold(
        backgroundColor: background,

        body: SafeArea(

          child: SingleChildScrollView(

            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // BACK BUTTON ONLY
                  Row(
                    children: [

                      CircleAvatar(
                        radius: 25,
                        backgroundColor: fieldColor,

                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: primaryText,
                          ),

                          onPressed: () {
                            Navigator.maybePop(context);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  // ARTIST INFORMATION
                  const Row(
                    children: [

                      Icon(
                        Icons.graphic_eq,
                        color: orange,
                        size: 27,
                      ),

                      SizedBox(width: 12),

                      Text(
                        'ARTIST INFORMATION',
                        style: TextStyle(
                          color: secondaryText,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // MAIN HEADING
                  const Text(
                    'Join the Bunker',
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 31,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TAGLINE - ALWAYS ONE LINE
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                    ),

                    child: SizedBox(
                      width: double.infinity,

                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,

                        child: const Text(
                          'START YOUR JOURNEY AND START COLLABORATING',

                          maxLines: 1,
                          softWrap: false,

                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // FULL NAME
                  buildInputField(
                    label: 'Full Name',
                    hint: 'e.g. Alex Shrestha',
                    icon: Icons.person_outline,
                    controller: nameController,
                    helper: 'Real or stage name',
                  ),

                  const SizedBox(height: 27),

                  // EMAIL ADDRESS
                  buildInputField(
                    label: 'Email Address',
                    hint: 'Enter your email address',
                    icon: Icons.alternate_email,
                    controller: emailController,
                    helper: 'Used for Invites',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 27),

                  // PASSWORD
                  buildInputField(
                    label: 'Password',
                    hint: 'Enter your password',
                    icon: Icons.lock_outline,
                    controller: passwordController,
                    helper: 'Minimum 8 characters',
                    isPassword: true,
                  ),

                  const SizedBox(height: 27),

                  // CONFIRM PASSWORD
                  buildInputField(
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    icon: Icons.lock_reset,
                    controller: confirmPasswordController,
                    isConfirmPassword: true,
                  ),

                  const SizedBox(height: 36),

                  // ROLE TITLE
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                    children: [

                      const Text(
                        'Primary Role / Instrument',
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(
                        '(Select your role)',
                        style: const TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // MUSICAL ROLE BUTTONS
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,

                    children: roles.map((role) {
                      return buildRoleChip(role);
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // TERMS AND CONDITIONS
                  Container(
                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0C12),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        SizedBox(
                          width: 25,
                          height: 25,

                          child: Checkbox(
                            value: agreeToTerms,

                            activeColor: orange,
                            checkColor: Colors.white,

                            side: const BorderSide(
                              color: secondaryText,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(5),
                            ),

                            onChanged: (value) {
                              setState(() {
                                agreeToTerms = value ?? false;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: RichText(
                            text: const TextSpan(

                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 14,
                                height: 1.5,
                              ),

                              children: [

                                TextSpan(
                                  text: 'I agree to the ',
                                ),

                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: Color(0xFFFFA47E),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                TextSpan(text: ', '),

                                TextSpan(
                                  text: 'Studio Safety Rules',
                                  style: TextStyle(
                                    color: Color(0xFFFFA47E),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                TextSpan(text: ', and '),

                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Color(0xFFFFA47E),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // CREATE ACCOUNT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 64,

                    child: ElevatedButton(

                      onPressed: isSubmitting ? null : createAccount,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        elevation: 8,

                        shadowColor: orange.withOpacity(0.3),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(22),
                        ),
                      ),

                      child: isSubmitting
                          ? const SizedBox(
                              height: 26,
                              width: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,

                              children: [

                                Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                SizedBox(width: 12),

                                Icon(
                                  Icons.arrow_forward,
                                  size: 25,
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // LOGIN LINK
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,

                      children: [

                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 16,
                          ),
                        ),

                        GestureDetector(

                          onTap: () {
                            // Navigate to LoginPage here.
                          },

                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              color: Color(0xFFFFA47E),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
