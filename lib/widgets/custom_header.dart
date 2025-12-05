import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/core/router/custom_router.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/pages/index.dart';
import 'package:website_gia_pha/themes/app_colors.dart';

class CustomHeader extends ConsumerWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.woodBrown,
      padding:
          ref.watch(flatformNotifierProvider) == 1
              ? const EdgeInsets.symmetric(horizontal: 5, vertical: 10)
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
                  'HỌ NGUYỄN',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Serif', // Placeholder for calligraphy font
                  ),
                ),
                Text(
                  'TỘC ĐÌNH CHI 5',
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
            _buildMenuItem(
              'Tài liệu',
              () => CustomRouter.push(const DocumentsPage()),
            ),
            _buildMenuItem(
              'Sự kiện',
              () => CustomRouter.push(const EventsPage()),
            ),
            _buildMenuItem(
              'Liên hệ',
              () => CustomRouter.push(const ContactPage()),
            ),
          ] else
            PopupMenuButton<String>(
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
                  case 'Tài liệu':
                    CustomRouter.push(const DocumentsPage());
                    break;
                  case 'Sự kiện':
                    CustomRouter.push(const EventsPage());
                    break;
                  case 'Liên hệ':
                    CustomRouter.push(const ContactPage());
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  _buildPopupMenuItem('Trang chủ', Icons.home),
                  _buildPopupMenuItem('Gia phả', Icons.account_tree),
                  _buildPopupMenuItem('Hình ảnh', Icons.photo_library),
                  _buildPopupMenuItem('Tài liệu', Icons.description),
                  _buildPopupMenuItem('Sự kiện', Icons.event),
                  _buildPopupMenuItem('Liên hệ', Icons.contact_mail),
                  _buildPopupMenuItem('Đăng nhập', Icons.login),
                ];
              },
            ),
          const SizedBox(width: 20),
          // Login Button
          ref.watch(flatformNotifierProvider) == 3
              ? ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.woodBrown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Đăng nhập'),
              )
              : SizedBox(),
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
}
