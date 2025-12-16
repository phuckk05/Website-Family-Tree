import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/models/album.dart';
import 'package:website_gia_pha/services/album_service.dart';

class AlbumNotifierProvider extends StateNotifier<Set<Album>> {
  AlbumService albumService = AlbumService();
  AlbumNotifierProvider() : super(<Album>{});

  //Lấy tất cả album
  Stream<Set<Album>> getAlbums() {
    return albumService.getAlbumsStream().map((albumList) {
      return albumList.toSet();
    });
  }

  //thêm album
  Future<void> addAlbum(Album album) async {
    await albumService.addAlbum(album);
    state = {...state, album};
  }

  //xóa album
  void removeAlbum(Album album) async {
    await albumService.deleteAlbum(album);
    state = state.where((a) => a.id != album.id).toSet();
  }

  //cập nhật album
  void updateAlbum(Album updatedAlbum) async {
    await albumService.updateAlbum(updatedAlbum);
    state =
        state
            .map((album) => album.id == updatedAlbum.id ? updatedAlbum : album)
            .toSet();
  }

  //clear all albums
  void clearAlbums() {
    state = <Album>{};
  }
}

// Riverpod provider để quản lý album
final albumNotifierProvider =
    StateNotifierProvider<AlbumNotifierProvider, Set<Album>>(
      (ref) => AlbumNotifierProvider(),
    );
