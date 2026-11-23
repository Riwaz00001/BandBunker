import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../clients/musician_client.dart';
import '../helpers/alert_helper.dart';
import '../models/musician_models.dart';
import '../services/token_storage.dart';
import '../widgets/post_card.dart';
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

  Profile? _profile;
  bool _loading = true;

  final List<Post> _myPosts = [];
  bool _postsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadMyPosts();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await MusicianClient.instance.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AlertHelper.error(context, e.toString());
      }
    }
  }

  Future<void> _loadMyPosts() async {
    setState(() => _postsLoading = true);
    try {
      final myPosts = await MusicianClient.instance.getMyPosts();
      if (mounted) {
        setState(() {
          _myPosts
            ..clear()
            ..addAll(myPosts);
          _postsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _postsLoading = false);
        AlertHelper.error(context, e.toString());
      }
    }
  }

  String get _artistName => _profile?.name ?? 'Pratik Pariyar';
  String get _artistEmail => _profile?.email ?? 'pariyarpratik450@gmail.com';
  String get _biography => _profile?.bio ??
      'Artist...';
  String? get _profilePicUrl => _profile?.profilePicUrl;

  Future<void> openEditProfile() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          biography: _biography,
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadProfile();
      await _loadMyPosts();
      if (mounted) {
        AlertHelper.success(context, 'Profile updated successfully!');
      }
    }
  }


  Future<void> logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Confirm Logout',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: secondaryText,
              fontSize: 14,
            ),
          ),
          actions: [
            // No button
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'No',
                style: TextStyle(
                  color: secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Yes button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    // If user selects No or closes the dialog
    if (shouldLogout != true) return;

    // Clear login token
    await TokenStorage.clearMusicianToken();

    if (!mounted) return;

    // Navigate to Login page
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

  Widget _buildAvatar() {
    if (_profilePicUrl != null && _profilePicUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _profilePicUrl!,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          key: ValueKey(_profilePicUrl),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.broken_image,
              color: secondaryText,
              size: 48,
            ),
          ),
        ),
      );
    }
    return const CircleAvatar(
      radius: 48,
      backgroundColor: fieldColor,
      child: Icon(
        Icons.person,
        size: 55,
        color: secondaryText,
      ),
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
          const SizedBox(height: 15),
          _buildAvatar(),
          const SizedBox(height: 15),
          Text(
            _artistName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _artistEmail,
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
          buildInformationField('Full Name', _artistName),
          const SizedBox(height: 18),
          buildInformationField('Email Address', _artistEmail),
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
            _biography,
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

  Widget buildMyPostsCard() {
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
            'My Posts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_postsLoading)
            const Center(
              child: CircularProgressIndicator(color: orange),
            )
          else if (_myPosts.isEmpty)
            const Center(
              child: Text(
                'No posts yet. Create one from Discover.',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 14,
                ),
              ),
            )
          else
            Column(
              children: _myPosts.asMap().entries.map((entry) {
                final index = entry.key;
                final post = entry.value;
                return Column(
                  children: [
                    PostCard(post: post),
                    if (index < _myPosts.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Divider(
                          color: Color(0xFF303039),
                          height: 1,
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: buildLoading(),
      );
    }

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

              const SizedBox(height: 20),

              buildMyPostsCard(),

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
  static const Color fieldColor = Color(0xFF101017);
  static const Color secondaryText = Color(0xFFBDB8C9);

  late TextEditingController biographyController;
  File? _selectedImage;
  bool _isSaving = false;

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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> saveChanges() async {
    final bio = biographyController.text.trim();
    if (bio.isEmpty) {
      AlertHelper.error(context, 'Biography cannot be empty.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await MusicianClient.instance.updateProfile(
        bio: bio,
        image: _selectedImage,
      );
      if (mounted) {
        AlertHelper.success(context, 'Profile updated successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AlertHelper.error(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImage == null) return const SizedBox.shrink();
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedImage!,
            height: 120,
            width: 120,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
      ],
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

            _buildImagePreview(),

            Center(
              child: OutlinedButton.icon(
                onPressed: _isSaving ? null : _pickImage,
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
              enabled: !_isSaving,
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
                onPressed: _isSaving ? null : saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
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
