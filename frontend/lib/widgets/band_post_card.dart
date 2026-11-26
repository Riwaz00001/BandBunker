import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/band_models.dart';
import 'package:frontend/pages/band_profile_page.dart';

class BandPostCard extends StatelessWidget {
  final BandPost post;
  const BandPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF7A00);
    const cardColor = Color(0xFF202026);
    const secondaryText = Color(0xFFBDB8C9);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: post.profilePicUrl != null ? CachedNetworkImageProvider(post.profilePicUrl!) : null,
                  child: post.profilePicUrl == null ? const Icon(Icons.groups, size: 18) : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BandProfilePage(bandId: post.bandId))),
                    child: Text(post.bandName ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                Text(post.formattedDate, style: const TextStyle(color: secondaryText, fontSize: 12)),
              ],
            ),
          ),
          if (post.mediaType == 'image')
            AspectRatio(
              aspectRatio: 4 / 3,
              child: CachedNetworkImage(imageUrl: post.mediaUrl, fit: BoxFit.cover),
            )
          else
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(color: const Color(0xFF303039), child: const Center(child: Icon(Icons.video_library, color: Colors.white70))),
            ),
          if (post.caption != null && post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(post.caption!, style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
