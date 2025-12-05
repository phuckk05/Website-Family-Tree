import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:website_gia_pha/models/family_member.dart';

class FamilyTreeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'family_tree';
  final String _docId = 'main_tree';

  Stream<FamilyMember> getFamilyTreeStream() {
    return _firestore.collection(_collection).doc(_docId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists && snapshot.data() != null) {
        return FamilyMember.fromJson(snapshot.data()!);
      } else {
        // Trả về dữ liệu mặc định nếu chưa có
        return _generateDemoData();
      }
    });
  }

  Future<void> saveFamilyTree(FamilyMember root) async {
    await _firestore.collection(_collection).doc(_docId).set(root.toJson());
  }

  // Hàm tạo dữ liệu giả 5 thế hệ (để khởi tạo nếu chưa có DB)
  FamilyMember _generateDemoData() {
    return FamilyMember(
      id: '1',
      name: 'Nguyễn Văn Tổ',
      role: 'Thủy Tổ (Đời 1)',
      birthDate: '1850 - 1920',
      isMale: true,
      spouses: ['Cụ Bà'],
      children: [
        FamilyMember(
          id: '2',
          name: 'Nguyễn Văn Cả',
          role: 'Trưởng Nam (Đời 2)',
          birthDate: '1880 - 1950',
          isMale: true,
          spouses: ['Bà Cả'],
          children: [],
        ),
      ],
    );
  }
}
