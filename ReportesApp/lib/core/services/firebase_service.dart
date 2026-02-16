import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:reportesapp/core/utils/dio_client.dart';
import '../utils/local_storage.dart';

class FirebaseService {

  final Dio _dio = DioClient.create("Auth");

  /// Initializes FCM, persists token to LocalStorage and posts it to backend.
  /// Returns the obtained token (or null).
  Future<String?> initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    String? token = await messaging.getToken();
    if (token != null) {
      await LocalStorage.init();
      await LocalStorage.saveFCM(token);
      print('FirebaseService: obtained FCM token: $token');
      try {
        await _dio.post('/save-fcm', data: {'fcmToken': token});
      } catch (e) {
        print('FirebaseService: failed to post token: $e');
      }
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (newToken != null) {
        await LocalStorage.init();
        await LocalStorage.saveFCM(newToken);
        print('FirebaseService: refreshed FCM token: $newToken');
        try {
          await _dio.post('/save-fcm', data: {'fcmToken': newToken});
        } catch (e) {
          print('FirebaseService: failed to post refreshed token: $e');
        }
      }
    });

    return token;
  }

}