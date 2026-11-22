import 'dart:io';

import 'package:dio/dio.dart';

import '../models/musician_models.dart';
import '../services/token_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class MusicianClient {
  MusicianClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
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

  static final MusicianClient instance = MusicianClient._();

  late final Dio _dio;

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/musician/register',
        data: request.toJson(),
      );

      return RegisterResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<String> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/musician/login', data: request.toJson());
      return (response.data as Map<String, dynamic>)['token'] as String;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Profile> getProfile() async {
    try {
      final response = await _dio.get('/musician/profile');
      return Profile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Profile> updateProfile({required String bio, File? image}) async {
    try {
      final fields = <MapEntry<String, dynamic>>[
        MapEntry('bio', bio),
      ];

      if (image != null) {
        fields.add(
          MapEntry(
            'file',
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.put(
        '/musician/profile',
        data: FormData.fromMap(Map.fromEntries(fields)),
      );

      return Profile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Post> createPost({required String caption, required File file}) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'caption': caption,
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });
      final response = await _dio.post(
        '/musician/posts/create_post',
        data: formData,
      );
      return Post.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<List<Post>> getMyPosts() async {
    try {
      final response = await _dio.get('/musician/posts/my_posts');
      final list = response.data as List;
      return list.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<List<Post>> getAllPosts() async {
    try {
      final response = await _dio.get('/musician/posts/all_posts');
      final list = response.data as List;
      return list.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
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

        if (statusCode == 400) {
          final detail = data is Map ? data['detail'] : null;
          return ApiException(
            detail is String ? detail : 'Registration failed. Please try again.',
            statusCode: statusCode,
          );
        }

        if (statusCode == 422) {
          final detail = data is Map ? data['detail'] : null;
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
          'Unable to complete registration. Please try again.',
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
