
// ignore_for_file: public_member_api_docs, sort_constructors_first
class ClinicalFinding {
  final String id;
  final String name;

  ClinicalFinding({required this.id, required this.name});

  ClinicalFinding copyWith({
    String? id,
    String? name,
  }) {
    return ClinicalFinding(
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

  factory ClinicalFinding.fromJson(Map<String, dynamic> map) {
    return ClinicalFinding(
      id: map['id'] as String,
      name: map['name'],
    );
  }
}
