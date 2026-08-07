import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/env/env.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/constants/app_strings.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// ── Client ───────────────────────────────────────────────────────────────────

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());
  }

  // ── Auth ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    final response = await _dio.post('/api/public/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    });
    return _unwrap(response);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/api/public/auth/login', data: {
      'email': email,
      'password': password,
    });
    return _unwrap(response);
  }

  // ── Vehicle ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getVehicleByUuid(String uuid) async {
    final response = await _dio.get('/api/public/supports/$uuid');
    return _unwrap(response);
  }

  // ── Report Types ──────────────────────────────────────────────────────────

  Future<List<dynamic>> getReportTypes() async {
    final response = await _dio.get('/api/public/report-types');
    return _unwrapList(response);
  }

  // ── Submit Report ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> submitReport({
    required String supportUuid,
    required int reportTypeId,
    required String description,
    required String? passengerName,
    required String? passengerEmail,
    required String? passengerPhone,
    List<String>? filePaths,
  }) async {
    final reportJson = jsonEncode({
      'supportUuid': supportUuid,
      'reportTypeId': reportTypeId,
      'description': description,
      'passenger': {
        if (passengerName != null) 'name': passengerName,
        if (passengerEmail != null) 'email': passengerEmail,
        if (passengerPhone != null) 'phoneNumber': passengerPhone,
      },
    });

    final formData = FormData.fromMap({
      // Critical: content-type must be application/json for Spring @RequestPart
      'report': MultipartFile.fromString(
        reportJson,
        contentType: DioMediaType('application', 'json'),
      ),
    });

    // Attach files if any
    if (filePaths != null && filePaths.isNotEmpty) {
      for (final path in filePaths) {
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(path),
        ));
      }
    }

    final response = await _dio.post(
      '/api/public/signalements',
      data: formData,
    );

    return _unwrap(response);
  }
  // ── Tracking ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> trackReport(String uuid) async {
    final response = await _dio.get('/api/public/suivi/$uuid');
    return _unwrap(response);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Unwraps { "success": true, "data": {...} } → returns data map
  Map<String, dynamic> _unwrap(Response response) {
    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true && body['data'] != null) {
      return body['data'] as Map<String, dynamic>;
    }
    throw AppException(
      body['message'] as String? ?? AppStrings.unknownError,
    );
  }

  /// Unwraps { "success": true, "data": [...] } → returns list
  List<dynamic> _unwrapList(Response response) {
    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true && body['data'] != null) {
      return body['data'] as List<dynamic>;
    }
    throw AppException(
      body['message'] as String? ?? AppStrings.unknownError,
    );
  }
}

// ── Auth Interceptor ──────────────────────────────────────────────────────────
// Automatically attaches JWT token to every request if present in storage.

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthStorageKeys.token);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// ── Error Interceptor ─────────────────────────────────────────────────────────
// Maps all Dio errors to typed AppException subclasses.

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 → clear token + throw UnauthorizedException
    if (err.response?.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AuthStorageKeys.token);
      await prefs.remove(AuthStorageKeys.name);
      await prefs.remove(AuthStorageKeys.email);
      await prefs.remove(AuthStorageKeys.phoneNumber);
      await prefs.remove(AuthStorageKeys.passengerId);
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const UnauthorizedException(),
        ),
      );
    }

    final exception = _mapError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
      ),
    );
  }

  AppException _mapError(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return const TimeoutException();
    }

    if (err.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }

    final statusCode = err.response?.statusCode;
    final message = err.response?.data?['message'] as String?;

    return switch (statusCode) {
      400 => AppException(message ?? AppStrings.unknownError, statusCode: 400),
      404 => const NotFoundException(),
      409 => ConflictException(message ?? AppStrings.unknownError),
      413 => const AppException('Fichiers trop volumineux.', statusCode: 413),
      500 => const ServerException(),
      _ => AppException(message ?? AppStrings.unknownError),
    };
  }
}

// ── Auth Storage Keys ─────────────────────────────────────────────────────────
// Single source of truth for all SharedPreferences keys.

class AuthStorageKeys {
  AuthStorageKeys._();

  static const String token = 'auth_token';
  static const String name = 'auth_name';
  static const String email = 'auth_email';
  static const String phoneNumber = 'auth_phone';
  static const String passengerId = 'auth_passenger_id';
  static const String recentReports = 'recent_reports';
}
