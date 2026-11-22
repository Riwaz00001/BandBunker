
import 'package:flutter/material.dart';
import '../services/token_storage.dart';
import 'login_page.dart';

class ProfileData {
  final String biography;

  ProfileData({
    required this.biography,
  });
}

class MyProfileView extends StatefulWidget {
  const MyProfileView({super.key});

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color cardColor = Color(0xFF202026);
  static const Color fieldColor = Color(0xFF101017);
  static const Color secondaryText = Color(0xFFBDB8C9);

  String artistName = 'Pratik Pariyar';
  String artistEmail = 'pariyarpratik450@gmail.com';

  String biography =
      'Write something about yourself, your musical journey and experience...';

  Future<void> openEditProfile() async {
    final result = await Navigator.push<ProfileData>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          biography: biography,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        biography = result.biography;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: orange,
          ),
        );
      }
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearMusicianToken();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
          (route) => false,
    );
  }

  Widget buildProfileHeading() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Manage your musician profile',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: logout,
          tooltip: 'Logout',
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.12),
            foregroundColor: Colors.redAccent,
          ),
          icon: const Icon(
            Icons.exit_to_app,
            size: 21,
          ),
        ),
      ],
    );
  }

  Widget buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton.icon(
              onPressed: openEditProfile,
              icon: const Icon(
                Icons.edit,
                size: 16,
                color: orange,
              ),
              label: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const CircleAvatar(
            radius: 48,
            backgroundColor: fieldColor,
            child: Icon(
              Icons.person,
              size: 55,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            artistName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            artistEmail,
            style: const TextStyle(
              color: secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInformationField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: secondaryText,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: fieldColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGeneralInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'General Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          buildInformationField('Full Name', artistName),
          const SizedBox(height: 18),
          buildInformationField('Email Address', artistEmail),
        ],
      ),
    );
  }

  Widget buildBiographyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Biography',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            biography,
            style: const TextStyle(
              color: secondaryText,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/band_bunker_logo.jpeg',
                    height: 42,
                    width: 42,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BAND BUNKER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'MUSICIAN COMMUNITY',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 9,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              buildProfileHeading(),

              const SizedBox(height: 22),

              buildProfileCard(),

              const SizedBox(height: 20),

              buildGeneralInformation(),

              const SizedBox(height: 20),

              buildBiographyCard(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// EDIT PROFILE SCREEN

class EditProfilePage extends StatefulWidget {
  final String biography;

  const EditProfilePage({
    super.key,
    required this.biography,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color cardColor = Color(0xFF202026);
  static const Color fieldColor = Color(0xFF101017);
  static const Color secondaryText = Color(0xFFBDB8C9);

  late TextEditingController biographyController;

  @override
  void initState() {
    super.initState();

    biographyController = TextEditingController(
      text: widget.biography,
    );
  }

  @override
  void dispose() {
    biographyController.dispose();
    super.dispose();
  }

  void saveChanges() {
    Navigator.pop(
      context,
      ProfileData(
        biography: biographyController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Picture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Backend photo selection/upload functionality will be added later.
                },
                icon: const Icon(
                  Icons.add_a_photo_outlined,
                  color: orange,
                ),
                label: const Text(
                  'Select Profile Photo',
                  style: TextStyle(
                    color: orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: orange),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Center(
              child: Text(
                'Upload your Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Biography',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: biographyController,
              maxLines: 6,
              maxLength: 300,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Tell us about yourself and your musical journey...',
                hintStyle: const TextStyle(
                  color: secondaryText,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: fieldColor,
                counterStyle: const TextStyle(
                  color: secondaryText,
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
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
