class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String role;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      };
}

class RegisterResponse {
  final String email;
  final String role;

  const RegisterResponse({
    required this.email,
    required this.role,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }
}

class LoginRequest {
  final String email;
  final String password;
  const LoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class Profile {
  final String name;
  final String email;
  final String role;
  final String? bio;
  final String? profilePicUrl;

  const Profile({
    required this.name,
    required this.email,
    required this.role,
    this.bio,
    this.profilePicUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      bio: json['bio'] as String?,
      profilePicUrl: json['profile_pic_url'] as String?,
    );
  }
}

class Post {
  final int musicianId;
  final String musicianName;
  final String? profilePicUrl;
  final String caption;
  final String mediaType;
  final String mediaUrl;
  final DateTime createdAt;

  Post({
    required this.musicianId,
    required this.musicianName,
    this.profilePicUrl,
    required this.caption,
    required this.mediaType,
    required this.mediaUrl,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'] as String?;
    return Post(
      musicianId: json['musician_id'] as int? ?? 0,
      musicianName: json['musician_name'] as String? ?? '',
      profilePicUrl: json['profile_pic_url'] as String?,
      caption: json['caption'] as String? ?? '',
      mediaType: json['media_type'] as String? ?? '',
      mediaUrl: json['media_url'] as String? ?? '',
      createdAt: created != null ? DateTime.parse(created) : DateTime.now(),
    );
  }

  String get formattedDate {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${createdAt.day} ${months[createdAt.month - 1]}';
  }
}
