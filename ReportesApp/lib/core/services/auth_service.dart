import 'package:dio/dio.dart';
import 'package:reportesapp/core/services/reports_service.dart';
import 'package:reportesapp/core/utils/dio_client.dart';
import 'package:reportesapp/login/login_controller.dart';
import 'package:reportesapp/new_report/new_report_controller.dart';
import 'package:reportesapp/profile/profile_page.dart';
import 'package:reportesapp/reports/reports_page.dart';
import '../utils/local_storage.dart';
import '../models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final Dio _dio = DioClient.create("Auth");

  /// Login: guarda cookie y token en LocalStorage
  Future<Response> login(String username, String passwordHash) async {
    print("AuthService.login() llamado con $username");
    final response = await _dio.post(
      '/login',
      data: {
        'username': username,
        'passwordHash': passwordHash,
      },
    );
    print("Respuesta recibida: ${response.statusCode}");
    return response;
  }

  /// Logout: envía FCM si existe, limpia storage
  Future<Response> logout(WidgetRef ref) async {
    await LocalStorage.init();
    final fcmToken = await LocalStorage.getFCM();

    final body = fcmToken != null ? {'fcmToken': fcmToken} : {};

    final response = await _dio.post('/logout', data: body);

    await LocalStorage.clearCookie();
    await LocalStorage.clearFCM();

    ref.invalidate(reportsServiceProvider);
    ref.invalidate(userProvider);
    ref.invalidate(newReportControllerProvider);
    ref.invalidate(myReportsProvider);
    ref.invalidate(loginControllerProvider);

    return response;
  }

  /// Me: obtiene datos del usuario autenticado
  Future<User> me() async {
    final response = await _dio.get('/me');
    return User.fromJson(response.data as Map<String, dynamic>);
  }
}

/// Interceptor para manejar cookies
class CookieInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    await LocalStorage.init();
    final cookie = await LocalStorage.getCookie();
    if (cookie != null && cookie.isNotEmpty) {
      options.headers['Cookie'] = cookie;
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final rawCookie = response.headers.value('set-cookie');
    if (rawCookie != null && rawCookie.isNotEmpty) {
      await LocalStorage.init();
      await LocalStorage.saveCookie(rawCookie);
    }
    return handler.next(response);
  }
}