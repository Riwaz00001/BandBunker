
import 'package:flutter/material.dart';
import 'package:frontend/pages/create_band.dart';
import 'package:frontend/pages/invites_page.dart';
import 'package:frontend/pages/band_profile_page.dart';
import 'package:frontend/widgets/band_card.dart';
import 'package:frontend/models/band_models.dart';
import 'package:frontend/clients/bands_client.dart';
import 'package:frontend/services/token_storage.dart';
import 'package:frontend/helpers/alert_helper.dart';

class BandsPage extends StatefulWidget {
  final VoidCallback onProfileTap;

  const BandsPage({
    super.key,
    required this.onProfileTap,
  });
  @override
  State<BandsPage> createState() => _BandsPageState();
}

class _BandsPageState extends State<BandsPage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  final TextEditingController searchController = TextEditingController();

  List<Band> myBands = [];
  bool isLoadingBands = true;
  int? myMusicianId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadMyMusicianId();
    await _loadMyBands();
  }

  Future<void> _loadMyMusicianId() async {
    final id = await TokenStorage.getMusicianId();
    if (mounted) setState(() => myMusicianId = id);
  }

  Future<void> _loadMyBands() async {
    try {
      final bands = await BandsClient.instance.getMyBands();
      if (!mounted) return;
      setState(() {
        myBands = bands;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load bands: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingBands = false;
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
          // Invites button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InvitesPage()),
              ).then((_) => _loadMyBands());
            },
            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
            tooltip: 'Invites',
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
                Icons.person_outlined,
                color: Colors.white,
                size: 28,
              ),
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
          'My Bands',
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
          hintText: 'Search Bands',
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
    if (isLoadingBands) {
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

    final bool ownsBand = myBands.any((b) => b.ownerId == myMusicianId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () async {
            if (!ownsBand) {
              final result = await Navigator.push<Band>(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateBandPage(),
                ),
              );

              if (result != null && mounted) {
                setState(() {
                  myBands.insert(0, result);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Band created successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else {
              final ownedBand = myBands.firstWhere((b) => b.ownerId == myMusicianId);
              final result = await Navigator.push<Band>(
                context,
                MaterialPageRoute(
                  builder: (context) => BandProfilePage(bandId: ownedBand.bandId),
                ),
              );

              if (result != null && mounted) {
                setState(() {
                  final idx = myBands.indexWhere((b) => b.bandId == result.bandId);
                  if (idx >= 0) myBands[idx] = result;
                });
              }
            }
          },
          icon: Icon(
            ownsBand ? Icons.groups : Icons.add,
            size: 23,
          ),
          label: Text(
            ownsBand ? 'My Band' : 'Create Band',
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
              'No bands yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create a band or accept an invite to get started.',
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
          child: RefreshIndicator(
            onRefresh: _loadMyBands,
            color: orange,
            child: isLoadingBands
                ? const Center(child: CircularProgressIndicator(color: orange))
                : myBands.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: buildEmptyState(),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: myBands.length,
                        itemBuilder: (context, index) {
                          final band = myBands[index];
                          final isOwner = band.ownerId == myMusicianId;
                          return BandCard(
                            band: band,
                            isOwner: isOwner,
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }
}
