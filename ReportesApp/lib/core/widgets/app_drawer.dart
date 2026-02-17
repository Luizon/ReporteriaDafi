import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  void _navigateIfNeeded(BuildContext context, String routeName) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == routeName) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, routeName);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20, horizontal: 0
              ),
              child: Image(
                image: AssetImage('assets/img/DAFI_banner.png'),
                fit: BoxFit.contain
              ),
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Reportes'),
              onTap: () => _navigateIfNeeded(context, '/reports'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () => _navigateIfNeeded(context, '/profile'),
            ),
            Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await authService.logout(ref);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}