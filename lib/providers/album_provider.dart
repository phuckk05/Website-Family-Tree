import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/models/album.dart';
import 'package:website_gia_pha/providers/clan_provider.dart';
import 'package:website_gia_pha/services/album_service.dart';

class AlbumNotifierProvider extends StreamNotifier<List<Album>> {
  @override
  Stream<List<Album>> build() {
    final albumService = ref.read(albumServiceProvider);
    final clan = ref.watch(clanNotifierProvider);
    return clan.when(
      data: (data) {
        return albumService.getAlbumsStream(data.first.id).handleError((error) {
          debugPrint('Lỗi stream album: $error');
        });
      },
      error: (error, stackTrace) {
        debugPrint('Lỗi lấy clan trong album provider: $error');
        return Stream.value([]);
      },
      loading: () {
        return Stream.value([]);
      },
    );
  }

  //thêm album
  Future<void> addAlbum(int clanId, Album album) async {
    await ref.read(albumServiceProvider).addAlbum(clanId, album);
    // State sẽ tự động update từ stream listener
  }

  // Thêm ảnh vào album
  Future<bool> addPhotoToAlbum(
    int clanId,
    List<String> urls,
    int? albumId,
  ) async {
    if (urls.isEmpty && albumId == null) return false;
    //Lấy album cần thêm ảnh
    Album? targetAlbum =
        state
            .whenData(
              (value) => value.where((album) => album.id == albumId).first,
            )
            .value;

    if (targetAlbum == null) return false;
    try {
      //Tạo danh sách ảnh mới
      List<Photos> newPhotos =
          urls
              .map((url) => Photos.create(url: url, albumId: albumId!))
              .toList();
      //Cập nhật album với danh sách ảnh mới
      Album updatedAlbum = targetAlbum.copyWith(
        photos: [...?targetAlbum.photos, ...newPhotos],
      );
      //Cập nhật lên firebase
      await ref.read(albumServiceProvider).updateAlbum(clanId, updatedAlbum);
      //Trả về thành công
      return true;
    } catch (e) {
      debugPrint('Lỗi thêm ảnh vào album: $e');
      return false;
    }
  }

  //xóa album
  Future<bool> removeAlbum(int clanId, Album album) async {
    try {
      await ref.read(albumServiceProvider).deleteAlbum(clanId, album);
      return true;
    } catch (e) {
      debugPrint('Lỗi xóa album: $e');
      return false;
    }
  }

  //cập nhật album
  Future<bool> updateAlbum(int clanId, Album updatedAlbum) async {
    try {
      await ref.read(albumServiceProvider).updateAlbum(clanId, updatedAlbum);
      return true;
    } catch (e) {
      debugPrint('Lỗi cập nhật album: $e');
      return false;
    }
  }

  //clear all albums
  void clearAlbums() {
    // state = <Album>{};
  }

  // @override
  // void dispose() {
  //   // albumSubscription?.cancel();
  //   // super.dispose();
  // }
}

// Riverpod provider để quản lý album

final albumNotifierProvider =
    StreamNotifierProvider<AlbumNotifierProvider, List<Album>>(
      AlbumNotifierProvider.new,
    );
