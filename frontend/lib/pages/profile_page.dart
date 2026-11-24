import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/clients/musician_client.dart';
import 'package:frontend/clients/bands_client.dart';
import 'package:frontend/helpers/alert_helper.dart';
import 'package:frontend/models/musician_models.dart';
import 'package:frontend/models/band_models.dart';
import 'package:frontend/services/token_storage.dart';
import 'package:frontend/widgets/post_card.dart';

class ProfilePage extends StatefulWidget {
  final int musicianId;

  const ProfilePage({
    super.key,
    required this.musicianId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color background = Color(0xFF121212);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  Profile? _profile;
  Band? _myBand;
  bool _loading = true;
  bool _sendingInvite = false;

  final List<Post> _posts = [];
  bool _postsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadPosts();
    _loadMyBand();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await MusicianClient.instance.getProfileById(widget.musicianId);
      if (mounted) {
        setState(() {
          _profile = profile;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AlertHelper.error(context, e.toString());
      }
    }
  }

  Future<void> _loadMyBand() async {
    try {
      final band = await BandsClient.instance.getMyBand();
      if (mounted) {
        setState(() => _myBand = band);
      }
    } catch (_) {}
  }

  Future<void> _loadPosts() async {
    setState(() => _postsLoading = true);
    try {
      final allPosts = await MusicianClient.instance.getAllPosts();
      final userPosts = allPosts.where((p) => p.musicianId == widget.musicianId).toList();
      if (mounted) {
        setState(() {
          _posts
            ..clear()
            ..addAll(userPosts);
          _postsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _postsLoading = false);
        AlertHelper.error(context, e.toString());
      }
    }
  }

  Future<void> _sendInvite() async {
    if (_myBand == null || _sendingInvite) return;

    setState(() => _sendingInvite = true);
    try {
      await BandsClient.instance.sendInvite(widget.musicianId);
      if (mounted) {
        AlertHelper.success(context, 'Invite sent!');
      }
    } catch (e) {
      if (mounted) {
        AlertHelper.error(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _sendingInvite = false);
    }
  }

  bool get _isOwnProfile {
    final myId = TokenStorage.getMusicianId();
    return myId != null && myId == widget.musicianId;
  }

  bool get _showInviteButton => !_isOwnProfile && _myBand != null;

  Widget _buildAvatar() {
    if (_profile?.profilePicUrl != null && _profile!.profilePicUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _profile!.profilePicUrl!,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          key: ValueKey(_profile!.profilePicUrl),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.broken_image,
              color: secondaryText,
              size: 48,
            ),
          ),
        ),
      );
    }
    return const CircleAvatar(
      radius: 48,
      backgroundColor: Color(0xFF101017),
      child: Icon(
        Icons.person,
        size: 55,
        color: Color(0xFFBDB8C9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: background,
        body: const Center(child: CircularProgressIndicator(color: orange)),
      );
    }

    if (_profile == null) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Musician Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: Text('Profile not found', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Musician Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadProfile();
          await _loadPosts();
          await _loadMyBand();
        },
        color: orange,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _buildAvatar()),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  _profile!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_profile!.bio != null && _profile!.bio!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    _profile!.bio!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: secondaryText,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              const SizedBox(height: 25),

              // Invite Button
              if (_showInviteButton)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _sendingInvite ? null : _sendInvite,
                      icon: Icon(_sendingInvite ? Icons.hourglass_empty : Icons.music_note),
                      label: Text(
                        _sendingInvite ? 'Sending...' : 'Send Band Invite',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: orange.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 30),
              const Divider(color: Colors.white12, thickness: 1),
              const SizedBox(height: 15),

              // Posts heading
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Icon(Icons.grid_on, color: orange, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Music & Work',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Posts grid
              if (_postsLoading)
                const Center(child: CircularProgressIndicator(color: orange))
              else if (_posts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                    child: Text(
                      'No posts yet',
                      style: TextStyle(color: Color(0xFFBDB8C9), fontSize: 14),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _posts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      return PostCard(post: _posts[index]);
                    },
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}