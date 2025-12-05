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
      // Shift orders of existing children if needed
      final updatedExistingChildren =
          current.children.map((child) {
            if (child.order >= newChild.order) {
              return child.copyWith(order: child.order + 1);
            }
            return child;
          }).toList();

      final newChildren = [...updatedExistingChildren, newChild];
      newChildren.sort((a, b) => a.order.compareTo(b.order));
      return current.copyWith(children: newChildren);
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

  Future<void> updateMember(FamilyMember updatedMember) async {
    final currentRoot = state.value;
    if (currentRoot == null) return;

    final newRoot = _updateMemberRecursive(currentRoot, updatedMember);
    await _service.saveFamilyTree(newRoot);
  }

  FamilyMember _updateMemberRecursive(
    FamilyMember current,
    FamilyMember updated,
  ) {
    // Case 1: Updating the current node itself (e.g. Root)
    if (current.id == updated.id) {
      return current.copyWith(
        name: updated.name,
        role: updated.role,
        birthDate: updated.birthDate,
        isMale: updated.isMale,
        order: updated.order,
        spouses: updated.spouses,
        children: current.children,
      );
    }

    // Case 2: Updating a direct child of the current node
    final index = current.children.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      final oldChild = current.children[index];
      final oldOrder = oldChild.order;
      final newOrder = updated.order;

      // Ensure we preserve the children of the updated node from the source of truth
      final realUpdated = updated.copyWith(children: oldChild.children);

      List<FamilyMember> newChildren;

      if (oldOrder != newOrder) {
        newChildren =
            current.children.map((child) {
              if (child.id == updated.id) {
                return realUpdated;
              }

              if (newOrder > oldOrder) {
                // Moving down (e.g. 1 -> 3). Shift items (1, 3] down by 1.
                if (child.order > oldOrder && child.order <= newOrder) {
                  return child.copyWith(order: child.order - 1);
                }
              } else {
                // Moving up (e.g. 3 -> 1). Shift items [1, 3) up by 1.
                if (child.order >= newOrder && child.order < oldOrder) {
                  return child.copyWith(order: child.order + 1);
                }
              }
              return child;
            }).toList();
      } else {
        newChildren =
            current.children.map((child) {
              if (child.id == updated.id) return realUpdated;
              return child;
            }).toList();
      }

      newChildren.sort((a, b) => a.order.compareTo(b.order));
      return current.copyWith(children: newChildren);
    }

    // Case 3: Recurse deeper
    final newChildren =
        current.children
            .map((child) => _updateMemberRecursive(child, updated))
            .toList();

    // Sort children to ensure order is maintained at all levels
    newChildren.sort((a, b) => a.order.compareTo(b.order));

    return current.copyWith(children: newChildren);
  }

  Future<void> deleteMember(String memberId) async {
    final currentRoot = state.value;
    if (currentRoot == null) return;

    if (currentRoot.id == memberId) {
      // Prevent deleting root for now, or handle it appropriately
      return;
    }

    final newRoot = _deleteMemberRecursive(currentRoot, memberId);
    await _service.saveFamilyTree(newRoot);
  }

  FamilyMember _deleteMemberRecursive(FamilyMember current, String targetId) {
    final updatedChildren =
        current.children
            .where((child) => child.id != targetId)
            .map((child) => _deleteMemberRecursive(child, targetId))
            .toList();

    return current.copyWith(children: updatedChildren);
  }
}
