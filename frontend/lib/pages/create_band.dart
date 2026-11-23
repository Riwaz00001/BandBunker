
import 'package:flutter/material.dart';

class CreateBandPage extends StatefulWidget {
  final Map<String, String>? initialData;

  const CreateBandPage({
    super.key,
    this.initialData,
  });

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

  String? selectedGenre;

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

  final List<Map<String, String>> members = [
    {'name': 'Pratik', 'role': 'Guitarist'},
    {'name': 'Member 2', 'role': 'Vocalist'},
    {'name': 'Member 3', 'role': 'Drummer'},
  ];

  bool get isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      bandNameController.text =
          widget.initialData!['name'] ?? '';

      descriptionController.text =
          widget.initialData!['description'] ?? '';

      selectedGenre = widget.initialData!['genre'];
    }
  }

  @override
  void dispose() {
    bandNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void showMemberMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Adding band members will be available later.',
        ),
      ),
    );
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
            onTap: () {
              // Band picture upload will be connected later.
            },
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: orange,
                  width: 1.5,
                ),
              ),
              child: const Column(
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
          onTap: () {
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

  Widget buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: buildSectionTitle('Band Members'),
            ),
            Container(
              decoration: BoxDecoration(
                color: orange.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: showMemberMessage,
                icon: const Icon(
                  Icons.add,
                  color: orange,
                  size: 25,
                ),
                tooltip: 'Add band member',
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.groups_outlined,
                    color: orange,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${members.length} Members',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 105,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(width: 22),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF303039),
                            border: Border.all(
                              color: orange,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: secondaryText,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          members[index]['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          members[index]['role']!,
                          style: const TextStyle(
                            color: secondaryText,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Member profiles will be connected later.',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void saveBand() {
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

    final Map<String, String> bandData = {
      'name': bandNameController.text.trim(),
      'description': descriptionController.text.trim(),
      'genre': selectedGenre!,
    };

    Navigator.pop(context, bandData);
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
        title: Text(
          isEditing ? 'Edit Band' : 'Create Band',
          style: const TextStyle(
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

            const SizedBox(height: 28),

            buildMembersSection(),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: saveBand,
                icon: Icon(
                  isEditing ? Icons.save_outlined : Icons.add,
                  size: 22,
                ),
                label: Text(
                  isEditing ? 'Save Changes' : 'Create Band',
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
