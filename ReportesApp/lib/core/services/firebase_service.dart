import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reportesapp/core/navigation/navigator_key.dart';
import 'package:reportesapp/core/utils/dio_client.dart';
import 'package:reportesapp/reports/report_detail_page.dart';
import '../utils/local_storage.dart';
import '../models/report.dart';
import '../../reports/reports_page.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService(ref);
});

class FirebaseService {
  FirebaseService(this.ref);

  final Ref ref;

  final Dio _dio = DioClient.create("Auth");
  final Dio _reportsDio = DioClient.createHttp("/Reports");

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<String?> initFCM() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    await _initLocalNotifications();

    final token = await messaging.getToken();
    if (token != null) {
      await LocalStorage.init();
      await LocalStorage.saveFCM(token);

      try {
        await _dio.post('/save-fcm', data: {'fcmToken': token});
      } catch (_) {}
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await LocalStorage.init();
      await LocalStorage.saveFCM(newToken);
      await _dio.post('/save-fcm', data: {'fcmToken': newToken});
    });

    _listenForeground();
    _listenBackgroundTap();

    return token;
  }

  // ---------------- FOREGROUND ----------------
  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((message) {
      final n = message.notification;
      if (n == null) return;

      _localNotifications.show(
        id: n.hashCode,
        title: n.title,
        body: n.body,
        notificationDetails: NotificationDetails(
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

  Future<void> _handleNavigation(Map<String, dynamic> data) async {
    final idStr = data['reportId'];
    if (idStr == null) return;

    final id = int.tryParse(idStr.toString());
    if (id == null) return;

    try {
      final report = await _fetchReportById(id);

      ref.invalidate(myReportsProvider);

      _navigate(report);
    } catch (e) {
      print('FCM navigation error: $e');
    }
  }

  Future<Report> _fetchReportById(int id) async {
    final res = await _reportsDio.get('/$id');
    return Report.fromJson(res.data);
  }

  void _navigate(Report report) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    nav.push(
      MaterialPageRoute(builder: (_) => ReportDetailPage(report: report)),
    );
  }

  // ---------------- LOCAL NOTIFICATIONS ----------------
  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _localNotifications.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (resp) {
        if (resp.payload != null) {
          _handleNavigation({'reportId': resp.payload});
        }
      },
    );
  }
}
