import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/band_models.dart';
import 'package:frontend/pages/band_profile_page.dart';

const Color _kOrange = Color(0xFFFF7A00);
const Color _kCardColor = Color(0xFF202026);
const Color _kSecondaryText = Color(0xFFBDB8C9);
const Color _kDarkGrey = Color(0xFF303039);

class BandCard extends StatelessWidget {
  final Band band;
  final bool isOwner;

  const BandCard({
    super.key,
    required this.band,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _kCardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BandProfilePage(bandId: band.bandId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: band.profilePicUrl != null
                    ? CachedNetworkImage(
                        imageUrl: band.profilePicUrl!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        memCacheWidth: 256,
                        maxWidthDiskCache: 256,
                        placeholder: (context, url) => Container(
                          width: 64,
                          height: 64,
                          color: _kDarkGrey,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: _kOrange,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, stackTrace) => Container(
                          width: 64,
                          height: 64,
                          color: _kDarkGrey,
                          child: const Icon(Icons.groups, color: _kSecondaryText, size: 32),
                        ),
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        color: _kDarkGrey,
                        child: const Icon(Icons.groups, color: _kSecondaryText, size: 32),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      band.bandName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      band.genre,
                      style: TextStyle(
                        color: _kSecondaryText,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOwner ? _kOrange.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOwner ? 'Owner' : 'Member',
                  style: TextStyle(
                    color: isOwner ? _kOrange : Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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