
import 'package:flutter/material.dart';

class ArtistPostsPage extends StatefulWidget {
  const ArtistPostsPage({super.key});

  @override
  State<ArtistPostsPage> createState() => _ArtistPostsPageState();
}

class _ArtistPostsPageState extends State<ArtistPostsPage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  final TextEditingController captionController =
  TextEditingController();

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  // Media selection options
  void showMediaOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Media',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: orange,
                  size: 28,
                ),
                title: const Text(
                  'Upload Photos',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Share your music photos',
                  style: TextStyle(color: secondaryText),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showMediaMessage('Photo');
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.video_library_outlined,
                  color: orange,
                  size: 28,
                ),
                title: const Text(
                  'Upload Videos',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Share your music videos',
                  style: TextStyle(color: secondaryText),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showMediaMessage('Video');
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Temporary message until backend is connected
  void showMediaMessage(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$type uploading will be available soon.',
        ),
      ),
    );
  }

  // Post button action
  void createPost() {
    if (captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a caption first.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Post creation will be available after backend integration.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page heading
              const Text(
                'Share Your Music',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),


              const Text(
                'Add Photos or Videos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 130,
                child: OutlinedButton(
                  onPressed: () {
                    // Backend media upload functionality will be added later.
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF202026),
                    foregroundColor: const Color(0xFFFF7A00),
                    side: const BorderSide(
                      color: Color(0xFFFF7A00),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 42,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Add Photos or Videos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Share your musical moments',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              const SizedBox(height: 30),

              // Caption section
              const Text(
                'Caption',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: captionController,
                maxLines: 6,
                maxLength: 500,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText:
                  'What would you like to share with musicians?',
                  hintStyle: const TextStyle(
                    color: secondaryText,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: cardColor,
                  contentPadding: const EdgeInsets.all(18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: orange,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const SizedBox(height: 35),

              // Create post button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: createPost,
                  icon: const Icon(
                    Icons.send,
                    size: 19,
                  ),
                  label: const Text(
                    'CREATE POST',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.7,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
