import 'package:flutter/material.dart';
import '../clients/musician_client.dart';
import '../helpers/alert_helper.dart';
import '../models/musician_models.dart';
import '../pages/artist_posts.dart';
import '../widgets/post_card.dart';

class DiscoverPage extends StatefulWidget {
  final VoidCallback onProfileTap;

  const DiscoverPage({
    super.key,
    required this.onProfileTap,
  });

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  final TextEditingController searchController = TextEditingController();

  final List<Post> posts = [];
  bool _loading = true;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    try {
      final allPosts = await MusicianClient.instance.getAllPosts();
      if (mounted) {
        setState(() {
          posts
            ..clear()
            ..addAll(allPosts);
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

  @override
  void initState() {
    super.initState();
    _loadPosts();
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

          GestureDetector(
            onTap: widget.onProfileTap,
            child: Container(
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

  // Search Bar
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
          onPressed: () async {
            final created = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => const ArtistPostsPage(),
              ),
            );
            if (created == true && mounted) {
              _loadPosts();
            }
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
              'No posts to discover yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'Musician posts will appear here when users share content.',
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
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: orange),
                )
              : RefreshIndicator(
                  onRefresh: _loadPosts,
                  child: posts.isEmpty
                      ? buildEmptyState()
                      : ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            return PostCard(post: posts[index]);
                          },
                        ),
                ),
        ),
      ],
    );
  }
}
