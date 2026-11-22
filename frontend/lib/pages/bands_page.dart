
import 'package:flutter/material.dart';

class Band {
  final String name;
  final String genre;
  final String location;
  final String description;
  final String lookingFor;
  final String imageUrl;
  final List<String> instruments;
  final int members;

  const Band({
    required this.name,
    required this.genre,
    required this.location,
    required this.description,
    required this.lookingFor,
    required this.imageUrl,
    required this.instruments,
    required this.members,
  });
}

class BandsPage extends StatefulWidget {
  const BandsPage({super.key});

  @override
  State<BandsPage> createState() => _BandsPageState();
}

class _BandsPageState extends State<BandsPage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  final TextEditingController searchController =
  TextEditingController();

  // Empty until real band information comes from the backend.
  final List<Band> bands = [];

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
                  'BANDS',
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

  // Page Heading
  Widget buildHeading() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Bands Looking for Members',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
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
          hintText: 'Search Bands and Location',
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

  // Band Image
  Widget buildBandImage(Band band) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: band.imageUrl.isNotEmpty
          ? Image.network(
        band.imageUrl,
        width: 85,
        height: 85,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return buildImagePlaceholder();
        },
      )
          : buildImagePlaceholder(),
    );
  }

  Widget buildImagePlaceholder() {
    return Container(
      width: 85,
      height: 85,
      color: const Color(0xFF303039),
      child: const Icon(
        Icons.groups,
        color: secondaryText,
        size: 42,
      ),
    );
  }

  // Individual Band Card
  Widget buildBandCard(Band band) {
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
          // Band Information
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildBandImage(band),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      band.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      band.location,
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${band.genre} • ${band.members} Members',
                      style: const TextStyle(
                        color: Color(0xFFFFA982),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Looking for a Member
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF493020),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.graphic_eq,
                  color: Color(0xFFFFB08F),
                  size: 18,
                ),

                const SizedBox(width: 7),

                Flexible(
                  child: Text(
                    'Looking for ${band.lookingFor}',
                    style: const TextStyle(
                      color: Color(0xFFFFB08F),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Text(
            band.description,
            style: const TextStyle(
              color: secondaryText,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 15),

          // Instruments / Requirements
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: band.instruments.map((instrument) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF303039),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  instrument,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 22),

          // Buttons
          Row(
            children: [
              TextButton(
                onPressed: () {
                  // Open band details page later.
                },
                child: const Text(
                  'View Band  →',
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
                    horizontal: 18,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ],
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
              Icons.groups_outlined,
              color: Colors.white24,
              size: 65,
            ),

            SizedBox(height: 15),

            Text(
              'No bands available yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'Bands looking for musicians will appear here when they join Band Bunker.',
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

        const SizedBox(height: 22),

        buildHeading(),

        const SizedBox(height: 22),

        buildSearchBar(),

        const SizedBox(height: 18),

        Expanded(
          child: bands.isEmpty
              ? buildEmptyState()
              : ListView.builder(
            itemCount: bands.length,
            itemBuilder: (context, index) {
              return buildBandCard(
                bands[index],
              );
            },
          ),
        ),
      ],
    );
  }
}
