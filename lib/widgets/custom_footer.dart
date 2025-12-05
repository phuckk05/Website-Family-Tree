import 'package:flutter/material.dart';
import 'package:website_gia_pha/themes/app_colors.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.woodBrown,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text(
            'HỌ NGUYỄN – TỘC ĐÌNH CHI 5',
            style: TextStyle(
              color: AppColors.primaryGold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Địa chỉ: Xã Bạch Hà, Tỉnh Nghệ An, Việt Nam',
            style: TextStyle(color: Colors.white),
          ),
          const Text(
            'Email: lienhe@honguyen.com | SĐT: 0909 123 456',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          const Text(
            '© 2025 Họ Nguyễn – Tộc Đình Chi 5',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
