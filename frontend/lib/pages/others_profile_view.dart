
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OthersProfileView extends StatefulWidget {
  const OthersProfileView({super.key});

  @override
  State<OthersProfileView> createState() =>
      _OthersProfileViewState();
}

class _OthersProfileViewState extends State<OthersProfileView> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color background = Color(0xFF121212);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  // Temporary profile information.
  // Your friend can connect these values to the backend later.
  final String userName = 'Alex Morgan';

  final String userBio =
      'Guitarist | Music Producer 🎸\n'
      'Creating music, connecting with musicians and '
      'sharing my musical journey.';

  final String profileImage =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500';

  // Temporary sample posts.
  final List<Map<String, String>> userPosts = [
    {
      'image':
      'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=600',
      'type': 'Guitar Performance',
    },
    {
      'image':
      'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=600',
      'type': 'Live Performance',
    },
    {
      'image':
      'https://images.unsplash.com/photo-1524368535928-5b5e00ddc76b?w=600',
      'type': 'Music Session',
    },
    {
      'image':
      'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=600',
      'type': 'Studio Recording',
    },
  ];

  bool requestSent = false;

  void sendBandRequest() {
    setState(() {
      requestSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Band request sent successfully!'),
        backgroundColor: orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget buildProfileImage() {
    return CircleAvatar(
      radius: 58,
      backgroundColor: orange,
      child: CircleAvatar(
        radius: 55,
        backgroundImage: CachedNetworkImageProvider(profileImage),
      ),
    );
  }

  Widget buildPostCard(Map<String, String> post) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: cardColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: post['image']!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      memCacheWidth: 800,
                      maxWidthDiskCache: 1080,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFF303039),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: orange,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, stackTrace) => Container(
                        color: const Color(0xFF303039),
                        child: const Icon(
                          Icons.music_note,
                          color: orange,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      post['type']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: post['image']!,
          fit: BoxFit.cover,
          memCacheWidth: 800,
          maxWidthDiskCache: 1080,
          placeholder: (context, progress) => const Center(
            child: CircularProgressIndicator(
              color: orange,
            ),
          ),
          errorWidget: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.music_note,
                color: orange,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'Musician Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),

            // Profile picture
            Center(
              child: buildProfileImage(),
            ),

            const SizedBox(height: 18),

            // User name
            Center(
              child: Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // User biography
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Text(
                userBio,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: secondaryText,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Send Band Request button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                  requestSent ? null : sendBandRequest,
                  icon: Icon(
                    requestSent
                        ? Icons.check_circle_outline
                        : Icons.music_note,
                  ),
                  label: Text(
                    requestSent
                        ? 'Request Sent'
                        : 'Send Band Invite',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    orange.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Divider
            const Divider(
              color: Colors.white12,
              thickness: 1,
            ),

            const SizedBox(height: 15),

            // Posts heading
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 22,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.grid_on,
                    color: orange,
                    size: 22,
                  ),
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

            // User posts grid
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                itemCount: userPosts.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  return buildPostCard(userPosts[index]);
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
