import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';

class CompressionHelper {
  static const int feedImageMaxWidth = 1080;
  static const int feedImageQuality = 80;

  static const int avatarMaxWidth = 256;
  static const int avatarQuality = 80;

  static const int maxFeedImageBytes = 2 * 1024 * 1024;
  static const int maxVideoBytes = 20 * 1024 * 1024;
  static const int maxAvatarBytes = 1 * 1024 * 1024;

  /// Compress a feed image to ~1080 px wide, quality 80.
  /// Returns the compressed file, or the original if compression fails
  /// or produces a larger file.
  static Future<File> compressFeedImage(File file) async {
    return _compressImage(
      file,
      targetWidth: feedImageMaxWidth,
      quality: feedImageQuality,
    );
  }

  /// Compress an avatar or band picture to ~256 px wide, quality 80.
  static Future<File> compressAvatar(File file) async {
    return _compressImage(
      file,
      targetWidth: avatarMaxWidth,
      quality: avatarQuality,
    );
  }

  static Future<File> _compressImage(
    File file, {
    required int targetWidth,
    required int quality,
  }) async {
    final originalBytes = await file.length();

    try {
      final targetPath = '${file.path}.compressed';
      final bytes = await FlutterImageCompress.compressWithFile(
        file.path,
        quality: quality,
        minWidth: targetWidth,
        minHeight: targetWidth,
      );

      if (bytes != null) {
        final compressed = File(targetPath);
        await compressed.writeAsBytes(bytes);
        if (await compressed.exists() &&
            (await compressed.length()) < originalBytes) {
          return compressed;
        }
      }
    } catch (_) {
      // Fall through to original.
    }

    return file;
  }

  /// Compress a video to a lower resolution. Returns the compressed file,
  /// or the original if compression fails.
  static Future<File> compressVideo(File file) async {
    try {
      final info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );

      if (info != null && info.file != null) {
        final compressed = File(info.file!.path);
        if (await compressed.exists() &&
            (await compressed.length()) < (await file.length())) {
          return compressed;
        }
      }
    } catch (_) {
      // Fall through to original.
    }

    return file;
  }

  /// Pre-check image size before upload. Returns null if OK, or error message.
  static String? checkImageSize(File file, {required bool isAvatar}) {
    final bytes = file.lengthSync();
    final cap = isAvatar ? maxAvatarBytes : maxFeedImageBytes;
    if (bytes > cap) {
      final capMB = (cap / (1024 * 1024)).toInt();
      return 'File is too large (max $capMB MB).';
    }
    return null;
  }

  /// Pre-check video size before upload. Returns null if OK, or error message.
  static String? checkVideoSize(File file) {
    final bytes = file.lengthSync();
    if (bytes > maxVideoBytes) {
      final capMB = (maxVideoBytes / (1024 * 1024)).toInt();
      return 'Video is too large (max $capMB MB).';
    }
    return null;
  }
}
