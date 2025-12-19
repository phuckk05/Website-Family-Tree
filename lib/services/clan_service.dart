import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:website_gia_pha/models/clan.dart';

class ClanServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'clans';

  /// STREAM ALL CLANS
  Stream<List<Clan>> getClansStream() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final id = int.tryParse(doc.id) ?? 0;
        return Clan.fromMap(id, doc.data());
      }).toList();
    });
  }

  /// STREAM CLANS BY SUBDOMAIN
  Stream<List<Clan>> getClansBySubdomain(String subdomain) {
    return _firestore
        .collection(_collection)
        .where('subNameUrl', isEqualTo: subdomain)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final id = int.tryParse(doc.id) ?? 0;
            return Clan.fromMap(id, doc.data());
          }).toList();
        });
  }

  /// GET ONCE BY SUBDOMAIN
  Future<Clan?> getClanOnceBySubdomain(String subdomain) async {
    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('subNameUrl', isEqualTo: subdomain)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final id = int.tryParse(doc.id) ?? 0;

      return Clan.fromMap(id, doc.data());
    } catch (e) {
      debugPrint('getClanOnceBySubdomain error: $e');
      return null;
    }
  }

  /// ADD CLAN
  Future<int> addClan(Clan clan) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(clan.id.toString())
          .set(clan.toMap());
      return clan.id;
    } catch (e) {
      debugPrint('addClan error: $e');
      rethrow;
    }
  }

  /// UPDATE CLAN
  Future<void> updateClan(int clanId, Clan clan) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(clanId.toString())
          .update(clan.toMap());
    } catch (e) {
      debugPrint('updateClan error: $e');
      rethrow;
    }
  }

  /// DELETE CLAN
  Future<void> deleteClan(int clanId) async {
    try {
      await _firestore.collection(_collection).doc(clanId.toString()).delete();
    } catch (e) {
      debugPrint('deleteClan error: $e');
      rethrow;
    }
  }
}

final clanServiceProvider = Provider<ClanServices>((ref) {
  return ClanServices();
});
