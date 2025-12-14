import 'package:flutter/material.dart';
import 'package:website_gia_pha/themes/app_colors.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF050505), // Darker matte black for footer
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text(
            'HỌ NGUYỄN ĐÌNH - CHI 5',
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
            'Email: phuckk2101@gmail.com | SĐT: 0328262101',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          const Text(
            '© 2025 Họ Nguyễn Đình - Chi 5',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
