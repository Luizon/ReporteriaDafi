import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/auth_service.dart';
import '../core/models/user.dart';
import '../core/widgets/app_drawer.dart';

final userProvider = FutureProvider.autoDispose<User>((ref) async {
  final authService = ref.read(authServiceProvider);
  return await authService.me();
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      drawer: const AppDrawer(),
      body: userAsync.when(
        data: (user) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfileField("Usuario", user.username),
            _buildProfileField("Nombre", "${user.name} ${user.lastName}"),
            _buildProfileField("Cargo", user.position),
            _buildProfileField("Rol", user.role),
            _buildProfileField(
              "Fecha de nacimiento",
              user.birthDate.toLocal().toString().split(' ')[0],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: Text(
            "Error al cargar perfil: $err",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}