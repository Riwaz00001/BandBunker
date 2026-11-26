import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/band_models.dart';
import 'package:frontend/clients/bands_client.dart';
import 'package:frontend/helpers/alert_helper.dart';
import 'package:frontend/pages/band_profile_page.dart';

const Color _kOrange = Color(0xFFFF7A00);
const Color _kCardColor = Color(0xFF202026);
const Color _kSecondaryText = Color(0xFFBDB8C9);
const Color _kDarkGrey = Color(0xFF303039);

class InviteCard extends StatefulWidget {
  final Invite invite;
  final VoidCallback onInviteChanged;

  const InviteCard({
    super.key,
    required this.invite,
    required this.onInviteChanged,
  });

  @override
  State<InviteCard> createState() => _InviteCardState();
}

class _InviteCardState extends State<InviteCard> {
  bool _isAcceptLoading = false;
  bool _isRejectLoading = false;

  Future<void> _handleAccept() async {
    setState(() => _isAcceptLoading = true);
    try {
      await BandsClient.instance.acceptInvite(widget.invite.inviteId);
      if (mounted) {
        AlertHelper.success(context, 'Joined band!');
        widget.onInviteChanged();
      }
    } catch (e) {
      if (mounted) {
        AlertHelper.error(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isAcceptLoading = false);
    }
  }

  Future<void> _handleReject() async {
    setState(() => _isRejectLoading = true);
    try {
      await BandsClient.instance.rejectInvite(widget.invite.inviteId);
      if (mounted) {
        AlertHelper.success(context, 'Invite rejected');
        widget.onInviteChanged();
      }
    } catch (e) {
      if (mounted) {
        AlertHelper.error(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isRejectLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isAcceptLoading || _isRejectLoading;

    return Card(
      color: _kCardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BandProfilePage(bandId: widget.invite.bandId),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _kDarkGrey,
                    backgroundImage: widget.invite.profilePicUrl != null
                        ? CachedNetworkImageProvider(widget.invite.profilePicUrl!)
                        : null,
                    child: widget.invite.profilePicUrl == null
                        ? const Icon(Icons.groups, color: _kSecondaryText, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.invite.bandName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Invited you to join',
                          style: TextStyle(
                            color: _kSecondaryText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : _handleReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isRejectLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                            )
                          : const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isAcceptLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}