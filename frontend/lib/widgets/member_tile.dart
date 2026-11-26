import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/band_models.dart';
import 'package:frontend/pages/profile_page.dart';

const Color _kOrange = Color(0xFFFF7A00);
const Color _kCardColor = Color(0xFF202026);
const Color _kSecondaryText = Color(0xFFBDB8C9);
const Color _kDarkGrey = Color(0xFF303039);

class MemberTile extends StatelessWidget {
  final BandMember member;

  const MemberTile({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = member.role == 'owner';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(musicianId: member.musicianId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _kDarkGrey,
              backgroundImage: member.profilePicUrl != null
                  ? CachedNetworkImageProvider(member.profilePicUrl!)
                  : null,
              child: member.profilePicUrl == null
                  ? const Icon(Icons.person, color: _kSecondaryText, size: 24)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOwner ? _kOrange.withValues(alpha: 0.2) : _kDarkGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isOwner ? 'Owner' : 'Member',
                          style: TextStyle(
                            color: isOwner ? _kOrange : _kSecondaryText,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _kSecondaryText),
          ],
        ),
      ),
    );
  }
}