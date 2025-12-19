import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/themes/app_colors.dart';

/// Loading page với vintage style - dùng cho full screen loading
/// Không liên kết với loading provider
class LoadingPage extends ConsumerWidget {
  final String? message;

  const LoadingPage({super.key, this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.warmBeige,
                AppColors.paperBeige,
                AppColors.lightBrown.withOpacity(0.3),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo hoặc icon gia phả
                Container(
                  width: isMobile ? 60 : 120,
                  height: isMobile ? 60 : 120,
                  decoration: BoxDecoration(
                    color: AppColors.creamPaper,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.goldBorder, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.temple_buddhist,
                    size: isMobile ? 30 : 60,
                    color: AppColors.deepGreen,
                  ),
                ),

                const SizedBox(height: 40),

                // Text
                Text(
                  message ?? 'Đang tải dữ liệu gia phả...',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                    color: AppColors.mutedText,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 16),

                // Loading indicator
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.vintageIvory.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.deepGreen,
                    ),
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(4),
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
