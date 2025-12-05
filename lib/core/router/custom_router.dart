import 'package:flutter/material.dart';

class CustomRouter {
  // Key để quản lý Navigator mà không cần context
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Push một trang mới vào stack
  static Future<dynamic> push(Widget page) {
    return navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // Thay thế trang hiện tại bằng trang mới
  static Future<dynamic> pushReplacement(Widget page) {
    return navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // Xóa hết stack và push trang mới (thường dùng cho Logout hoặc về Home)
  static Future<dynamic> pushAndRemoveUntil(Widget page) {
    return navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  // Quay lại trang trước
  static void pop([dynamic result]) {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop(result);
    }
  }
}
