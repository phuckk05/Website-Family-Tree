import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/providers/login_provider.dart';
import 'package:website_gia_pha/providers/notification_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';

/// Login Page với phong cách vintage 1990s Vietnamese
///
/// Trang đăng nhập an toàn cho quản trị viên gia phả
/// với thiết kế ấm áp, trang trọng như sổ gia phả cổ
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

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
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.warmBeige,
                AppColors.creamPaper,
                AppColors.warmBeige.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 10 : 40),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 480,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header với logo và tiêu đề
                    _buildHeader(),
                    const SizedBox(height: 40),

                    // Card đăng nhập chính
                    _buildLoginCard(isLoading, errorMessage, isMobile),

                    const SizedBox(height: 24),

                    // Nút quay lại
                    _buildBackButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Xây dựng header với logo và tiêu đề
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo temple
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryGold.withOpacity(0.4),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.softShadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.temple_buddhist,
            color: AppColors.primaryGold,
            size: 56,
          ),
        ),
        const SizedBox(height: 20),

        // Tên họ
        Text(
          'HỌ NGUYỄN ĐÌNH',
          style: TextStyle(
            color: AppColors.woodBrown,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            fontFamily: 'Serif',
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Chi 5 badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryGold.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: const Text(
            'CHI 5',
            style: TextStyle(
              color: AppColors.woodBrown,
              fontSize: 14,
              letterSpacing: 2,
              fontFamily: 'Serif',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Xây dựng card đăng nhập chính
  Widget _buildLoginCard(bool isLoading, String? errorMessage, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.creamPaper, AppColors.vintageIvory],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldBorder.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tiêu đề đăng nhập
          Center(
            child: Column(
              children: [
                Text(
                  'ĐĂNG NHẬP',
                  style: TextStyle(
                    color: AppColors.woodBrown,
                    fontSize: isMobile ? 22 : 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primaryGold,
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dành cho quản trị viên',
                  style: TextStyle(
                    color: AppColors.woodBrown.withOpacity(0.7),
                    fontSize: 13,
                    fontFamily: 'Serif',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Username field
          _buildVintageTextField(
            controller: _usernameController,
            label: 'Tên đăng nhập',
            icon: Icons.person,
            isPassword: false,
          ),
          const SizedBox(height: 20),

          // Password field
          _buildVintageTextField(
            controller: _passwordController,
            label: 'Mật khẩu',
            icon: Icons.lock,
            isPassword: true,
            onSubmitted: (_) => _login(),
          ),

          // Error message
          if (errorMessage != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dustyRose.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.dustyRose.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.burgundyAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(
                        color: AppColors.burgundyAccent,
                        fontSize: 13,
                        fontFamily: 'Serif',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),

          // Login button
          _buildLoginButton(isLoading),
        ],
      ),
    );
  }

  /// Xây dựng text field vintage
  Widget _buildVintageTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isPassword,
    void Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.woodBrown.withOpacity(0.8),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontFamily: 'Serif',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.bronzeBorder.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !_isPasswordVisible,
            onSubmitted: onSubmitted,
            style: const TextStyle(
              color: AppColors.woodBrown,
              fontSize: 15,
              fontFamily: 'Serif',
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: AppColors.primaryGold.withOpacity(0.7),
                size: 20,
              ),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.woodBrown.withOpacity(0.5),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              hintStyle: TextStyle(
                color: AppColors.woodBrown.withOpacity(0.4),
                fontSize: 14,
                fontFamily: 'Serif',
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Xây dựng nút đăng nhập
  Widget _buildLoginButton(bool isLoading) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGold, AppColors.sepiaTone],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : _login,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child:
                isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.login, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'ĐĂNG NHẬP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontFamily: 'Serif',
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  /// Xây dựng nút quay lại
  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(
        Icons.arrow_back,
        color: AppColors.woodBrown.withOpacity(0.7),
        size: 18,
      ),
      label: Text(
        'Quay lại (Chế độ xem)',
        style: TextStyle(
          color: AppColors.woodBrown.withOpacity(0.8),
          fontSize: 14,
          fontFamily: 'Serif',
          letterSpacing: 0.5,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
