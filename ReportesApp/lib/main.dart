import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reportesapp/core/utils/local_storage.dart';
import 'package:reportesapp/new_report/new_report_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login/login_page.dart';
import 'reports/reports_page.dart';
import 'profile/profile_page.dart';
import 'core/utils/route_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init(); // inicializa SharedPreferences

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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