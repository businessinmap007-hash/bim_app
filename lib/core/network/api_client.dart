import 'package:dio/dio.dart';

import '../env/env.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Thin wrapper around Dio that speaks the backend's envelope directly:
/// success responses are `{"success": true, "data": ...}` (see
/// docs/api/openapi-v2.yaml on the backend) — callers get `data` already
/// unwrapped, and every failure arrives as an [ApiException], never a raw
/// [DioException].
class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiClient(this._tokenStorage)
      : _dio = Dio(BaseOptions(
          baseUrl: Env.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Accept': 'application/json'},
        )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    if (Env.logNetwork) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  Dio get raw => _dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _unwrap(() => _dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? data, Map<String, String>? headers}) =>
      _unwrap(() => _dio.post(path, data: data, options: Options(headers: headers)));

  /// For the rare endpoint whose success body carries more than `data`
  /// (e.g. `/auth/login`'s sibling `token` field) — same error handling as
  /// [post], but returns the full response body un-unwrapped.
  Future<Map<String, dynamic>> postForBody(String path, {Object? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<dynamic> put(String path, {Object? data}) =>
      _unwrap(() => _dio.put(path, data: data));

  Future<dynamic> delete(String path, {Object? data}) =>
      _unwrap(() => _dio.delete(path, data: data));

  Future<dynamic> _unwrap(Future<Response> Function() call) async {
    try {
      final response = await call();
      final body = response.data;
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        return body['data'];
      }
      return body;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;

    if (body is Map<String, dynamic>) {
      final message = (body['message'] as String?) ?? 'Request failed.';
      final rawErrors = body['errors'];
      final fieldErrors = <String, List<String>>{};
      if (rawErrors is Map) {
        rawErrors.forEach((key, value) {
          if (value is List) {
            fieldErrors[key.toString()] = value.map((v) => v.toString()).toList();
          }
        });
      }
      return ApiException(statusCode: status, message: message, fieldErrors: fieldErrors);
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ApiException(message: 'No internet connection.');
    }

    return ApiException(statusCode: status, message: e.message ?? 'Request failed.');
  }
}
