import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/themes/app_colors.dart';

class label extends ConsumerWidget {
  final String labelString;
  final VoidCallback? onPressed;
  final IconData? iconData;
  final String? textIcon;
  const label({
    super.key,
    required this.labelString,
    this.onPressed,
    this.iconData,
    this.textIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          labelString,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 18,
            color: AppColors.mutedText,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isMobile)
          IconButton(
            onPressed: onPressed,
            icon: Icon(iconData ?? Icons.add, size: 16),
          ),
        if (!isMobile)
          TextButton.icon(
            onPressed: onPressed,
            icon: Icon(iconData ?? Icons.add, size: 16),
            label: Text(textIcon ?? 'Thêm mới'),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppColors.goldBorder),
              ),
              foregroundColor: AppColors.goldBorder,
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }
}
