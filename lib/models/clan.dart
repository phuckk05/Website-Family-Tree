import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Generation {
  final int id;
  final String title;
  final String name;
  final String year;

  Generation({
    required this.id,
    required this.title,
    required this.name,
    required this.year,
  });

  factory Generation.create({
    required String title,
    required String name,
    required String year,
  }) {
    return Generation(
      id: Uuid().v4().hashCode,
      title: title,
      name: name,
      year: year,
    );
  }

  Generation copyWith({int? id, String? title, String? name, String? year}) {
    return Generation(
      id: id ?? this.id,
      title: title ?? this.title,
      name: name ?? this.name,
      year: year ?? this.year,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'name': name, 'year': year};
  }

  factory Generation.fromMap(Map<String, dynamic> map) {
    return Generation(
      id: map['id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      name: map['name'] ?? '',
      year: map['year'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Generation.fromJson(String source) =>
      Generation.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Generation(id: $id, title: $title, name: $name, year: $year)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Generation &&
        other.id == id &&
        other.title == title &&
        other.name == name &&
        other.year == year;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ name.hashCode ^ year.hashCode;
  }
}

class Story {
  final int id;
  final String duration;
  final String title;
  final String description;
  Story({
    required this.id,
    required this.duration,
    required this.title,
    required this.description,
  });
  factory Story.create({
    required String duration,
    required String title,
    required String description,
  }) {
    return Story(
      id: Uuid().v4().hashCode,
      duration: duration,
      title: title,
      description: description,
    );
  }

  Story copyWith({
    int? id,
    String? duration,
    String? title,
    String? description,
  }) {
    return Story(
      id: id ?? this.id,
      duration: duration ?? this.duration,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'duration': duration,
      'title': title,
      'description': description,
    };
  }

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      id: map['id']?.toInt() ?? 0,
      duration: map['duration'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Story.fromJson(String source) => Story.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Story(id: $id, duration: $duration, title: $title, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Story &&
        other.id == id &&
        other.duration == duration &&
        other.title == title &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        duration.hashCode ^
        title.hashCode ^
        description.hashCode;
  }
}

class Clan {
  final int id;
  final String name;
  final String chi;
  final String subNameUrl;
  //Cách trường mới thêm
  final String? address;
  final String? phone;
  final String? email;

  final String? slogan;

  final String? soucreSolgan;
  final String? soucreUrl;

  final List<Generation>? generations;
  final List<Story>? stories;

  final DateTime createdAt;
  Clan({
    required this.id,
    required this.name,
    required this.chi,
    required this.subNameUrl,
    required this.address,
    required this.phone,
    required this.email,
    required this.slogan,
    required this.soucreSolgan,
    required this.soucreUrl,
    required this.generations,
    required this.stories,
    required this.createdAt,
  });

  factory Clan.create({
    required String name,
    required String chi,
    required String subNameUrl,
    String? address,
    String? phone,
    String? email,
    String? slogan,
    String? soucreSolgan,
    String? soucreUrl,
    List<Generation>? generations,
    List<Story>? stories,
  }) {
    return Clan(
      id: Uuid().v4().hashCode,
      name: name,
      chi: chi,
      subNameUrl: subNameUrl,
      address: address ?? 'Chưa có địa chỉ',
      phone: phone ?? 'Chưa có số điện thoại',
      email: email ?? 'Chưa có email',
      slogan: slogan ?? 'Chưa có khẩu hiệu',
      soucreSolgan: soucreSolgan ?? 'Chưa có mô tả nguồn gốc',
      soucreUrl: soucreUrl ?? 'Chưa có ảnh',
      generations:
          generations ??
          [
            Generation(
              id: Uuid().v4().hashCode,
              title: 'Thế hệ 1-5',
              name: 'Tiền nhân',
              year: '1400-1600',
            ),
            Generation(
              id: Uuid().v4().hashCode,
              title: 'Chưa có tiêu đề',
              name: 'Chưa có tên',
              year: 'Chưa thời gian',
            ),
            Generation(
              id: Uuid().v4().hashCode,
              title: 'Chưa có tiêu đề',
              name: 'Chưa có tên',
              year: 'Chưa thời gian',
            ),
            Generation(
              id: Uuid().v4().hashCode,
              title: 'Chưa có tiêu đề',
              name: 'Chưa có tên',
              year: 'Chưa thời gian',
            ),
          ],
      stories:
          stories ??
          [
            Story(
              id: Uuid().v4().hashCode,
              duration: 'Chưa thời gian',
              title: 'Chưa có tiêu đề',
              description: 'Chưa có mô tả',
            ),
          ],
      createdAt: DateTime.now(),
    );
  }

  Clan copyWith({
    int? id,
    String? name,
    String? chi,
    String? subNameUrl,
    String? address,
    String? phone,
    String? email,
    String? slogan,
    String? soucreSolgan,
    String? soucreUrl,
    List<Generation>? generations,
    List<Story>? stories,
    DateTime? createdAt,
  }) {
    return Clan(
      id: id ?? this.id,
      name: name ?? this.name,
      chi: chi ?? this.chi,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      subNameUrl: subNameUrl ?? this.subNameUrl,
      slogan: slogan ?? this.slogan,
      soucreSolgan: soucreSolgan ?? this.soucreSolgan,
      soucreUrl: soucreUrl ?? this.soucreUrl,
      generations: generations ?? this.generations,
      stories: stories ?? this.stories,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'chi': chi,
      'subNameUrl': subNameUrl,
      'address': address,
      'phone': phone,
      'email': email,
      'slogan': slogan,
      'soucreSolgan': soucreSolgan,
      'soucreUrl': soucreUrl,
      'generations': generations?.map((x) => x.toMap()).toList(),
      'stories': stories?.map((x) => x.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Clan.fromMap(int? id, Map<String, dynamic> map) {
    return Clan(
      id: id ?? 0,
      name: map['name'] ?? '',
      chi: map['chi'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      subNameUrl: map['subNameUrl'] ?? '',
      slogan: map['slogan'] ?? '',
      soucreSolgan: map['soucreSolgan'] ?? '',
      soucreUrl: map['soucreUrl'] ?? '',
      generations: List<Generation>.from(
        map['generations']?.map((x) => Generation.fromMap(x)),
      ),
      stories: List<Story>.from(map['stories']?.map((x) => Story.fromMap(x))),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Clan.fromJson(String source) =>
      Clan.fromMap(null, json.decode(source));

  @override
  String toString() {
    return 'Clan(id: $id, name: $name, chi: $chi, subNameUrl: $subNameUrl, slogan: $slogan, soucreSolgan: $soucreSolgan, soucreUrl: $soucreUrl, generations: $generations, stories: $stories, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Clan &&
        other.id == id &&
        other.name == name &&
        other.chi == chi &&
        other.address == address &&
        other.phone == phone &&
        other.email == email &&
        other.subNameUrl == subNameUrl &&
        other.slogan == slogan &&
        other.soucreSolgan == soucreSolgan &&
        other.soucreUrl == soucreUrl &&
        listEquals(other.generations, generations) &&
        listEquals(other.stories, stories) &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        chi.hashCode ^
        subNameUrl.hashCode ^
        address.hashCode ^
        phone.hashCode ^
        email.hashCode ^
        slogan.hashCode ^
        soucreSolgan.hashCode ^
        soucreUrl.hashCode ^
        generations.hashCode ^
        stories.hashCode ^
        createdAt.hashCode;
  }
}
