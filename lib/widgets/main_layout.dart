import 'package:flutter/material.dart';
import 'package:website_gia_pha/themes/app_colors.dart';
import 'package:website_gia_pha/widgets/custom_header.dart';
import 'package:website_gia_pha/widgets/custom_footer.dart';
import 'package:website_gia_pha/widgets/top_notification.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final bool enableScroll;
  final int index;

  const MainLayout({
    super.key,
    required this.child,
    this.enableScroll = true,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.ivoryWhite,
      body: Stack(
        children: [
          Column(
            children: [
              const CustomHeader(),
              Expanded(
                child:
                    enableScroll
                        ? SingleChildScrollView(
                          child: Column(
                            children: [
                              child,
                              index == 2 ? SizedBox() : const CustomFooter(),
                            ],
                          ),
                        )
                        : Column(
                          children: [
                            Expanded(child: child),
                            index == 2 ? SizedBox() : const CustomFooter(),
                          ],
                        ),
              ),
            ],
          ),
          const TopNotification(),
        ],
      ),
    );
  }
}
