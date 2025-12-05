import 'package:flutter/material.dart';
import 'package:website_gia_pha/themes/app_colors.dart';
import 'package:website_gia_pha/widgets/custom_header.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final bool enableScroll;

  const MainLayout({super.key, required this.child, this.enableScroll = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoryWhite,
      body: Column(
        children: [
          const CustomHeader(),
          Expanded(
            child: enableScroll ? SingleChildScrollView(child: child) : child,
          ),
        ],
      ),
    );
  }
}
