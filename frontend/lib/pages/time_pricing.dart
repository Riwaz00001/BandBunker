
import 'package:flutter/material.dart';
import '../clients/owner_client.dart';


// Room model shared with the owner dashboard.
class RoomData {
  final String name;
  final String price;
  final List<String> timeSlots;

  RoomData({
    required this.name,

    required this.price,
    required this.timeSlots,
  });
}

class TimePricingPage extends StatefulWidget {
  final String studioName;
  final RoomData? existingRoom;

  const TimePricingPage({
    super.key,
    required this.studioName,
    this.existingRoom,
  });

  @override
  State<TimePricingPage> createState() => _TimePricingPageState();
}

class _TimePricingPageState extends State<TimePricingPage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color background = Color(0xFF121212);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  final TextEditingController priceController = TextEditingController();

  final List<String> availableSlots = [
    '8:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '12:00 PM - 2:00 PM',
    '2:00 PM - 4:00 PM',
    '4:00 PM - 6:00 PM',
    '6:00 PM - 8:00 PM',
    '8:00 PM - 10:00 PM',
  ];

  final Set<String> selectedSlots = {};

  String _studioName = '';

  String get studioName {
    if (_studioName.trim().isNotEmpty) return _studioName.trim();
    if (widget.studioName.trim().isNotEmpty) return widget.studioName.trim();
    return widget.existingRoom?.name ?? '';
  }

  @override
  void initState() {
    super.initState();

    priceController.text = widget.existingRoom?.price ?? '';

    if (widget.existingRoom != null) {
      selectedSlots.addAll(widget.existingRoom!.timeSlots);
    }

    _loadStudioName();
  }

  Future<void> _loadStudioName() async {
    try {
      final data = await OwnerClient.instance.getOwnerProfile();
      if (mounted) setState(() => _studioName = (data['studio'] ?? '') as String);
    } catch (_) {}
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white38,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: orange,
        size: 20,
      ),
      filled: true,
      fillColor: const Color(0xFF303039),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.white10,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: orange,
          width: 1.3,
        ),
      ),
    );
  }

  void registerRoom() {
    final price = priceController.text.trim();
    final parsedPrice = double.tryParse(price);

    if (studioName.isEmpty) {
      showMessage('Studio name is not available.');
      return;
    }

    if (price.isEmpty || parsedPrice == null || parsedPrice <= 0) {
      showMessage('Please enter a valid hourly price.');
      return;
    }

    if (selectedSlots.isEmpty) {
      showMessage('Please select at least one available time slot.');
      return;
    }

    final room = RoomData(
      name: studioName,
      price: price,
      timeSlots: availableSlots
          .where((slot) => selectedSlots.contains(slot))
          .toList(),
    );

    Navigator.pop(context, room);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget buildStudioName() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 17,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF303039),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.meeting_room_outlined,
            color: orange,
            size: 21,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              studioName.isEmpty ? 'Studio name not available' : studioName,
              style: const TextStyle(
                color: secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.lock_outline,
            color: Colors.white38,
            size: 17,
          ),
        ],
      ),
    );
  }

  Widget buildTimeSlots() {
    return Wrap(
      spacing: 10,
      runSpacing: 12,
      children: availableSlots.map((slot) {
        final isSelected = selectedSlots.contains(slot);

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedSlots.remove(slot);
              } else {
                selectedSlots.add(slot);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? orange.withValues(alpha: 0.17)
                  : const Color(0xFF303039),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? orange : Colors.white12,
                width: isSelected ? 1.3 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.access_time,
                  color: isSelected ? orange : secondaryText,
                  size: 17,
                ),
                const SizedBox(width: 8),
                Text(
                  slot,
                  style: TextStyle(
                    color: isSelected ? Colors.white : secondaryText,
                    fontSize: 12,
                    fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRoom != null;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Room' : 'Register Room',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.home_work_outlined,
                      color: orange,
                      size: 35,
                    ),
                    const SizedBox(height: 13),
                    Text(
                      isEditing ? 'Update Your Room' : 'Set Up Your Room',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Set your hourly price and choose the time slots when bands can book your studio.',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              sectionTitle('Studio Name'),
              const SizedBox(height: 10),
              buildStudioName(),

              const SizedBox(height: 25),

              sectionTitle('Price Per Hour (NPR)'),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                decoration: inputDecoration(
                  'Enter hourly price (e.g. 800)',
                  Icons.currency_rupee,
                ),
              ),

              const SizedBox(height: 28),

              sectionTitle('Available Time Slots'),
              const SizedBox(height: 7),
              const Text(
                'Select all the time slots when your room is available.',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 17),

              buildTimeSlots(),

              const SizedBox(height: 18),

              Text(
                '${selectedSlots.length} time slot(s) selected',
                style: const TextStyle(
                  color: orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 53,
                child: ElevatedButton(
                  onPressed: registerRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Register Room',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'You can update your pricing and availability later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
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
