import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationType { success, error, info, warning }

class NotificationState {
  final String message;
  final NotificationType type;
  final Duration duration;
  final int id; // Dùng để phân biệt các thông báo khác nhau

  NotificationState({
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 3),
    required this.id,
  });
}

class NotificationNotifier extends StateNotifier<NotificationState?> {
  NotificationNotifier() : super(null);

  void show(
    String message,
    NotificationType error, {
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    state = NotificationState(
      message: message,
      type: type,
      duration: duration,
      id: DateTime.now().millisecondsSinceEpoch,
    );
  }

  void clear() {
    state = null;
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState?>((ref) {
      return NotificationNotifier();
    });
