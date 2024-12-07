class Specialization {
  String id;
  String name;

  Specialization({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory Specialization.fromJson(Map<String, dynamic> map) {
    return Specialization(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }
}
