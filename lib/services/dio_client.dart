import 'package:dio/dio.dart';
import 'package:presgo_app/services/storage_service.dart';

Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://appabsensi.mobileprojp.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
      // Allow all status codes to pass through — we handle errors manually
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final path = options.path;
        final isPublicRoute = path.contains('/api/login') ||
            path.contains('/api/register') ||
            path.contains('/api/batches') ||
            path.contains('/api/trainings');

        if (!isPublicRoute) {
          final token = await StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        // Convert non-2xx responses that passed validateStatus into errors with friendly messages
        if (response.statusCode != null && response.statusCode! >= 400) {
          String message = _extractMessage(response.data);
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              message: message,
            ),
          );
        } else {
          handler.next(response);
        }
      },
    ),
  );

  // Log only in debug
  assert(() {
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    return true;
  }());

  return dio;
}

/// Extract a human-readable message from a server response body.
String _extractMessage(dynamic data) {
  if (data == null) return 'Terjadi kesalahan';
  if (data is Map) {
    // Try common message fields
    for (final key in ['message', 'error', 'msg', 'detail']) {
      if (data[key] != null && data[key].toString().isNotEmpty) {
        return data[key].toString();
      }
    }
    // Try nested 'data.message'
    if (data['data'] is Map && data['data']['message'] != null) {
      return data['data']['message'].toString();
    }
  }
  return 'Permintaan gagal. Coba lagi.';
}
