class JoinRequest {
  final int requestId;
  final int bandId;
  final String bandName;
  final String? profilePicUrl;
  final int musicianId;
  final String musicianName;
  final String? musicianProfilePicUrl;
  final DateTime createdAt;

  const JoinRequest({
    required this.requestId,
    required this.bandId,
    required this.bandName,
    this.profilePicUrl,
    required this.musicianId,
    required this.musicianName,
    this.musicianProfilePicUrl,
    required this.createdAt,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'] as String?;
    return JoinRequest(
      requestId: json['request_id'] as int? ?? 0,
      bandId: json['band_id'] as int? ?? 0,
      bandName: json['band_name'] as String? ?? '',
      profilePicUrl: json['profile_pic_url'] as String?,
      musicianId: json['musician_id'] as int? ?? 0,
      musicianName: json['musician_name'] as String? ?? '',
      musicianProfilePicUrl: json['musician_profile_pic_url'] as String?,
      createdAt: created != null ? DateTime.parse(created) : DateTime.now(),
    );
  }
}
