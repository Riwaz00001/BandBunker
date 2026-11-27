
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../clients/bands_client.dart';
import '../clients/musician_client.dart';
import '../clients/owner_client.dart';
import '../models/musician_models.dart';

class JammingRoom {
  final int roomId;
  final String name;
  final String location;
  final String type;
  final String price;
  final String imageUrl;
  final String rating;
  final String reviews;
  final String distance;
  final List<String> facilities;
  final bool available;

  const JammingRoom({
    required this.roomId,
    required this.name,
    required this.location,
    required this.type,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.facilities,
    this.available = false,
  });
}

class RoomsPage extends StatefulWidget {
  final VoidCallback onProfileTap;
  const RoomsPage({
    super.key,
  required this.onProfileTap,});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  final TextEditingController searchController =
  TextEditingController();

  // Empty until real room information comes from the backend.
  final List<JammingRoom> rooms = [];
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final fetched = await OwnerClient.instance.getRooms();
      final mapped = fetched.map((r) => JammingRoom(
        roomId: r.roomId,
        name: r.name,
        location: r.location,
        type: r.roomType,
        price: 'NPR ${r.price}',
        imageUrl: '',
        rating: '0',
        reviews: '0',
        distance: '',
        facilities: r.timeSlots,
        available: true,
      )).toList();
      if (mounted) setState(() {
        rooms
          ..clear()
          ..addAll(mapped);
      });
    } catch (_) {}
  }

  Future<void> _bookRoom(JammingRoom room) async {
    final bands = await BandsClient.instance.getMyBands();
    if (bands.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You need to own a band to book.')));
      return;
    }
    int selectedBand = bands.first.bandId;
    String selectedSlot = room.facilities.isNotEmpty ? room.facilities.first : '';
    DateTime selectedDate = DateTime.now();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Book Slot'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<int>(
                  value: selectedBand,
                  items: bands.map((b) => DropdownMenuItem(value: b.bandId, child: Text(b.bandName))).toList(),
                  onChanged: (v) => setState(() => selectedBand = v ?? selectedBand),
                ),
                DropdownButton<String>(
                  value: selectedSlot,
                  items: room.facilities.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => selectedSlot = v ?? selectedSlot),
                ),
                TextButton(
                  onPressed: () async {
                    final d = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
                    if (d != null) setState(() => selectedDate = d);
                  },
                  child: Text('Date: ${selectedDate.toIso8601String().split('T').first}'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Book')),
            ],
          );
        });
      },
    );
    if (ok != true) return;
    try {
      await BandsClient.instance.createBooking(room.roomId, selectedBand, selectedDate, selectedSlot);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking request sent.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
  Future<void> _loadProfile() async {
    try {
      final profile = await MusicianClient.instance.getProfile();
      if (profile.profilePicUrl != null && profile.profilePicUrl!.isNotEmpty && mounted) {
        // CachedNetworkImage handles caching on demand; no precache needed.
      }
      if (mounted) setState(() => _profile = profile);
    } catch (_) {}
  }

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
                  'ROOMS',
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
                child: (_profile?.profilePicUrl != null && _profile!.profilePicUrl!.isNotEmpty)
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: _profile!.profilePicUrl!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          memCacheWidth: 256,
                          maxWidthDiskCache: 256,
                          placeholder: (context, url) => const SizedBox(
                            width: 20,
                            height: 20,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, stackTrace) => const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      )
                    : const Icon(
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

  // Page Heading
  Widget buildHeading() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Nearby Jamming Rooms',
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
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
          hintText: 'Search by Studio and Location',
          hintStyle: const TextStyle(
            color: secondaryText,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: secondaryText,
            size: 27,
          ),
          suffixIcon: const Icon(
            Icons.tune,
            color: secondaryText,
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

  // Room Image
  Widget buildRoomImage(JammingRoom room) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 185,
          child: room.imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: room.imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  maxWidthDiskCache: 1080,
                  placeholder: (context, url) => buildImagePlaceholder(),
                  errorWidget: (context, url, stackTrace) => buildImagePlaceholder(),
                )
              : buildImagePlaceholder(),
        ),

        // Available Status
        Positioned(
          top: 14,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  color: room.available
                      ? const Color(0xFF00C58E)
                      : Colors.grey,
                  size: 9,
                ),
                const SizedBox(width: 7),
                Text(
                  room.available
                      ? 'Instant Book Available'
                      : 'Check Availability',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Room Name and Price
        Positioned(
          left: 16,
          right: 16,
          bottom: 14,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      room.type,
                      style: const TextStyle(
                        color: Color(0xFFFFA982),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFFFFA982),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${room.distance} away • ${room.location}',
                            style: const TextStyle(
                              color: Color(0xFFFFB08F),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'STARTS AT',
                    style: TextStyle(
                      color: Color(0xFFFFB08F),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    room.price,
                    style: const TextStyle(
                      color: Color(0xFFFFB08F),
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'per hour',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildImagePlaceholder() {
    return Container(
      color: const Color(0xFF303039),
      child: const Center(
        child: Icon(
          Icons.music_video_outlined,
          color: secondaryText,
          size: 55,
        ),
      ),
    );
  }

  // Individual Room Card
  Widget buildRoomCard(JammingRoom room) {
    return Container(
      margin: const EdgeInsets.only(
        left: 22,
        right: 22,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildRoomImage(room),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Facilities
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: room.facilities.map((facility) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF303039),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFFFFA982),
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            facility,
                            style: const TextStyle(
                              color: secondaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                // Rating and Booking
                Row(
                  children: [
                    Expanded(child: Container()),
                    ElevatedButton.icon(
                      onPressed: () => _bookRoom(room),
                      icon: const Icon(Icons.calendar_month, size: 19),
                      label: const Text('Book Slot'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
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
          ),
        ],
      ),
    );
  }

  // Empty State
  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.meeting_room_outlined,
              color: Colors.white24,
              size: 65,
            ),

            const SizedBox(height: 15),

            const Text(
              'No jamming rooms available yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Music rooms and studios will appear here when room owners register on Band Bunker.',
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
          child: rooms.isEmpty
              ? buildEmptyState()
              : ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              return buildRoomCard(rooms[index]);
            },
          ),
        ),
      ],
    );
  }
}

