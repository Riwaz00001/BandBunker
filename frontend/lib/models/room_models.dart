class Room {
  final int roomId;
  final int ownerId;
  final String name;
  final String location;
  final String roomType;
  final String price;
  final List<String> timeSlots;

  Room({
    required this.roomId,
    required this.ownerId,
    required this.name,
    required this.location,
    required this.roomType,
    required this.price,
    required this.timeSlots,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        roomId: json['room_id'] as int,
        ownerId: json['owner_id'] as int,
        name: json['name'] as String,
        location: json['location'] as String,
        roomType: json['room_type'] as String,
        price: json['price'] as String,
        timeSlots: (json['time_slots'] as List).map((e) => e.toString()).toList(),
      );
}
