import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> login(String username, String password) async {
    try {
      // Tìm trong collection 'users' xem có document nào khớp username không
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final data = userDoc.data();
        final storedPassword = data['password'];

        // So sánh mật khẩu (plain text như yêu cầu)
        return storedPassword == password;
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
}
