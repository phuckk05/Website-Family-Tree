import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/providers/auth_provider.dart';
import 'package:website_gia_pha/providers/login_provider.dart';
import 'package:website_gia_pha/providers/notification_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final success = await ref
        .read(loginControllerProvider.notifier)
        .login(username, password);

    if (success && mounted) {
      Navigator.pop(context); // Return to previous screen (Family Tree)
      ref
          .read(notificationProvider.notifier)
          .show('Đăng nhập thành công!', type: NotificationType.success);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final isLoading = loginState.isLoading;
    final errorMessage =
        loginState.hasError ? loginState.error.toString() : null;

    return Scaffold(
      backgroundColor: AppColors.woodBrown,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEE58), // Yellow background
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD50000), width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ĐĂNG NHẬP',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD50000),
                    fontFamily:
                        'PlayfairDisplay', // Assuming font exists or fallback
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên đăng nhập',
                    labelStyle: TextStyle(color: AppColors.woodBrown),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD50000),
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(Icons.person, color: AppColors.woodBrown),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    labelStyle: TextStyle(color: AppColors.woodBrown),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD50000),
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(Icons.lock, color: AppColors.woodBrown),
                  ),
                  onSubmitted: (_) => _login(),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD50000),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'ĐĂNG NHẬP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back as guest
                  },
                  child: const Text(
                    'Quay lại (Chế độ xem)',
                    style: TextStyle(color: AppColors.woodBrown),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
