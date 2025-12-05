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
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<bool> login(String username, String password) async {
    final success = await _authService.login(username, password);
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      state = const AsyncData(true);
    }
    return success;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    state = const AsyncData(false);
  }
}
