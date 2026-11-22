import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../clients/musician_client.dart';
import '../helpers/alert_helper.dart';

class ArtistPostsPage extends StatefulWidget {
  const ArtistPostsPage({super.key});

  @override
  State<ArtistPostsPage> createState() => _ArtistPostsPageState();
}

class _ArtistPostsPageState extends State<ArtistPostsPage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  final TextEditingController captionController = TextEditingController();
  File? _selectedMedia;
  String? _mediaType;
  String? _pickedFileName;
  bool _isSaving = false;

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    if (result.files.length > 1) {
      if (mounted) {
        AlertHelper.error(context, 'Please select only one file at a time.');
      }
      return;
    }

    final file = result.files.first;
    setState(() {
      _selectedMedia = File(file.path!);
      _pickedFileName = file.name;
      final ext = file.name.split('.').last.toLowerCase();
      _mediaType = const {'mp4': 'video', 'mov': 'video', 'quicktime': 'video'}
              .containsKey(ext)
          ? 'video'
          : 'image';
    });
  }

  void _removeMedia() {
    setState(() {
      _selectedMedia = null;
      _mediaType = null;
      _pickedFileName = null;
    });
  }

  Future<void> createPost() async {
    final caption = captionController.text.trim();
    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a caption first.')),
      );
      return;
    }
    if (_selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo or video first.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await MusicianClient.instance.createPost(
        caption: caption,
        file: _selectedMedia!,
      );
      if (mounted) {
        AlertHelper.success(context, 'Post created successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AlertHelper.error(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildMediaPreview() {
    if (_selectedMedia == null) return const SizedBox.shrink();
    final isVideo = _mediaType == 'video';
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: isVideo
              ? Container(
                  width: double.infinity,
                  height: 130,
                  color: const Color(0xFF303039),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.video_library, color: Colors.white70, size: 42),
                        SizedBox(height: 8),
                        Text(
                          'Video selected',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              : Image.file(
                  _selectedMedia!,
                  width: double.infinity,
                  height: 130,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.insert_drive_file, color: secondaryText, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _pickedFileName ?? '',
                style: const TextStyle(color: secondaryText, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: _isSaving ? null : _removeMedia,
              child: const Text(
                'Remove',
                style: TextStyle(color: orange, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
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
                  onPressed: _isSaving ? null : _pickMedia,
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
              _buildMediaPreview(),
              const SizedBox(height: 30),
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
                enabled: !_isSaving,
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
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : createPost,
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
