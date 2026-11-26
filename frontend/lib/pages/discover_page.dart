
import 'package:cached_network_image/cached_network_image.dart';
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

  // Filter posts according to musician name
  List<Post> get filteredPosts {
    final searchText = searchController.text.trim().toLowerCase();

    if (searchText.isEmpty) {
      return posts;
    }

    return posts.where((post) {
      return post.musicianName.toLowerCase().contains(searchText);
    }).toList();
  }

  final TextEditingController searchController =
  TextEditingController();

  final List<Post> posts = [];
  bool _loading = true;
  Profile? _profile;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Load all posts
  Future<void> _loadPosts() async {
    setState(() => _loading = true);

    try {
      final allPosts =
      await MusicianClient.instance.getAllPosts();

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

  // Load current user's profile
  Future<void> _loadProfile() async {
    try {
      final profile =
      await MusicianClient.instance.getProfile();

      if (profile.profilePicUrl != null &&
          profile.profilePicUrl!.isNotEmpty &&
          mounted) {
        // CachedNetworkImage handles caching on demand; no precache needed.
      }

      if (mounted) {
        setState(() => _profile = profile);
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadProfile();
  }

  // Compact Top Header
  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/band_bunker_logo.jpeg',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 11),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BAND BUNKER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'DISCOVER',
                  style: TextStyle(
                    color: orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: widget.onProfileTap,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: orange,
                  width: 2,
                ),
              ),
              child: (
                  _profile?.profilePicUrl != null &&
                      _profile!.profilePicUrl!.isNotEmpty
              )
                  ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: _profile!.profilePicUrl!,
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                  memCacheWidth: 256,
                  maxWidthDiskCache: 256,
                  placeholder: (context, url) => const SizedBox(
                    width: 38,
                    height: 38,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, stackTrace) =>
                  const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              )
                  : const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Compact Discover Heading
  Widget buildDiscoverHeading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Discover Musicians',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Text(
              'ACTIVE',
              style: TextStyle(
                color: Color(0xFFFFB08F),
                fontSize: 11,
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

        onChanged: (value) {
          setState(() {});
        },

        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),

        decoration: InputDecoration(
          hintText: 'Search musicians by name...',
          hintStyle: const TextStyle(
            color: secondaryText,
            fontSize: 13,
          ),

          prefixIcon: const Icon(
            Icons.search,
            color: secondaryText,
            size: 23,
          ),

          filled: true,
          fillColor: cardColor,
          isDense: true,

          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
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
                builder: (context) =>
                const ArtistPostsPage(),
              ),
            );

            if (created == true && mounted) {
              _loadPosts();
            }
          },
          icon: const Icon(
            Icons.add,
            size: 20,
          ),
          label: const Text(
            'Add Post',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
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
  Widget buildNoSearchResults() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              color: Colors.white24,
              size: 60,
            ),

            SizedBox(height: 15),

            Text(
              'No musicians found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'Try searching with another musician name.',
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
    final displayedPosts = filteredPosts;

    return RefreshIndicator(
      onRefresh: _loadPosts,
      color: orange,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [

          // Header
          SliverToBoxAdapter(
            child: buildHeader(),
          ),

          // Discover heading
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                buildDiscoverHeading(),
                const SizedBox(height: 14),
              ],
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Column(
              children: [
                buildSearchBar(),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // Add Post button
          SliverToBoxAdapter(
            child: Column(
              children: [
                buildAddPostButton(),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Loading indicator
          if (_loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(
                  color: orange,
                ),
              ),
            )

          // No posts available
          else if (posts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: buildEmptyState(),
            )

          // No matching musician
          else if (displayedPosts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: buildNoSearchResults(),
              )

            // Display filtered posts
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return PostCard(
                      post: displayedPosts[index],
                    );
                  },
                  childCount: displayedPosts.length,
                ),
              ),
        ],
      ),
    );
  }
}
