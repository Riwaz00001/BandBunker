class OwnerRegisterRequest {
  final String name;
  final String studio;
  final String email;
  final String number;
  final String location;
  final String roomType;
  final String password;

  const OwnerRegisterRequest({
    required this.name,
    required this.studio,
    required this.email,
    required this.number,
    required this.location,
    required this.roomType,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'studio': studio,
        'email': email,
        'number': number,
        'location': location,
        'room_type': roomType,
        'password': password,
      };
}

class OwnerRegisterResponse {
  final String email;
  final String number;

  const OwnerRegisterResponse({
    required this.email,
    required this.number,
  });

  factory OwnerRegisterResponse.fromJson(Map<String, dynamic> json) {
    return OwnerRegisterResponse(
      email: json['email'] as String? ?? '',
      number: json['number'] as String? ?? '',
    );
  }
}

class OwnerLoginRequest {
  final String email;
  final String password;
  const OwnerLoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}