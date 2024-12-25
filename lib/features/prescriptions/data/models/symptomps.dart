// ignore_for_file: public_member_api_docs, sort_constructors_first
class ChiefComplaint {
  final String id;
  final String name;

  ChiefComplaint({required this.id, required this.name});

  ChiefComplaint copyWith({
    String? id,
    String? name,
  }) {
    return ChiefComplaint(
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

  factory ChiefComplaint.fromJson(Map<String, dynamic> map) {
    return ChiefComplaint(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }
}
