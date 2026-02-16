import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:reportesapp/core/services/auth_service.dart';
import 'package:reportesapp/core/utils/constants.dart';

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

    // Bypass para aceptar todos los certificados incluso de desarrollo de ASP.NET
    // esto NO DEBE LLEGAR A PRODUCTIVO, solo se agregó para pruebas en localhost
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // Interceptor de cookies
    dio.interceptors.add(CookieInterceptor());

    return dio;
  }

  // esto NO DEBE LLEGAR A PRODUCCIÓN, solo se agregó para pruebas en localhost
  static Dio createHttp(String subpath) {
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
