import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:reportesapp/core/navigation/navigator_key.dart';
import 'package:reportesapp/core/utils/dio_client.dart';
import '../utils/local_storage.dart';

class FirebaseService {
  final Dio _dio = DioClient.create("Auth");

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<String?> initFCM() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true, // Muestra la notificación emergente
          badge: true, // Actualiza el badge del ícono
          sound: true, // Reproduce sonido
        );

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    await _initLocalNotifications();

    String? token = await messaging.getToken();
    if (token != null) {
      await LocalStorage.init();
      await LocalStorage.saveFCM(token);

      try {
        await _dio.post('/save-fcm', data: {'fcmToken': token});
      } catch (e) {
        print('FirebaseService: failed to post token: $e');
      }
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await LocalStorage.init();
      await LocalStorage.saveFCM(newToken);

      try {
        await _dio.post('/save-fcm', data: {'fcmToken': newToken});
      } catch (e) {
        print('FirebaseService: failed to post refreshed token: $e');
      }
    });

    _listenForeground();
    _listenBackgroundTap();

    return token;
  }

  // ---------------- FOREGROUND ----------------
  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: message.data['reportId'],
      );
    });
  }

  // ---------------- TAP NOTIFICATION ----------------
  void _listenBackgroundTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNavigation(message.data);
    });
  }

  void _handleNavigation(Map<String, dynamic> data) {
    final reportId = data['reportId'];
    if (reportId != null) {
      navigatorKey.currentState!.pushNamed('/report/$reportId');
    }
  }

  // ---------------- LOCAL NOTIFICATIONS ----------------
  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _localNotifications.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          navigatorKey.currentState!.pushNamed('/report/${response.payload}');
        }
      },
    );
  }
}
