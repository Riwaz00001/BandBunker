import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/musician_models.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    if (widget.post.mediaType == 'video') {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.post.mediaUrl),
      )
        ..initialize().then((_) {
          if (mounted) setState(() {});
        }).catchError((_) {
          if (mounted) {
            setState(() => _videoError = true);
          }
        });
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        showControls: true,
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal : 20, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF202026),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF303039), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: profile pic + tappable name + date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: widget.post.profilePicUrl != null
                    ? NetworkImage(widget.post.profilePicUrl!)
                    : null,
                child: widget.post.profilePicUrl == null
                    ? const Icon(Icons.person, size: 22)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('View profile coming soon.'),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(
                        widget.post.musicianName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.post.formattedDate,
                      style: const TextStyle(
                        color: Color(0xFFBDB8C9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Media: image or video
          if (widget.post.mediaType == 'image')
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.post.mediaUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 300,
                  color: const Color(0xFF303039),
                  child: const Icon(
                    Icons.broken_image,
                    color: Color(0xFFBDB8C9),
                    size: 48,
                  ),
                ),
              ),
            )
          else if (widget.post.mediaType == 'video')
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                height: 300,
                child: _videoError
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Color(0xFFBDB8C9),
                              size: 48,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Video unavailable',
                              style: TextStyle(
                                color: Color(0xFFBDB8C9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _chewieController != null &&
                            _videoController!.value.isInitialized
                        ? ConstrainedBox(
                            constraints: const BoxConstraints.expand(),
                            child: Chewie(
                              controller: _chewieController!,
                            ),
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 300,
              color: const Color(0xFF303039),
              child: const Center(
                child: Icon(Icons.help_outline, color: Color(0xFFBDB8C9)),
              ),
            ),

          const SizedBox(height: 12),

          // Caption
          Text(
            widget.post.caption,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
