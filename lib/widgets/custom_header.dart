import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/core/router/custom_router.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/pages/index.dart';
import 'package:website_gia_pha/pages/login_page.dart';
import 'package:website_gia_pha/providers/auth_provider.dart';
import 'package:website_gia_pha/providers/notification_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';

class CustomHeader extends ConsumerWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.woodBrown,
      padding:
          ref.watch(flatformNotifierProvider) == 1
              ? const EdgeInsets.symmetric(horizontal: 5, vertical: 5)
              : const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      child: Row(
        children: [
          // Logo (Placeholder)
          InkWell(
            onTap: () => CustomRouter.pushAndRemoveUntil(const HomePage()),
            child: const Icon(
              Icons.account_balance,
              color: AppColors.primaryGold,
              size: 40,
            ),
          ),
          const SizedBox(width: 10),
          // Title
          InkWell(
            onTap: () => CustomRouter.pushAndRemoveUntil(const HomePage()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HỌ NGUYỄN ĐÌNH',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Serif', // Placeholder for calligraphy font
                  ),
                ),
                Text(
                  'CHI 5',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Menu
          if (ref.watch(flatformNotifierProvider) == 3) ...[
            _buildMenuItem(
              'Trang chủ',
              () => CustomRouter.pushAndRemoveUntil(const HomePage()),
            ),
            _buildMenuItem(
              'Gia phả',
              () => CustomRouter.push(const FamilyTreePage()),
            ),
            _buildMenuItem(
              'Hình ảnh',
              () => CustomRouter.push(const GalleryPage()),
            ),
            // _buildMenuItem(
            //   'Tài liệu',
            //   () => CustomRouter.push(const DocumentsPage()),
            // ),
            // _buildMenuItem(
            //   'Sự kiện',
            //   () => CustomRouter.push(const EventsPage()),
            // ),
            _buildMenuItem(
              'Liên hệ',
              () => CustomRouter.push(const ContactPage()),
            ),
            const SizedBox(width: 10),
            _buildLoginButton(context, ref),
          ],
          Visibility(
            visible: ref.watch(flatformNotifierProvider) != 3,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: false,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: AppColors.primaryGold),
              color: AppColors.ivoryWhite,
              onSelected: (value) {
                switch (value) {
                  case 'Trang chủ':
                    CustomRouter.pushAndRemoveUntil(const HomePage());
                    break;
                  case 'Gia phả':
                    CustomRouter.push(const FamilyTreePage());
                    break;
                  case 'Hình ảnh':
                    CustomRouter.push(const GalleryPage());
                    break;
                  // case 'Tài liệu':
                  //   CustomRouter.push(const DocumentsPage());
                  //   break;
                  // case 'Sự kiện':
                  //   CustomRouter.push(const EventsPage());
                  //   break;
                  case 'Liên hệ':
                    CustomRouter.push(const ContactPage());
                    break;
                  case 'Đăng nhập':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                    break;
                  case 'Đăng xuất':
                    ref.read(authProvider.notifier).logout();
                    ref
                        .read(notificationProvider.notifier)
                        .show('Đã đăng xuất', type: NotificationType.info);
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                final isLoggedIn = ref.watch(authProvider).value ?? false;
                return [
                  _buildPopupMenuItem('Trang chủ', Icons.home),
                  _buildPopupMenuItem('Gia phả', Icons.account_tree),
                  _buildPopupMenuItem('Hình ảnh', Icons.photo_library),
                  // _buildPopupMenuItem('Tài liệu', Icons.description),
                  // _buildPopupMenuItem('Sự kiện', Icons.event),
                  _buildPopupMenuItem('Liên hệ', Icons.contact_mail),
                  _buildPopupMenuItem(
                    isLoggedIn ? 'Đăng xuất' : 'Đăng nhập',
                    isLoggedIn ? Icons.logout : Icons.login,
                  ),
                ];
              },
            ),
          ),
          // // Login Button
          // ref.watch(flatformNotifierProvider) == 3
          //     ? Row(
          //       children: [
          //         const SizedBox(width: 20),
          //         ElevatedButton(
          //           onPressed: () {
          //             CustomRouter.push(const LoginPage());
          //           },
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: AppColors.primaryGold,
          //             foregroundColor: AppColors.woodBrown,
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(8),
          //             ),
          //           ),
          //           child: const Text('Đăng nhập'),
          //         ),
          //       ],
          //     )
          //     : SizedBox(),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String title, IconData icon) {
    return PopupMenuItem<String>(
      value: title,
      child: Row(
        children: [
          Icon(icon, color: AppColors.woodBrown, size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.woodBrown,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          title,
          style: const TextStyle(color: AppColors.ivoryWhite, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return authState.when(
      data:
          (isLoggedIn) => ElevatedButton.icon(
            onPressed: () {
              if (isLoggedIn) {
                ref.read(authProvider.notifier).logout();
                ref
                    .read(notificationProvider.notifier)
                    .show('Đã đăng xuất', type: NotificationType.info);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isLoggedIn ? Colors.red : AppColors.primaryGold,
              foregroundColor: isLoggedIn ? Colors.white : AppColors.woodBrown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: Icon(isLoggedIn ? Icons.logout : Icons.login, size: 16),
            label: Text(isLoggedIn ? 'Đăng xuất' : 'Đăng nhập'),
          ),
      loading:
          () => const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryGold,
            ),
          ),
      error: (_, __) => const Icon(Icons.error, color: Colors.red),
    );
  }
}
