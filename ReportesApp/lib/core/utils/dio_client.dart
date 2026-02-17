import 'package:dio/dio.dart';
import 'package:reporteriadafi/core/services/auth_service.dart';
import 'package:reporteriadafi/core/utils/constants.dart';

class DioClient {
  static Dio create(String subpath) {
    final dio = Dio(
      BaseOptions(
        baseUrl: '$ngrokHttps/$subpath',
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );

    // Interceptor de cookies
    dio.interceptors.add(CookieInterceptor());

    return dio;
  }
}
