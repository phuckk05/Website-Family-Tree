import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/providers/notification_provider.dart';

class TopNotification extends ConsumerStatefulWidget {
  const TopNotification({super.key});

  @override
  ConsumerState<TopNotification> createState() => _TopNotificationState();
}

class _TopNotificationState extends ConsumerState<TopNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  NotificationState? _currentNotification;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Hết thời gian, ẩn thông báo
        ref.read(notificationProvider.notifier).clear();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notification = ref.watch(notificationProvider);

    // Nếu có thông báo mới (khác ID hoặc mới hiện)
    if (notification != null &&
        (_currentNotification == null ||
            notification.id != _currentNotification!.id)) {
      _currentNotification = notification;
      _controller.duration = notification.duration;
      _controller.forward(from: 0.0);
    } else if (notification == null) {
      _currentNotification = null;
      _controller.stop();
    }

    if (_currentNotification == null) return const SizedBox.shrink();

    Color backgroundColor;
    IconData icon;
    Color textColor = Colors.white;

    switch (_currentNotification!.type) {
      case NotificationType.success:
        backgroundColor = const Color(0xFF2E7D32); // Green
        icon = Icons.check_circle;
        break;
      case NotificationType.error:
        backgroundColor = const Color(0xFFC62828); // Red
        icon = Icons.error;
        break;
      case NotificationType.warning:
        backgroundColor = const Color(0xFFEF6C00); // Orange
        icon = Icons.warning;
        break;
      case NotificationType.info:
      // ignore: unreachable_switch_default
      default:
        backgroundColor = const Color(0xFF1565C0); // Blue
        icon = Icons.info;
        break;
    }

    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1 || platform == 2;
    final double width = isMobile ? 300 : 400;

    final paddingHorizontal = isMobile ? 6.0 : 16.0;
    final paddingVertical = isMobile ? 4.0 : 12.0;

    return Positioned(
      top: 10,
      right: 10,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: width,
            constraints: BoxConstraints(maxWidth: isMobile ? 300 : 600),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias, // Để cắt progress bar
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: paddingHorizontal,
                    vertical: paddingVertical,
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: textColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _currentNotification!.message,
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: textColor, size: 20),
                        onPressed: () {
                          ref.read(notificationProvider.notifier).clear();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Progress Line
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: 1.0 - _controller.value, // Giảm dần
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.5),
                      ),
                      minHeight: 2,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
