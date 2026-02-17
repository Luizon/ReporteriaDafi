import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reporteriadafi/core/navigation/navigator_key.dart';
import 'package:reporteriadafi/new_report/new_report_page.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // se invalidan reportes para forzar refrescar
      // para reflejar cambios recibidos por notificacion
      final container = ProviderScope.containerOf(context);
      container.invalidate(myReportsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reportes App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff042a80),
          primary: const Color(0xff042a80),
        ),
        scaffoldBackgroundColor: const Color(0xffe9ecf4),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      navigatorObservers: [routeObserver],
      navigatorKey: navigatorKey,
      routes: {
        '/login': (context) => const LoginPage(),
        '/reports': (context) => const ReportsPage(),
        '/newReport': (context) => const NewReportPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
