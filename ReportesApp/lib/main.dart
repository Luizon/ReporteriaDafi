import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reportesapp/new_report/new_report_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login/login_page.dart';
import 'reports/reports_page.dart';
import 'profile/profile_page.dart';
import 'core/utils/route_observer.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.requestPermission();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reportes App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      navigatorObservers: [routeObserver],
      routes: {
        '/login': (context) => const LoginPage(),
        '/reports': (context) => const ReportsPage(),
        '/newReport': (context) => const NewReportPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
