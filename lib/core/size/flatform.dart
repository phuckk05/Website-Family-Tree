import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlatformNotifier extends StateNotifier<int> {
  FlatformNotifier() : super(3);

  //Kiểm tra kích thước màn hình hiện tại và cập nhật trạng thái
  void updateFlatform(double width) {
    if (width >= 1200) {
      state = 3; // Desktop
    } else if (width >= 800) {
      state = 2; // Tablet
    } else {
      state = 1; // Mobile
    }
  }
}

final flatformNotifierProvider = StateNotifierProvider<FlatformNotifier, int>(
  (ref) => FlatformNotifier(),
);
