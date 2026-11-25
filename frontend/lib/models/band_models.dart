class Band {
  final int bandId;
  final String bandName;
  final String? description;
  final String genre;
  final String? profilePicUrl;
  final int ownerId;

  const Band({
    required this.bandId,
    required this.bandName,
    this.description,
    required this.genre,
    this.profilePicUrl,
    required this.ownerId,
  });

  factory Band.fromJson(Map<String, dynamic> json) {
    return Band(
      bandId: json['band_id'] as int? ?? 0,
      bandName: json['band_name'] as String? ?? '',
      description: json['description'] as String?,
      genre: json['genre'] as String? ?? '',
      profilePicUrl: json['profile_pic_url'] as String?,
      ownerId: json['owner_id'] as int? ?? 0,
    );
  }
}

class BandMember {
  final int musicianId;
  final String name;
  final String role;
  final String? profilePicUrl;

  const BandMember({
    required this.musicianId,
    required this.name,
    required this.role,
    this.profilePicUrl,
  });

  factory BandMember.fromJson(Map<String, dynamic> json) {
    return BandMember(
      musicianId: json['musician_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      profilePicUrl: json['profile_pic_url'] as String?,
    );
  }
}

class BandMembersResponse {
  final List<BandMember> members;

  const BandMembersResponse({required this.members});

  factory BandMembersResponse.fromJson(Map<String, dynamic> json) {
    final list = json['members'] as List? ?? [];
    return BandMembersResponse(
      members: list.map((e) => BandMember.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class Invite {
  final int inviteId;
  final int bandId;
  final String bandName;
  final String? profilePicUrl;
  final int musicianId;
  final DateTime createdAt;

  const Invite({
    required this.inviteId,
    required this.bandId,
    required this.bandName,
    this.profilePicUrl,
    required this.musicianId,
    required this.createdAt,
  });

  factory Invite.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'] as String?;
    return Invite(
      inviteId: json['invite_id'] as int? ?? 0,
      bandId: json['band_id'] as int? ?? 0,
      bandName: json['band_name'] as String? ?? '',
      profilePicUrl: json['profile_pic_url'] as String?,
      musicianId: json['musician_id'] as int? ?? 0,
      createdAt: created != null ? DateTime.parse(created) : DateTime.now(),
    );
  }
}

class BandPost {
  final int postId;
  final int bandId;
  final String? caption;
  final String mediaType;
  final String mediaUrl;
  final DateTime createdAt;

  const BandPost({
    required this.postId,
    required this.bandId,
    this.caption,
    required this.mediaType,
    required this.mediaUrl,
    required this.createdAt,
  });

  factory BandPost.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'] as String?;
    return BandPost(
      postId: json['post_id'] as int? ?? 0,
      bandId: json['band_id'] as int? ?? 0,
      caption: json['caption'] as String?,
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