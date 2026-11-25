import 'dart:io';

import 'package:dio/dio.dart';

import '../models/band_models.dart';
import '../services/token_storage.dart';
import '../utils/compression_helper.dart';
import 'musician_client.dart';

class BandsClient {
  BandsClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getMusicianToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://bandbunker.onrender.com/',
  );

  static final BandsClient instance = BandsClient._();

  late final Dio _dio;

  Future<Band> createBand({
    required String bandName,
    String? description,
    required String genre,
    File? image,
  }) async {
    try {
      final fields = <MapEntry<String, dynamic>>[
        MapEntry('band_name', bandName),
        MapEntry('genre', genre),
      ];

      if (description != null && description.isNotEmpty) {
        fields.add(MapEntry('description', description));
      }

      if (image != null) {
        final sizeError = CompressionHelper.checkImageSize(image, isAvatar: true);
        if (sizeError != null) {
          throw Exception(sizeError);
        }
        final compressed = await CompressionHelper.compressAvatar(image);
        fields.add(
          MapEntry(
            'file',
            await MultipartFile.fromFile(
              compressed.path,
              filename: compressed.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/bands/create',
        data: FormData.fromMap(Map.fromEntries(fields)),
      );

      return Band.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Band> updateBand({
    required int bandId,
    required String bandName,
    String? description,
    required String genre,
    File? image,
  }) async {
    try {
      final fields = <MapEntry<String, dynamic>>[
        MapEntry('band_name', bandName),
        MapEntry('genre', genre),
      ];

      if (description != null && description.isNotEmpty) {
        fields.add(MapEntry('description', description));
      }

      if (image != null) {
        final sizeError = CompressionHelper.checkImageSize(image, isAvatar: true);
        if (sizeError != null) {
          throw Exception(sizeError);
        }
        final compressed = await CompressionHelper.compressAvatar(image);
        fields.add(
          MapEntry(
            'file',
            await MultipartFile.fromFile(
              compressed.path,
              filename: compressed.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.put(
        '/bands/$bandId',
        data: FormData.fromMap(Map.fromEntries(fields)),
      );

      return Band.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Band?> getMyBand() async {
    try {
      final response = await _dio.get('/bands/my_band');
      return Band.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _mapDioError(e);
    }
  }

  Future<Band> getBand(int bandId) async {
    try {
      final response = await _dio.get('/bands/$bandId');
      return Band.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<BandMembersResponse> getBandMembers(int bandId) async {
    try {
      final response = await _dio.get('/bands/$bandId/members');
      return BandMembersResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<BandPost> createBandPost({
    required int bandId,
    required String caption,
    required File file,
  }) async {
    try {
      final extension = file.path.split('/').last.split('.').last.toLowerCase();
      final isVideo = ['mp4', 'mov', 'quicktime'].contains(extension);

      if (isVideo) {
        final sizeError = CompressionHelper.checkVideoSize(file);
        if (sizeError != null) {
          throw Exception(sizeError);
        }
        final compressed = await CompressionHelper.compressVideo(file);
        final fileName = compressed.path.split('/').last;
        final formData = FormData.fromMap({
          'caption': caption,
          'file': await MultipartFile.fromFile(compressed.path, filename: fileName),
        });
        final response = await _dio.post(
          '/bands/$bandId/posts',
          data: formData,
        );
        return BandPost.fromJson(response.data as Map<String, dynamic>);
      }

      final sizeError = CompressionHelper.checkImageSize(file, isAvatar: false);
      if (sizeError != null) {
        throw Exception(sizeError);
      }
      final compressed = await CompressionHelper.compressFeedImage(file);
      final fileName = compressed.path.split('/').last;
      final formData = FormData.fromMap({
        'caption': caption,
        'file': await MultipartFile.fromFile(compressed.path, filename: fileName),
      });
      final response = await _dio.post(
        '/bands/$bandId/posts',
        data: formData,
      );
      return BandPost.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<List<BandPost>> getAllBandPosts() async {
    try {
      final response = await _dio.get('/bands/posts/all');
      final list = response.data as List;
      return list.map((e) => BandPost.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<List<BandPost>> getBandPosts(int bandId) async {
    try {
      final response = await _dio.get('/bands/$bandId/posts');
      final list = response.data as List;
      return list.map((e) => BandPost.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<List<Band>> getMyBands() async {
    try {
      final response = await _dio.get('/bands/mine');
      final list = response.data as List;
      return list.map((e) => Band.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<List<Invite>> getInvites() async {
    try {
      final response = await _dio.get('/bands/invites');
      final list = response.data as List;
      return list.map((e) => Invite.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Band> sendInvite(int musicianId) async {
    try {
      final response = await _dio.post('/bands/invite/$musicianId');
      return Band.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Band> acceptInvite(int inviteId) async {
    try {
      final response = await _dio.put('/bands/invites/$inviteId/accept');
      return Band.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<void> rejectInvite(int inviteId) async {
    try {
      await _dio.delete('/bands/invites/$inviteId');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  ApiException _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException('Request timed out. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        final detail = data is Map ? data['detail'] : null;

        if (statusCode == 401) {
          return const ApiException(
            'Please log in again to create a band.',
            statusCode: 401,
          );
        }

        if (statusCode == 405) {
          return ApiException(
            detail is String ? detail : 'Method not allowed. Backend may need restart.',
            statusCode: statusCode,
          );
        }

        if (statusCode == 400 || statusCode == 413) {
          return ApiException(
            detail is String ? detail : 'Unable to create band. Please try again.',
            statusCode: statusCode,
          );
        }

        if (statusCode == 422) {
          if (detail is List && detail.isNotEmpty) {
            final first = detail.first;
            final message = first is Map ? first['msg'] : null;
            if (message is String) {
              return ApiException(message, statusCode: statusCode);
            }
          }
          return const ApiException(
            'Please check the details you entered.',
            statusCode: 422,
          );
        }

        if (statusCode != null && statusCode >= 500) {
          return ApiException(
            'Something went wrong on the server. Please try again.',
            statusCode: statusCode,
          );
        }

        return ApiException(
          detail is String ? detail : 'Unable to complete request. Please try again.',
          statusCode: statusCode,
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          'Cannot reach the server. Make sure the backend is running.',
        );

      case DioExceptionType.badCertificate:
        return const ApiException('Server certificate is not valid.');

      case DioExceptionType.cancel:
        return const ApiException('Request was cancelled.');

      case DioExceptionType.unknown:
        return const ApiException(
          'Cannot reach the server. Make sure the backend is running.',
        );
    }
  }
}