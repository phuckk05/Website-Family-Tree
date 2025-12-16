import 'dart:convert';

import 'package:flutter/foundation.dart';
//thư viện tạo uid
import 'package:uuid/uuid.dart';

class Album {
  final int id;
  final String title;
  final String description;
  final String year;

  Album({
    required this.id,
    required this.title,
    required this.description,
    required this.year,
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
    );
  }

  Album copyWith({int? id, String? title, String? description, String? year}) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      year: year ?? this.year,
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'description': description, 'year': year};
  }

  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      id: map['id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      year: map['year'] ?? '',
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
