import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:website_gia_pha/models/family_member.dart';

class FamilyTreeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'family_tree';

  /// STREAM FAMILY TREE
  Stream<FamilyMember> getFamilyTreeStreamById(int clanId) {
    return _firestore
        .collection(_collection)
        .doc(clanId.toString())
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return FamilyMember.fromJson(snapshot.data()!);
          }

          // default root nếu chưa có
          return FamilyMember(
            id: const Uuid().v4(),
            name: 'Nguyễn Văn Tổ',
            role: 'Thủy Tổ (Đời 1)',
            birthDate: '1850 - 1920',
            isMale: true,
            spouses: const ['Cụ Bà'],
            children: const [],
          );
        });
  }

  /// SAVE FAMILY TREE

  Future<void> saveFamilyTree(int clanId, FamilyMember root) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(clanId.toString())
          .set(root.toJson());
    } catch (e) {
      debugPrint(' saveFamilyTree error: $e');
      rethrow;
    }
  }

  /// GENERATE DEFAULT ROOT
  FamilyMember generateDefaultRoot() {
    return FamilyMember(
      id: const Uuid().v4(),
      name: 'Nguyễn Văn Tổ',
      role: 'Thủy Tổ (Đời 1)',
      birthDate: '1850 - 1920',
      isMale: true,
      spouses: const ['Cụ Bà'],
      children: const [],
    );
  }
}

final familyTreeServiceProvider = Provider<FamilyTreeService>(
  (ref) => FamilyTreeService(),
);
