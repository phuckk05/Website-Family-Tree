import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/core/router/custom_router.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/providers/auth_provider.dart';
import 'package:website_gia_pha/providers/clan_provider.dart';
import 'package:website_gia_pha/providers/notification_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';

/// Header với phong cách vintage 1990s Vietnamese
///
/// Hiển thị logo, tiêu đề họ, menu điều hướng và nút đăng nhập
/// với thiết kế ấm áp, nostalgic như những tấm biển gỗ cũ
class CustomHeader extends ConsumerStatefulWidget {
  const CustomHeader({super.key});

  @override
  ConsumerState<CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends ConsumerState<CustomHeader> {
  String? _hoveredItem;

  @override
  Widget build(BuildContext context) {
    final isMobile = ref.watch(flatformNotifierProvider) != 3;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.woodBrown, AppColors.woodBrown.withOpacity(0.95)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryGold.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      padding:
          isMobile
              ? const EdgeInsets.symmetric(horizontal: 5, vertical: 5)
              : const EdgeInsets.symmetric(horizontal: 36, vertical: 15),
      child: Row(
        children: [
          _buildLogo(),
          const SizedBox(width: 16),
          _buildTitle(),
          const Spacer(),
          if (!isMobile) ..._buildDesktopMenu(),
          if (isMobile) _buildMobileMenu(),
        ],
      ),
    );
  }

  /// Xây dựng logo chùa với hiệu ứng vintage
  Widget _buildLogo() {
    return InkWell(
      onTap: () => AppRouter.go(context, AppRouter.home),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryGold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.4),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.temple_buddhist,
          color: AppColors.primaryGold,
          size: 36,
        ),
      ),
    );
  }

  /// Xây dựng tiêu đề họ với typography vintage
  Widget _buildTitle() {
    final clan = ref.watch(clanNotifierProvider);
    return InkWell(
      onTap: () => AppRouter.go(context, AppRouter.home),
      child: clan.when(
        data: (data) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.first.name,
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 2,
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
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data.first.chi,
                  style: TextStyle(
                    color: AppColors.creamPaper,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    fontFamily: 'Serif',
                  ),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          return Text(
            'unknown',
            style: TextStyle(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 2,
              fontFamily: 'Serif',
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          );
        },
        loading: () {
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  /// Xây dựng menu desktop với hiệu ứng hover
  List<Widget> _buildDesktopMenu() {
    final authState = ref.watch(authProvider);
    return [
      _buildMenuItem('Trang chủ', Icons.home, () {
        AppRouter.go(context, AppRouter.home);
      }),
      _buildMenuItem('Gia phả', Icons.account_tree, () {
        AppRouter.go(context, AppRouter.familyTree);
      }),
      _buildMenuItem('Hình ảnh', Icons.photo_library, () {
        AppRouter.go(context, AppRouter.gallery);
      }),
      _buildMenuItem('Liên hệ', Icons.contact_mail, () {
        AppRouter.go(context, AppRouter.contact);
      }),
      authState.when(
        data: (isLoggedIn) {
          if (isLoggedIn) {
            return _buildMenuItem('Cài đặt', Icons.settings, () {
              AppRouter.go(context, AppRouter.settings);
            });
          }
          return SizedBox();
        },
        error: (error, stackTrace) {
          return SizedBox();
        },
        loading: () {
          return const SizedBox();
        },
      ),
      const SizedBox(width: 16),
      _buildLoginButton(),
    ];
  }

  /// Xây dựng item menu với hover effect
  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    final isHovered = _hoveredItem == title;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredItem = title),
      onExit: (_) => setState(() => _hoveredItem = null),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color:
                isHovered
                    ? AppColors.primaryGold.withOpacity(0.15)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isHovered
                      ? AppColors.primaryGold.withOpacity(0.5)
                      : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: TextButton.icon(
            onPressed: onTap,
            icon: Icon(
              icon,
              color: isHovered ? AppColors.primaryGold : AppColors.creamPaper,
              size: 18,
            ),
            label: Text(
              title,
              style: TextStyle(
                color: isHovered ? AppColors.primaryGold : AppColors.creamPaper,
                fontSize: 15,
                fontFamily: 'Serif',
                letterSpacing: 0.5,
                fontWeight: isHovered ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  /// Xây dựng nút đăng nhập/đăng xuất
  Widget _buildLoginButton() {
    final authState = ref.watch(authProvider);
    return authState.when(
      data: (isLoggedIn) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton.icon(
              onPressed: () {
                if (isLoggedIn) {
                  ref.read(authProvider.notifier).logout();
                  ref
                      .read(notificationProvider.notifier)
                      .show('Đã đăng xuất', NotificationType.info);
                } else {
                  AppRouter.go(context, AppRouter.login);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isLoggedIn ? AppColors.dustyRose : AppColors.primaryGold,
                foregroundColor:
                    isLoggedIn ? AppColors.creamPaper : AppColors.woodBrown,
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color:
                        isLoggedIn
                            ? AppColors.dustyRose.withOpacity(0.5)
                            : AppColors.primaryGold.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              icon: Icon(isLoggedIn ? Icons.logout : Icons.login, size: 18),
              label: Text(
                isLoggedIn ? 'Đăng xuất' : 'Đăng nhập',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Serif',
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
      loading:
          () => Container(
            padding: const EdgeInsets.all(12),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryGold,
              ),
            ),
          ),
      error: (_, __) => const Icon(Icons.error, color: AppColors.dustyRose),
    );
  }

  /// Xây dựng menu mobile (popup)
  Widget _buildMobileMenu() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryGold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.4),
            width: 2,
          ),
        ),
        child: const Icon(Icons.menu, color: AppColors.primaryGold, size: 24),
      ),
      color: AppColors.creamPaper,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.bronzeBorder.withOpacity(0.3),
          width: 2,
        ),
      ),
      onSelected: (value) {
        switch (value) {
          case 'Trang chủ':
            AppRouter.go(context, AppRouter.home);
            break;
          case 'Gia phả':
            AppRouter.go(context, AppRouter.familyTree);
            break;
          case 'Hình ảnh':
            AppRouter.go(context, AppRouter.gallery);
            break;
          case 'Liên hệ':
            AppRouter.go(context, AppRouter.contact);
            break;
          case 'Đăng nhập':
            AppRouter.go(context, AppRouter.login);
            break;
          case 'Cài đặt':
            AppRouter.go(context, AppRouter.settings);
            break;
          case 'Đăng xuất':
            ref.read(authProvider.notifier).logout();
            ref
                .read(notificationProvider.notifier)
                .show('Đã đăng xuất', NotificationType.info);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        final isLoggedIn = ref.watch(authProvider).value ?? false;
        return [
          _buildPopupMenuItem('Trang chủ', Icons.home),
          _buildPopupMenuItem('Gia phả', Icons.account_tree),
          _buildPopupMenuItem('Hình ảnh', Icons.photo_library),
          _buildPopupMenuItem('Liên hệ', Icons.contact_mail),
          _buildPopupMenuItem(
            isLoggedIn ? 'Cài đặt' : null,
            isLoggedIn ? Icons.settings : null,
          ),
          const PopupMenuDivider(),
          _buildPopupMenuItem(
            isLoggedIn ? 'Đăng xuất' : 'Đăng nhập',
            isLoggedIn ? Icons.logout : Icons.login,
          ),
        ];
      },
    );
  }

  /// Xây dựng popup menu item với style vintage
  PopupMenuItem<String> _buildPopupMenuItem(String? title, IconData? icon) {
    return PopupMenuItem<String>(
      value: title,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: AppColors.woodBrown, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title ?? 'unknown',
              style: const TextStyle(
                color: AppColors.woodBrown,
                fontWeight: FontWeight.w500,
                fontFamily: 'Serif',
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
