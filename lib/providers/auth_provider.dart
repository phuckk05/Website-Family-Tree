import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:website_gia_pha/services/auth_service.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  final AuthService _authService = AuthService();
  static const _isLoggedInKey = 'isLoggedIn';

  @override
  Future<bool> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Lỗi SharedPreferences (Web): $e');
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final success = await _authService.login(username, password);
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_isLoggedInKey, true);
        state = const AsyncData(true);
      }
      return success;
    } catch (e) {
      print('Lỗi Login Action: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isLoggedInKey);
    } catch (e) {
      print('Lỗi Logout Action: $e');
    }
    state = const AsyncData(false);
  }
}
