import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reporteriadafi/core/services/reports_service.dart';
import 'package:reporteriadafi/core/utils/local_storage.dart';
import 'package:reporteriadafi/profile/profile_page.dart';
import 'package:reporteriadafi/reports/reports_page.dart';
import '../core/services/auth_service.dart';
import '../core/services/firebase_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';

final loginErrorProvider = StateProvider<String?>((ref) => null);

final loginControllerProvider = AsyncNotifierProvider<LoginController, void>(
  LoginController.new,
);

class LoginController extends AsyncNotifier<void> {
  late AuthService _authService;

  @override
  FutureOr<void> build() {
    _authService = ref.read(authServiceProvider);
    state = const AsyncData(null);
  }

  Future<bool> login(String username, String passwordHash) async {
    state = const AsyncLoading();
    try {
      final response = await _authService.login(username, passwordHash);

      if (response.statusCode == 200) {
        state = const AsyncData(null);
        // Invalidate user and reports providers so UI fetches fresh data
        ref.invalidate(userProvider);
        ref.invalidate(myReportsProvider);
        ref.invalidate(reportsServiceProvider);

        // Firebase
        try {
          // primero validar permisos
          final notifSettings = await FirebaseMessaging.instance
              .getNotificationSettings();
          if (notifSettings.authorizationStatus !=
              AuthorizationStatus.authorized) {
            await requestAppPermissions();
          }

          // luego consultar fcm token
          final token = await ref.read(firebaseServiceProvider).initFCM();
          if (token != null) {
            LocalStorage.init();
            LocalStorage.saveFCM(token);
          }

          if (token != null) {
            print('LoginController: FCM token set: $token');
          } else {
            print('LoginController: no FCM token obtained');
          }
        } catch (e) {
          print('LoginController: initFCM failed: $e');
        }
        return true;
      } else {
        print(
          "flutter: Login fallido ${response.data}, status ${response.statusMessage}",
        );
        final msg = response.statusCode == 401 || response.statusCode == 403
            ? "Credenciales incorrectas"
            : response.statusCode == 400
                ? "Solicitud inválida"
                : "Ocurrió un error inesperado.";
        ref.read(loginErrorProvider.notifier).state = msg;

        state = AsyncData(null);
        return false;
      }
    } catch (e, st) {
      final current = ref.read(loginErrorProvider);
      if (current == null) {
        final msg = e.toString().contains("401") || e.toString().contains("403")
            ? "Credenciales incorrectas"
            : e.toString().contains("400")
                ? "Solicitud inválida"
                : "Ocurrió un error inesperado.";
        ref.read(loginErrorProvider.notifier).state = msg;
      }
      print("flutter: Login fallido $e");
      state = AsyncData(null);
      return false;
    }
  }

  Future<void> requestAppPermissions() async {
    // Cámara + galería
    await [Permission.camera, Permission.photos].request();

    // Notificaciones
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
