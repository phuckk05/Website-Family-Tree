import 'dart:convert';

import 'package:uuid/uuid.dart';

//tạo model photos
class Photos {
  final int id;
  final String url;
  final int albumId;
  Photos({required this.id, required this.url, required this.albumId});

  factory Photos.create({required String url, required int albumId}) {
    return Photos(id: Uuid().v4().hashCode, url: url, albumId: albumId);
  }

  Photos copyWith({int? id, String? url, int? albumId}) {
    return Photos(
      id: id ?? this.id,
      url: url ?? this.url,
      albumId: albumId ?? this.albumId,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'url': url, 'albumId': albumId};
  }

  factory Photos.fromMap(Map<String, dynamic> map) {
    return Photos(
      id: map['id']?.toInt() ?? 0,
      url: map['url'] ?? '',
      albumId: map['albumId']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Photos.fromJson(String source) => Photos.fromMap(json.decode(source));

  @override
  String toString() => 'Photos(id: $id, url: $url, albumId: $albumId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Photos &&
        other.id == id &&
        other.url == url &&
        other.albumId == albumId;
  }

  @override
  int get hashCode => id.hashCode ^ url.hashCode ^ albumId.hashCode;
}

class Album {
  final int id;
  final String title;
  final String description;
  final String year;
  final List<Photos>? photos;

  Album({
    required this.id,
    required this.title,
    required this.description,
    required this.year,
    this.photos,
  });
  //create album
  factory Album.create({
    required String title,
    required String description,
    required String year,
  }) {
    return Album(
      id: Uuid().v4().hashCode,
      title: title,
      description: description,
      year: year,
      photos: [],
    );
  }

  Album copyWith({
    int? id,
    String? title,
    String? description,
    String? year,
    List<Photos>? photos,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      year: year ?? this.year,
      photos: photos ?? this.photos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'year': year,
      'photos': photos?.map((x) => x.toMap()).toList(),
    };
  }

  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      id: map['id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      year: map['year'] ?? '',
      photos:
          map['photos'] != null
              ? List<Photos>.from(map['photos']?.map((x) => Photos.fromMap(x)))
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Album.fromJson(String source) => Album.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Album(id: $id, title: $title, description: $description, year: $year)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Album &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.year == year;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ description.hashCode ^ year.hashCode;
  }
}
