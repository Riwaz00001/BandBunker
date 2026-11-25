import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/clients/bands_client.dart';
import 'package:frontend/helpers/alert_helper.dart';
import 'package:frontend/models/band_models.dart';
import 'package:frontend/services/token_storage.dart';
import 'package:frontend/widgets/member_tile.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/pages/edit_band.dart';
import 'package:frontend/pages/bands_posts.dart';

class BandProfilePage extends StatefulWidget {
  final int bandId;

  const BandProfilePage({
    super.key,
    required this.bandId,
  });

  @override
  State<BandProfilePage> createState() => _BandProfilePageState();
}

class _BandProfilePageState extends State<BandProfilePage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color background = Color(0xFF121212);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  Band? _band;
  BandMembersResponse? _membersResponse;
  List<BandPost> _posts = [];
  bool _loading = true;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        BandsClient.instance.getBand(widget.bandId),
        BandsClient.instance.getBandMembers(widget.bandId),
        BandsClient.instance.getBandPosts(widget.bandId),
      ]);
      if (mounted) {
        final band = results[0] as Band;
        final membersResponse = results[1] as BandMembersResponse;
        final posts = results[2] as List<BandPost>;
        
        // Check if current user is the band owner
        final myId = await TokenStorage.getMusicianId();
        final isOwner = myId != null && membersResponse.members.any((m) => m.musicianId == myId && m.role == 'owner');
        
        setState(() {
          _band = band;
          _membersResponse = membersResponse;
          _posts = posts;
          _isOwner = isOwner;
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

  Future<void> _navigateToEditBand() async {
    if (_band == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditBandPage(band: _band!)),
    );
    if (result != null && mounted) {
      // Refresh data if band was updated
      _loadData();
    }
  }

  Future<void> _navigateToAddPost() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => BandsPostsPage(bandId: widget.bandId)),
    );
    if (result == true && mounted) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Band Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: CircularProgressIndicator(color: orange)),
      );
    }

    if (_band == null) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Band Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: Text('Band not found', style: TextStyle(color: Colors.white))),
      );
    }

    final members = _membersResponse?.members ?? [];

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Band Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isOwner)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _navigateToEditBand,
              tooltip: 'Edit Band',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: orange,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 15, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Band Header
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFF303039),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: orange, width: 1.5),
                  ),
                  child: _band!.profilePicUrl != null
                      ? CachedNetworkImage(
                          imageUrl: _band!.profilePicUrl!,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          memCacheWidth: 256,
                          maxWidthDiskCache: 256,
                          placeholder: (context, url) => const Icon(
                            Icons.groups,
                            color: orange,
                            size: 55,
                          ),
                          errorWidget: (context, url, stackTrace) =>
                              const Icon(Icons.groups, color: orange, size: 55),
                        )
                      : const Icon(Icons.groups, color: orange, size: 55),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Text(
                  _band!.bandName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _band!.genre,
                    style: const TextStyle(
                      color: orange,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'About Our Band',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _band!.description ?? '',
                style: const TextStyle(
                  color: secondaryText,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              const Divider(color: Colors.white12, thickness: 1),
              const SizedBox(height: 20),

              // Members
              const Row(
                children: [
                  Icon(Icons.groups_outlined, color: orange),
                  SizedBox(width: 9),
                  Text(
                    'Band Members',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (members.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No members yet',
                      style: TextStyle(color: Color(0xFFBDB8C9), fontSize: 14),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MemberTile(member: members[index]),
                    );
                  },
                ),

              // Add Post button (owner only)
              if (_isOwner)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToAddPost,
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text(
                      'Add Post',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 22),

              // Band Posts
              const Row(
                children: [
                  Icon(Icons.post_add, color: orange),
                  SizedBox(width: 9),
                  Text(
                    'Band Posts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_posts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No posts yet',
                      style: TextStyle(color: secondaryText, fontSize: 14),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (post.mediaType == 'image')
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: post.mediaUrl,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 800,
                                  maxWidthDiskCache: 1080,
                                  placeholder: (context, url) => Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: const Color(0xFF303039),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: orange,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, stackTrace) =>
                                      Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: const Color(0xFF303039),
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: secondaryText,
                                      size: 48,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                height: 200,
                                color: const Color(0xFF303039),
                                child: const Center(
                                  child: Icon(
                                    Icons.video_library,
                                    color: Colors.white70,
                                    size: 48,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            if (post.caption != null && post.caption!.isNotEmpty)
                              Text(
                                post.caption!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  post.formattedDate,
                                  style: const TextStyle(
                                    color: secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}