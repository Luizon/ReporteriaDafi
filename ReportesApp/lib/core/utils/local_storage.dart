import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveCookie(String token) async {
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getCookie() async {
    return prefs.getString('auth_token');
  }

  static Future<void> clearCookie() async {
    await prefs.remove('auth_token');
  }

  static Future<void> saveFCM(String fcm) async {
    await prefs.setString('fcm_token', fcm);
  }

  static Future<String?> getFCM() async {
    return prefs.getString('fcm_token');
  }

  static Future<void> clearFCM() async {
    await prefs.remove('fcm_token');
  }
}