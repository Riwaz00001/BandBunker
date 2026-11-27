import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/owner_models.dart';
import '../models/room_models.dart';
import '../services/token_storage.dart';
import 'musician_client.dart';

class OwnerClient {
  OwnerClient._() {
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
        final token = await TokenStorage.getOwnerToken();
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

  static final OwnerClient instance = OwnerClient._();

  late final Dio _dio;

  Future<OwnerRegisterResponse> register(OwnerRegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/owner/register',
        data: request.toJson(),
      );

      return OwnerRegisterResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<String> login(OwnerLoginRequest request) async {
    try {
      final response = await _dio.post('/owner/login', data: request.toJson());
      return (response.data as Map<String, dynamic>)['token'] as String;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<List<Room>> getRooms() async {
    try {
      final response = await _dio.get('/rooms');
      final list = response.data as List;
      return list.map((e) => Room.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Room> createRoom(String price, List<String> selectedSlots) async {
    try {
      final response = await _dio.post('/owner/rooms', data: {
        'price': price,
        'selected_slots': selectedSlots,
      });
      return Room.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> getOwnerProfile() async {
    try {
      final response = await _dio.get('/owner/me');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }
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