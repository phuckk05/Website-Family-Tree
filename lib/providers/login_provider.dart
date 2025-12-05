import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:website_gia_pha/providers/auth_provider.dart';

part 'login_provider.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  Future<bool> login(String username, String password) async {
    state = const AsyncLoading();

    if (username.isEmpty || password.isEmpty) {
      state = AsyncError('Vui lòng nhập đầy đủ thông tin', StackTrace.current);
      return false;
    }

    try {
      final success = await ref
          .read(authProvider.notifier)
          .login(username, password);
      if (success) {
        state = const AsyncData(null);
        return true;
      } else {
        state = AsyncError(
          'Tên đăng nhập hoặc mật khẩu không đúng',
          StackTrace.current,
        );
        return false;
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
