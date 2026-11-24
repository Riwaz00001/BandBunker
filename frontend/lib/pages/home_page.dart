import 'discover_page.dart';
import 'package:flutter/material.dart';
import 'bands_page.dart';
import 'rooms_page.dart';
import 'myprofile_view.dart';
import 'invites_page.dart';
import 'band_profile_page.dart';
import 'profile_page.dart';
import 'package:frontend/services/token_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color background = Colors.black;
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  int selectedIndex = 0;

  late final List<Widget> _pages = [
    buildHomeContent(),

    DiscoverPage(
      onProfileTap: () {
        setState(() {
          selectedIndex = 4;
        });
      },
    ),

    BandsPage(
      onProfileTap: (){
        setState(() {
          selectedIndex = 4;
        });
      },
    ),
    RoomsPage(
      onProfileTap: (){
        setState(() {
          selectedIndex = 4;
        });
      },
    ),
    const MyProfileView(),
  ];

  final TextEditingController searchController =
  TextEditingController();

  final List<String> pageTitles = [
    'Home',
    'Discover',
    'Bands',
    'Rooms',
    'Profile',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget buildHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top App Header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 15,
          ),
          child: Row(
            children: [
              // Band Bunker Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/band_bunker_logo.jpeg',
                  width: 55,
                  height: 55,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(width: 15),

              // App Name
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
                      'HOME',
                      style: TextStyle(
                        color: orange,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Icon
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = 4;
                  });
                },
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
        ),

        const SizedBox(height: 25),

        // Welcome Text
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Band Bunker',
                style: TextStyle(
                  color: Color(0xFFE8E4F0),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Ready to make some noise?',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search musicians',
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
                  // Search filters can be added later.
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
        ),

        const SizedBox(height: 25),

        // Empty content area.
        // Backend data will be displayed here later.
        const Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.music_note_rounded,
                  color: Colors.white24,
                  size: 55,
                ),
                SizedBox(height: 12),
                Text(
                  'Your music community starts here',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Musicians, bands and rooms will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildOtherPage(String title) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selectedIndex == 1
                ? Icons.explore_outlined
                : selectedIndex == 2
                ? Icons.groups_outlined
                : selectedIndex == 3
                ? Icons.meeting_room_outlined
                : Icons.person_outline,
            color: orange,
            size: 65,
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This page will be developed next.',
            style: TextStyle(
              color: secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: _pages,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: NavigationBar(
        height: 75,
        backgroundColor: const Color(0xFF121218),
        indicatorColor: orange.withOpacity(0.12),
        selectedIndex: selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        labelBehavior:
        NavigationDestinationLabelBehavior.alwaysShow,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Bands',
          ),
          NavigationDestination(
            icon: Icon(Icons.meeting_room_outlined),
            selectedIcon: Icon(Icons.meeting_room),
            label: 'Rooms',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
