import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reportesapp/core/services/reports_service.dart';
import 'package:reportesapp/profile/profile_page.dart';
import 'package:reportesapp/reports/reports_page.dart';
import '../core/services/auth_service.dart';
import 'dart:async';

final loginControllerProvider =
    AsyncNotifierProvider<LoginController, void>(LoginController.new);
    
class LoginController extends AsyncNotifier<void> {
  late final AuthService _authService;

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
        return true;
      } else {
        print("flutter: Login fallido ${response.data}, status ${response.statusMessage}");
        state = AsyncError(
          Exception("Error ${response.statusCode}: ${response.statusMessage}"),
          StackTrace.current,
        );
        return false;
      }
    } catch (e, st) {
      print("flutter: Login fallido $e");
      state = AsyncError(e, st);
      return false;
    }
  }
}
