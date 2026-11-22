
import 'package:flutter/material.dart';
import 'package:frontend/pages/artist_posts.dart';

class Musician {
  final String name;
  final String instrument;
  final String genre;
  final String location;
  final String distance;
  final String imageUrl;
  final List<String> skills;
  final bool isOnline;

  const Musician({
    required this.name,
    required this.instrument,
    required this.genre,
    required this.location,
    required this.distance,
    required this.imageUrl,
    required this.skills,
    this.isOnline = false,
  });
}

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  final TextEditingController searchController =
  TextEditingController();

  // Musician data will come from the backend later.
  final List<Musician> musicians = [];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Top Header
  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 15,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/band_bunker_logo.jpeg',
              width: 55,
              height: 55,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BAND BUNKER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'DISCOVER',
                  style: TextStyle(
                    color: orange,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: orange,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // Discover Heading
  Widget buildDiscoverHeading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Discover Musicians',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Text(
              'ACTIVE',
              style: TextStyle(
                color: Color(0xFFFFB08F),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Search Bar (no category filtering)
  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: TextField(
        controller: searchController,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: 'Search by Name and Roles.',
          hintStyle: const TextStyle(
            color: secondaryText,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: secondaryText,
            size: 27,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              // Advanced filters can be added later.
            },
            icon: const Icon(
              Icons.tune,
              color: secondaryText,
            ),
          ),
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
  // Add Post Button
  Widget buildAddPostButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ElevatedButton.icon(
          onPressed: () {
           Navigator.push(
             context,
             MaterialPageRoute(
               builder: (context) => const ArtistPostsPage(),
             ),
           );
          },
          icon: const Icon(
            Icons.add,
            size: 21,
          ),
          label: const Text(
            'Add Post',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // Individual Musician Card
  Widget buildMusicianCard(Musician musician) {
    return Container(
      margin: const EdgeInsets.only(
        left: 22,
        right: 22,
        bottom: 22,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: musician.imageUrl.isNotEmpty
                        ? Image.network(
                      musician.imageUrl,
                      width: 95,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return buildProfilePlaceholder();
                      },
                    )
                        : buildProfilePlaceholder(),
                  ),

                  Positioned(
                    bottom: -5,
                    right: -7,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: musician.isOnline
                            ? const Color(0xFF00C58E)
                            : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cardColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      musician.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      musician.instrument,
                      style: const TextStyle(
                        color: Color(0xFFFFA982),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${musician.genre} • ${musician.location}',
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              Text(
                musician.distance,
                style: const TextStyle(
                  color: Color(0xFFFFA982),
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: musician.skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF303039),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              TextButton(
                onPressed: () {
                  // Open musician profile later.
                },
                child: const Text(
                  'View Profile  →',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Connect feature will be available soon.',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.person_add_alt_1,
                  size: 19,
                ),
                label: const Text('Connect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Profile Image Placeholder
  Widget buildProfilePlaceholder() {
    return Container(
      width: 95,
      height: 110,
      color: const Color(0xFF303039),
      child: const Icon(
        Icons.person,
        color: secondaryText,
        size: 45,
      ),
    );
  }

  // Empty State
  Widget buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              color: Colors.white24,
              size: 65,
            ),

            SizedBox(height: 15),

            Text(
              'No musicians to discover yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'Musician profiles will appear here when users join Band Bunker.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeader(),

        const SizedBox(height: 18),

        buildDiscoverHeading(),

        const SizedBox(height: 22),

        buildSearchBar(),

        const SizedBox(height: 12),

        buildAddPostButton(),

        const SizedBox(height: 18),

        Expanded(
          child: musicians.isEmpty
              ? buildEmptyState()
              : ListView.builder(
            itemCount: musicians.length,
            itemBuilder: (context, index) {
              return buildMusicianCard(
                musicians[index],
              );
            },
          ),
        ),
      ],
    );
  }
}
