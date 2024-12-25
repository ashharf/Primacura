
// ignore_for_file: public_member_api_docs, sort_constructors_first
class Investigation {
  final String id;
  final String name;

  Investigation({required this.id, required this.name});

  Investigation copyWith({
    String? id,
    String? name,
  }) {
    return Investigation(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory Investigation.fromJson(Map<String, dynamic> map) {
    return Investigation(
      id: map['id'] as String,
      name: map['name'],
    );
  }
}
