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