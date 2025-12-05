import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:website_gia_pha/models/family_member.dart';
import 'package:website_gia_pha/services/family_tree_service.dart';

part 'family_tree_provider.g.dart';

@riverpod
class FamilyTree extends _$FamilyTree {
  final FamilyTreeService _service = FamilyTreeService();

  @override
  Stream<FamilyMember> build() {
    return _service.getFamilyTreeStream();
  }

  Future<void> addChild(String parentId, FamilyMember newChild) async {
    final currentRoot = state.value;
    if (currentRoot == null) return;

    final newRoot = _addChildRecursive(currentRoot, parentId, newChild);
    await _service.saveFamilyTree(newRoot);
  }

  FamilyMember _addChildRecursive(
    FamilyMember current,
    String targetId,
    FamilyMember newChild,
  ) {
    if (current.id == targetId) {
      return current.copyWith(children: [...current.children, newChild]);
    }

    return current.copyWith(
      children:
          current.children
              .map((child) => _addChildRecursive(child, targetId, newChild))
              .toList(),
    );
  }

  Future<void> addSpouse(String memberId, String spouseName) async {
    final currentRoot = state.value;
    if (currentRoot == null) return;

    final newRoot = _addSpouseRecursive(currentRoot, memberId, spouseName);
    await _service.saveFamilyTree(newRoot);
  }

  FamilyMember _addSpouseRecursive(
    FamilyMember current,
    String targetId,
    String spouseName,
  ) {
    if (current.id == targetId) {
      return current.copyWith(spouses: [...current.spouses, spouseName]);
    }

    return current.copyWith(
      children:
          current.children
              .map((child) => _addSpouseRecursive(child, targetId, spouseName))
              .toList(),
    );
  }
}
