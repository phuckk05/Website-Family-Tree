import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/providers/loading_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';

/// Loading overlay hiển thị phủ lên màn hình hiện tại
class LoadingOverlay extends ConsumerWidget {
  final Widget child;

  const LoadingOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingState = ref.watch(loadingNotifierProvider);

    return Stack(
      children: [
        child,
        if (loadingState.isLoading)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                constraints: const BoxConstraints(maxWidth: 300),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.creamPaper, AppColors.warmBeige],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.goldBorder, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Icon(
                      Icons.hourglass_empty_rounded,
                      size: 48,
                      color: AppColors.deepGreen,
                    ),
                    const SizedBox(height: 24),

                    // Loading indicator
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        backgroundColor: AppColors.vintageIvory.withOpacity(
                          0.3,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.deepGreen,
                        ),
                        minHeight: 3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Message
                    Text(
                      loadingState.message ?? 'Đang xử lý...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14,
                        color: AppColors.darkBrown,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
