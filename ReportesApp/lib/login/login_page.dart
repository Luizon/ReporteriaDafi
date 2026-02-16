import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/auth_service.dart';
import '../core/utils/local_storage.dart';
import 'login_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await LocalStorage.init();
    final cookie = await LocalStorage.getCookie();
    if (cookie != null && cookie.isNotEmpty) {
      try {
        final authService = ref.read(authServiceProvider);
        final user = await authService.me();
        if (user != null) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/reports');
          }
        }
      } catch (e) {
        print("flutter: Sesión inválida o error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loginState.isLoading
                  ? null
                  : () async {
                      final success = await ref
                          .read(loginControllerProvider.notifier)
                          .login(emailController.text, passwordController.text);

                      if (success && mounted) {
                        Navigator.pushReplacementNamed(context, '/reports');
                      }
                    },
              child: loginState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Iniciar sesión'),
            ),
            if (loginState.hasError)
              Text(
                "Ocurrió un error inesperado",
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}