
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../clients/owner_client.dart';
import '../services/token_storage.dart';
import 'login_page.dart';
import 'time_pricing.dart';

class owner_dashboard extends StatefulWidget {
  final String studioName;
  const owner_dashboard({
    super.key,
    this.studioName = '',
  });

  @override
  State<owner_dashboard> createState() => _owner_dashboardState();
}

class _owner_dashboardState extends State<owner_dashboard> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color background = Color(0xFF121212);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  List<RoomData> myRooms = [];

  List<BookingRequest> bookingRequests = [];

  int get pendingRequests =>
      bookingRequests.where((request) => request.status == 'Pending').length;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _loadBookings();
  }

  Future<void> _loadRooms() async {
    try {
      final rooms = await OwnerClient.instance.getMyRooms();
      if (mounted) {
        setState(() {
          myRooms = rooms
              .map(
                (r) => RoomData(
                  name: r.name,
                  roomType: r.roomType,
                  price: r.price,
                  timeSlots: r.timeSlots,
                ),
              )
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await OwnerClient.instance.getOwnerBookings();
      if (mounted) {
        setState(() {
          bookingRequests = bookings.map((b) => BookingRequest(
            bookingId: b['booking_id'] as int?,
            bandName: (b['band_name'] ?? '') as String,
            date: b['date'].toString(),
            time: (b['time_slot'] ?? '') as String,
            members: (b['band_member_count'] as int? ?? 0),
            profilePic: (b['band_profile_pic'] as String?),
            status: (b['status'] ?? 'Pending') as String,
          )).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: secondaryText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: secondaryText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: orange, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await TokenStorage.clearOwnerToken();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }


  Future<void> openRoomForm({RoomData? existingRoom}) async {
    final result = await Navigator.push<RoomData>(
      context,
      MaterialPageRoute(
        builder: (context) => TimePricingPage(
          studioName: widget.studioName,
          existingRoom: existingRoom,
        ),
      ),
    );

    if (result != null && mounted) {
      try {
        final room = await OwnerClient.instance.createRoom(
          result.roomType,
          result.price,
          result.timeSlots,
        );
        setState(() {
          final roomData = RoomData(
            name: room.name,
            roomType: room.roomType,
            price: room.price,
            timeSlots: room.timeSlots,
          );
          if (existingRoom != null) {
            final idx = myRooms.indexWhere((r) => identical(r, existingRoom));
            if (idx >= 0) {
              myRooms[idx] = roomData;
            }
          } else {
            myRooms.add(roomData);
          }
        });
      } catch (_) {
        setState(() {
          if (existingRoom != null) {
            final idx = myRooms.indexWhere((r) => identical(r, existingRoom));
            if (idx >= 0) {
              myRooms[idx] = result;
            }
          } else {
            myRooms.add(result);
          }
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingRoom == null
                ? 'Room details added!'
                : 'Room details updated!',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white38,
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: orange, size: 20),
      filled: true,
      fillColor: const Color(0xFF303039),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white10),
      ),
    );
  }

  // Dashboard header.
  Widget buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.music_note,
            color: orange,
            size: 28,
          ),
        ),

        const SizedBox(width: 13),

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
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'ROOM OWNER DASHBOARD',
                style: TextStyle(
                  color: orange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: _logout,
          tooltip: 'Logout',
          icon: const Icon(
            Icons.logout_rounded,
            color: secondaryText,
          ),
        ),
      ],
    );
  }

  Widget buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manage Your Studio',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 7),

        const Text(
          'Manage your rehearsal room and connect with bands looking for a place to practise.',
          style: TextStyle(
            color: secondaryText,
            fontSize: 13,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.meeting_room_outlined,
                title: 'My Rooms',
                value: myRooms.length.toString(),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _statCard(
                icon: Icons.pending_actions_outlined,
                title: 'Pending Requests',
                value: '$pendingRequests',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: orange, size: 25),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Main dashboard actions.
  Widget buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _actionCard(
            icon: Icons.add_business_rounded,
            title: myRooms.isEmpty ? 'Register Room' : 'My Rooms',
            subtitle: myRooms.isEmpty
                ? 'Add your rehearsal room'
                : 'View and edit your rooms',
            onTap: () {
              if (myRooms.isEmpty) {
                openRoomForm();
              } else {
                showAllRooms();
              }
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _actionCard(
            icon: Icons.event_note_rounded,
            title: 'Booking Requests',
            subtitle: 'View band requests',
            count: pendingRequests,
            onTap: showBookingRequests,
          ),
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int? count,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 145,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: orange, size: 23),
                ),

                const Spacer(),

                if (count != null && count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const Spacer(),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              subtitle,
              style: const TextStyle(
                color: secondaryText,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Registered rooms preview on dashboard.
  Widget buildRoomPreview() {
    if (myRooms.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.home_work_outlined,
              color: orange,
              size: 40,
            ),

            const SizedBox(height: 12),

            const Text(
              'Your rehearsal room starts here',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Register your room to let bands discover and book your space.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryText,
                fontSize: 12,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 15),

            OutlinedButton.icon(
              onPressed: openRoomForm,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Your Room'),
              style: OutlinedButton.styleFrom(
                foregroundColor: orange,
                side: const BorderSide(color: orange),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.meeting_room,
                color: orange,
                size: 22,
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  'YOUR REGISTERED ROOMS',
                  style: TextStyle(
                    color: orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              Text(
                '${myRooms.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...myRooms.map((room) => _roomPreviewCard(room)),
        ],
      ),
    );
  }

  Widget _roomPreviewCard(RoomData room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF303039),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.meeting_room,
                color: orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        room.roomType,
                        style: const TextStyle(
                          color: orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => openRoomForm(existingRoom: room),
                icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                tooltip: 'Edit room',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'NPR ${room.price} / hour',
            style: const TextStyle(
              color: orange,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: room.timeSlots.map((slot) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  slot,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // All rooms list sheet.
  void showAllRooms() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Rooms',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...myRooms.map(
                (room) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    room.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${room.roomType} \u2022 NPR ${room.price}/hr',
                    style: const TextStyle(
                      color: secondaryText,
                      fontSize: 13,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined, color: orange),
                    onPressed: () {
                      Navigator.pop(context);
                      openRoomForm(existingRoom: room);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Booking requests page.
  void showBookingRequests() async {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingRequestsPage(
          requests: List.of(bookingRequests),
          onChanged: () {
            if (mounted) setState(() => _loadBookings());
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader(),

              const SizedBox(height: 28),

              buildWelcomeSection(),

              const SizedBox(height: 25),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 13),

              buildActionButtons(),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => openRoomForm(),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Add Room',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 27),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'My Rehearsal Rooms',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (myRooms.isNotEmpty)
                    TextButton.icon(
                      onPressed: showAllRooms,
                      icon: const Icon(Icons.edit, size: 15),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: orange,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 13),

              buildRoomPreview(),

              const SizedBox(height: 25),

              const Text(
                'Booking Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              InkWell(
                onTap: showBookingRequests,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: orange,
                          size: 25,
                        ),
                      ),

                      const SizedBox(width: 13),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'See All Booking Requests',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Manage requests from bands',
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios,
                        color: secondaryText,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Booking request model for the frontend.
class BookingRequest {
  final int? bookingId;
  final String bandName;
  final String date;
  final String time;
  final int members;
  final String? profilePic;
  String status;

  BookingRequest({
    this.bookingId,
    required this.bandName,
    required this.date,
    required this.time,
    required this.members,
    this.profilePic,
    this.status = 'Pending',
  });
}

// Booking requests screen.
class BookingRequestsPage extends StatefulWidget {
  final List<BookingRequest> requests;
  final VoidCallback onChanged;

  const BookingRequestsPage({
    super.key,
    required this.requests,
    required this.onChanged,
  });

  @override
  State<BookingRequestsPage> createState() =>
      _BookingRequestsPageState();
}

class _BookingRequestsPageState extends State<BookingRequestsPage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  void updateRequest(BookingRequest request, String status) async {
    if (request.bookingId != null) {
      try {
        await OwnerClient.instance.updateBookingStatus(request.bookingId!, status);
      } catch (_) {}
    }
    setState(() {
      request.status = status;
    });

    widget.onChanged();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 'Accepted'
              ? 'Booking request accepted!'
              : 'Booking request rejected.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget buildRequestCard(BookingRequest request) {
    final isPending = request.status == 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: orange.withValues(alpha: 0.15),
                    backgroundImage:
                        request.profilePic != null && request.profilePic!.isNotEmpty
                            ? CachedNetworkImageProvider(request.profilePic!)
                            : null,
                    child: request.profilePic == null ||
                            request.profilePic!.isEmpty
                        ? const Icon(
                            Icons.groups,
                            color: orange,
                            size: 25,
                          )
                        : null,
                  ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.bandName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${request.members} band members',
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: request.status == 'Accepted'
                      ? Colors.green.withValues(alpha: 0.15)
                      : request.status == 'Rejected'
                      ? Colors.red.withValues(alpha: 0.15)
                      : orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.status,
                  style: TextStyle(
                    color: request.status == 'Accepted'
                        ? Colors.greenAccent
                        : request.status == 'Rejected'
                        ? Colors.redAccent
                        : orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: orange,
                size: 17,
              ),
              const SizedBox(width: 9),
              Text(
                request.date,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: orange,
                size: 17,
              ),
              const SizedBox(width: 9),
              Text(
                request.time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          if (isPending) ...[
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        updateRequest(request, 'Rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(
                        color: Colors.redAccent,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        updateRequest(request, 'Accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Booking Requests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: widget.requests.isEmpty
          ? const Center(
        child: Text(
          'No booking requests yet.',
          style: TextStyle(color: secondaryText),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${widget.requests.length} booking requests',
            style: const TextStyle(
              color: secondaryText,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.requests.map(buildRequestCard),
        ],
      ),
    );
  }
}
