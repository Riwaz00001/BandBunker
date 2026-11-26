
import 'package:flutter/material.dart';

class OthersBandView extends StatefulWidget {
  const OthersBandView({super.key});

  @override
  State<OthersBandView> createState() => _OthersBandViewState();
}

class _OthersBandViewState extends State<OthersBandView> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  bool requestSent = false;

  // Temporary band information.
  // Your friend can connect this with the backend later.
  final String bandName = 'The Midnight Echo';

  final String bandBio =
      'We are a group of passionate musicians who love creating '
      'music, performing live, and sharing our passion for rock '
      'and alternative sounds. Looking for new opportunities '
      'and musical collaborations.';

  final String bandImage =
      'https://images.unsplash.com/photo-1524368535928-5b5e00ddc76b'
      '?auto=format&fit=crop&w=1000&q=80';

  // Temporary band posts.
  final List<Map<String, String>> bandPosts = [
    {
      'image':
      'https://images.unsplash.com/photo-1501386761578-eac5c94b800a'
          '?auto=format&fit=crop&w=700&q=80',
      'caption': 'Our latest live performance!',
    },
    {
      'image':
      'https://images.unsplash.com/photo-1516280440614-37939bbacd81'
          '?auto=format&fit=crop&w=700&q=80',
      'caption': 'Making music together in the studio.',
    },
    {
      'image':
      'https://images.unsplash.com/photo-1524650359799-842906ca1c06'
          '?auto=format&fit=crop&w=700&q=80',
      'caption': 'An unforgettable music session.',
    },
    {
      'image':
      'https://images.unsplash.com/photo-1506157786151-b8491531f063'
          '?auto=format&fit=crop&w=700&q=80',
      'caption': 'Memories from our recent concert.',
    },
  ];

  // Send join request (temporary frontend interaction).
  void sendJoinRequest() {
    if (requestSent) return;

    setState(() {
      requestSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Join request sent successfully!'),
        backgroundColor: Color(0xFF303039),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Band profile picture.
  Widget buildBandImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        bandImage,
        width: double.infinity,
        height: 210,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 210,
            width: double.infinity,
            color: cardColor,
            child: const Icon(
              Icons.groups,
              color: secondaryText,
              size: 65,
            ),
          );
        },
      ),
    );
  }

  // Band name and bio.
  Widget buildBandInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bandName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        const Row(
          children: [
            Icon(
              Icons.music_note,
              color: orange,
              size: 16,
            ),
            SizedBox(width: 5),
            Text(
              'MUSIC BAND',
              style: TextStyle(
                color: orange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        const Text(
          'About the Band',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          bandBio,
          style: const TextStyle(
            color: secondaryText,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // Send join request button.
  Widget buildJoinButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: requestSent ? null : sendJoinRequest,
        icon: Icon(
          requestSent ? Icons.check_circle : Icons.person_add_alt_1,
          size: 20,
        ),
        label: Text(
          requestSent ? 'Request Sent' : 'Send Join Request',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: requestSent
              ? const Color(0xFF383838)
              : orange,
          disabledBackgroundColor: const Color(0xFF383838),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Band work heading.
  Widget buildPostsHeading() {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'Band Work & Posts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(
          Icons.grid_view_rounded,
          color: orange,
          size: 22,
        ),
      ],
    );
  }

  // Band posts grid.
  Widget buildBandPosts() {
    if (bandPosts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 45),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.photo_library_outlined,
                color: Colors.white24,
                size: 55,
              ),
              SizedBox(height: 12),
              Text(
                'No band posts yet',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bandPosts.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final post = bandPosts[index];

        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  backgroundColor: cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            post['image']!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(
                              Icons.broken_image,
                              color: secondaryText,
                              size: 50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          post['caption']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text(
                            'Close',
                            style: TextStyle(color: orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: const Color(0xFF303039),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.network(
                    post['image']!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: secondaryText,
                          size: 35,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(9),
                  child: Text(
                    post['caption']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Band Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Band picture
              buildBandImage(),

              const SizedBox(height: 20),

              // Band name and bio
              buildBandInformation(),

              const SizedBox(height: 20),

              // Join request button
              buildJoinButton(),

              const SizedBox(height: 28),

              // Band work heading
              buildPostsHeading(),

              const SizedBox(height: 15),

              // Band posts
              buildBandPosts(),
            ],
          ),
        ),
      ),
    );
  }
}
