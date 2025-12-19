import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/models/loading_state.dart';

/// Notifier để quản lý loading state
class LoadingNotifier extends StateNotifier<LoadingState> {
  LoadingNotifier()
    : super(const LoadingState(isLoading: false, message: null));

  /// Hiển thị loading với message tùy chọn
  void show([String? message]) {
    state = LoadingState(isLoading: true, message: message ?? 'Đang tải...');
  }

  /// Ẩn loading
  void hide() {
    state = const LoadingState(isLoading: false, message: null);
  }

  /// Thực hiện async action với loading
  Future<T> withLoading<T>(
    Future<T> Function() action, {
    String? message,
  }) async {
    try {
      show(message);
      final result = await action();
      return result;
    } finally {
      hide();
    }
  }
}

/// Provider cho loading state
final loadingNotifierProvider =
    StateNotifierProvider<LoadingNotifier, LoadingState>((ref) {
      return LoadingNotifier();
    });
