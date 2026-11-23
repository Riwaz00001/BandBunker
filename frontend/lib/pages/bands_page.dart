
import 'package:flutter/material.dart';
import 'package:frontend/pages/create_band.dart';
import 'package:frontend/pages/edit_band.dart';
import 'package:frontend/pages/bands_posts.dart';
import 'package:frontend/models/band_models.dart';
import 'package:frontend/clients/bands_client.dart';

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

  Band? myBand;
  bool isLoadingBand = true;

  @override
  void initState() {
    super.initState();
    _loadMyBand();
  }

  Future<void> _loadMyBand() async {
    try {
      final band = await BandsClient.instance.getMyBand();
      if (!mounted) return;
      setState(() {
        myBand = band;
      });
    } catch (_) {
      // keep myBand null; the create flow surfaces real errors
    } finally {
      if (mounted) {
        setState(() {
          isLoadingBand = false;
        });
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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
              Icons.groups_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeading() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Bands Looking for Members',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

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

  // Create Band / My Band Button
  Widget buildMyBandButton() {
    if (isLoadingBand) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const SizedBox(
              width: 23,
              height: 23,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ),
      );
    }

    final bool bandExists = myBand != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () async {
            if (!bandExists) {
              final result = await Navigator.push<Band>(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateBandPage(),
                ),
              );

              if (result != null && mounted) {
                setState(() {
                  myBand = result;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Band created successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyBandPage(
                    band: myBand!,
                  ),
                ),
              );
            }
          },
          icon: Icon(
            bandExists ? Icons.groups : Icons.add,
            size: 23,
          ),
          label: Text(
            bandExists ? 'My Band' : 'Create Band',
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
    );
  }

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

        // This button changes from Create Band to My Band.
        buildMyBandButton(),

        const SizedBox(height: 18),

        Expanded(
          child: buildEmptyState(),
        ),
      ],
    );
  }
}

// MY BAND DETAILS PAGE

class MyBandPage extends StatefulWidget {
  final Band band;

  const MyBandPage({
    super.key,
    required this.band,
  });

  @override
  State<MyBandPage> createState() => _MyBandPageState();
}

class _MyBandPageState extends State<MyBandPage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  late Band _band;

  @override
  void initState() {
    super.initState();
    _band = widget.band;
  }

  void addPosts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BandsPostPage(),
      ),
    );
  }

  Future<void> editBand() async {
    final updated = await Navigator.push<Band>(
      context,
      MaterialPageRoute(
        builder: (context) => EditBandPage(band: _band),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _band = updated;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Band updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 110,
              height: 110,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFF303039),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: orange,
                  width: 1.5,
                ),
              ),
              child: _band.profilePicUrl != null
                  ? Image.network(
                _band.profilePicUrl!,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(
                  Icons.groups,
                  color: orange,
                  size: 55,
                ),
              )
                  : const Icon(
                Icons.groups,
                color: orange,
                size: 55,
              ),
            ),
          ),

          const SizedBox(height: 22),

          Center(
            child: Text(
              _band.bandName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _band.genre,
                style: const TextStyle(
                  color: orange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'About Our Band',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            _band.description ?? '',
            style: const TextStyle(
              color: secondaryText,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMembersCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.groups_outlined,
                color: orange,
              ),
              SizedBox(width: 9),
              Text(
                'Band Members',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              buildMember('Pratik', 'Guitarist'),
              const SizedBox(width: 22),
              buildMember('Member 2', 'Vocalist'),
              const SizedBox(width: 22),
              buildMember('Member 3', 'Drummer'),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            'Member management coming soon.',
            style: TextStyle(
              color: secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMember(String name, String role) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
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
              size: 30,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            role,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: secondaryText,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    bool outlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: orange,
          side: const BorderSide(
            color: orange,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      )
          : ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
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
    );
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
          'My Band',
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
            buildInfoCard(),

            const SizedBox(height: 22),

            buildMembersCard(),

            const SizedBox(height: 25),

            buildActionButton(
              title: 'Add Posts',
              icon: Icons.add_photo_alternate_outlined,
              onPressed: addPosts,
            ),

            const SizedBox(height: 15),

            buildActionButton(
              title: 'Edit Band Profile',
              icon: Icons.edit_outlined,
              onPressed: editBand,
              outlined: true,
            ),
          ],
        ),
      ),
    );
  }
}
