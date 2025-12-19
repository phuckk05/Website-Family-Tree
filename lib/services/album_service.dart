import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/models/album.dart';

class AlbumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'albums';

  /// ADD ALBUM
  Future<void> addAlbum(int clanId, Album album) async {
    try {
      await _firestore.collection(_collection).doc(clanId.toString()).set({
        'albums': FieldValue.arrayUnion([album.toMap()]),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Lỗi addAlbum: $e');
      rethrow;
    }
  }

  /// UPDATE ALBUM
  Future<bool> updateAlbum(int clanId, Album updatedAlbum) async {
    try {
      final docRef = _firestore.collection(_collection).doc(clanId.toString());

      final snapshot = await docRef.get();
      if (!snapshot.exists) return false;

      final data = snapshot.data();
      if (data == null || data['albums'] == null) return false;

      final albums = List<Map<String, dynamic>>.from(data['albums']);

      final oldAlbum = albums.firstWhere(
        (a) => a['id'] == updatedAlbum.id,
        orElse: () => {},
      );

      if (oldAlbum.isEmpty) return false;

      await docRef.update({
        'albums': FieldValue.arrayRemove([oldAlbum]),
      });

      await docRef.update({
        'albums': FieldValue.arrayUnion([updatedAlbum.toMap()]),
      });
      return true;
    } catch (e) {
      debugPrint('Lỗi updateAlbum: $e');
      return false;
    }
  }

  /// DELETE ALBUM
  Future<void> deleteAlbum(int clanId, Album album) async {
    try {
      await _firestore.collection(_collection).doc(clanId.toString()).update({
        'albums': FieldValue.arrayRemove([album.toMap()]),
      });
    } catch (e) {
      debugPrint('Lỗi deleteAlbum: $e');
      rethrow;
    }
  }

  /// STREAM ALBUMS
  Stream<List<Album>> getAlbumsStream(int clanId) {
    return _firestore
        .collection(_collection)
        .doc(clanId.toString())
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return <Album>[];

          final data = snapshot.data();
          if (data == null || data['albums'] == null) return <Album>[];

          final albumsData = List<Map<String, dynamic>>.from(data['albums']);

          return albumsData.map((e) => Album.fromMap(e)).toList()
            ..sort((a, b) => b.id.compareTo(a.id));
        });
  }
}

final albumServiceProvider = Provider<AlbumService>((ref) => AlbumService());
