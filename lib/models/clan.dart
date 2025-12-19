import 'dart:convert';

import 'package:uuid/uuid.dart';

class Clan {
  final int id;
  final String name;
  final String chi;
  final String subNameUrl;
  final DateTime createdAt;
  Clan({
    required this.id,
    required this.name,
    required this.chi,
    required this.subNameUrl,
    required this.createdAt,
  });

  factory Clan.create({
    required String name,
    required String chi,
    required String subNameUrl,
  }) {
    return Clan(
      id: Uuid().v4().hashCode,
      name: name,
      chi: chi,
      subNameUrl: subNameUrl,
      createdAt: DateTime.now(),
    );
  }

  Clan copyWith({
    int? id,
    String? name,
    String? chi,
    String? subNameUrl,
    DateTime? createdAt,
  }) {
    return Clan(
      id: id ?? this.id,
      name: name ?? this.name,
      chi: chi ?? this.chi,
      subNameUrl: subNameUrl ?? this.subNameUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'chi': chi,
      'subNameUrl': subNameUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Clan.fromMap(int? id, Map<String, dynamic> map) {
    return Clan(
      id: id ?? 0,
      name: map['name'] ?? '',
      chi: map['chi'] ?? '',
      subNameUrl: map['subNameUrl'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Clan.fromJson(String source) =>
      Clan.fromMap(null, json.decode(source));

  @override
  String toString() {
    return 'Clan(id: $id, name: $name, chi: $chi, subNameUrl: $subNameUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Clan &&
        other.id == id &&
        other.name == name &&
        other.chi == chi &&
        other.subNameUrl == subNameUrl &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        chi.hashCode ^
        subNameUrl.hashCode ^
        createdAt.hashCode;
  }
}
