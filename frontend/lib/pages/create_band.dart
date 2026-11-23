import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../clients/bands_client.dart';
import '../clients/musician_client.dart';

class CreateBandPage extends StatefulWidget {
  const CreateBandPage({super.key});

  @override
  State<CreateBandPage> createState() => _CreateBandPageState();
}

class _CreateBandPageState extends State<CreateBandPage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  final TextEditingController bandNameController =
  TextEditingController();

  final TextEditingController descriptionController =
  TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? selectedImage;
  String? selectedGenre;
  bool isLoading = false;

  final List<String> genres = [
    'Rock',
    'Pop',
    'Metal',
    'Classical',
    'Jazz',
    'Indie',
    'Hip-Hop',
    'Other',
  ];

  @override
  void dispose() {
    bandNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1440,
    );

    if (picked != null && mounted) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  InputDecoration buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: secondaryText,
        fontSize: 14,
      ),
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: orange,
          width: 1.3,
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildBandPicture() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: isLoading ? null : pickImage,
            child: Container(
              width: 125,
              height: 125,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: orange,
                  width: 1.5,
                ),
              ),
              child: selectedImage != null
                  ? Image.file(
                selectedImage!,
                width: 125,
                height: 125,
                fit: BoxFit.cover,
              )
                  : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: orange,
                    size: 38,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add Photo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add your band profile picture',
            style: TextStyle(
              color: secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGenreSelection() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: genres.map((genre) {
        final bool isSelected = selectedGenre == genre;

        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  setState(() {
                    selectedGenre = genre;
                  });
                },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: isSelected ? orange : cardColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? orange : Colors.white24,
              ),
            ),
            child: Text(
              genre,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> saveBand() async {
    if (bandNameController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        selectedGenre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter band name, description and select a genre.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final band = await BandsClient.instance.createBand(
        bandName: bandNameController.text.trim(),
        description: descriptionController.text.trim(),
        genre: selectedGenre!,
        image: selectedImage,
      );

      if (mounted) {
        Navigator.pop(context, band);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Create Band',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 15, 22, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildBandPicture(),
            const SizedBox(height: 30),

            buildSectionTitle('Band Name'),
            TextField(
              controller: bandNameController,
              style: const TextStyle(color: Colors.white),
              decoration: buildInputDecoration(
                'Enter your band name',
              ),
            ),

            const SizedBox(height: 25),

            buildSectionTitle('Band Description'),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              maxLength: 300,
              style: const TextStyle(color: Colors.white),
              decoration: buildInputDecoration(
                'Tell people about your band...',
              ),
            ),

            const SizedBox(height: 15),

            buildSectionTitle('Select Music Genre'),
            buildGenreSelection(),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : saveBand,
                icon: isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Icon(Icons.add, size: 22),
                label: Text(
                  isLoading ? 'Creating...' : 'Create Band',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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