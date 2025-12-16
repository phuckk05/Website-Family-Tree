import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:website_gia_pha/models/album.dart';

class AlbumService {
  //kết nối firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'albums';

  //cập nhật thêm xóa xửa được lấy từ album_provider
  Future<void> addAlbum(Album album) async {
    await _firestore
        .collection(_collection)
        .doc(album.id.toString())
        .set(album.toMap());
  }

  //Cập nhật album
  Future<void> updateAlbum(Album album) async {
    await _firestore
        .collection(_collection)
        .doc(album.id.toString())
        .update(album.toMap());
  }

  //Xóa album
  Future<void> deleteAlbum(Album album) async {
    await _firestore.collection(_collection).doc(album.id.toString()).delete();
  }

  Stream<List<Album>> getAlbumsStream() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Album.fromMap(doc.data());
      }).toList();
    });
  }
}
