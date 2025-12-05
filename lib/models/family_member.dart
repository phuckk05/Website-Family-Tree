class FamilyMember {
  final String id;
  final String name;
  final String role;
  final String birthDate;
  final bool isMale;
  final int order;
  final List<FamilyMember> children;
  final List<String> spouses; // List of spouse names

  FamilyMember({
    required this.id,
    required this.name,
    required this.role,
    required this.birthDate,
    required this.isMale,
    this.order = 1,
    this.children = const [],
    this.spouses = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'birthDate': birthDate,
      'isMale': isMale,
      'order': order,
      'children': children.map((child) => child.toJson()).toList(),
      'spouses': spouses,
    };
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    var children =
        (json['children'] as List<dynamic>?)
            ?.map((child) => FamilyMember.fromJson(child))
            .toList() ??
        [];

    // Sort children by order
    children.sort((a, b) => a.order.compareTo(b.order));

    return FamilyMember(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      birthDate: json['birthDate'] ?? '',
      isMale: json['isMale'] ?? true,
      order: json['order'] ?? 1,
      children: children,
      spouses:
          (json['spouses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  FamilyMember copyWith({
    String? id,
    String? name,
    String? role,
    String? birthDate,
    bool? isMale,
    int? order,
    List<FamilyMember>? children,
    List<String>? spouses,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      birthDate: birthDate ?? this.birthDate,
      isMale: isMale ?? this.isMale,
      order: order ?? this.order,
      children: children ?? this.children,
      spouses: spouses ?? this.spouses,
    );
  }
}
