class Medicine {
  final String id;
  final String brandName;
  final List<String> contains;
  final String? genericName;
  final List<String> dosage;
  final String? type;
  final String? userId;

  Medicine({
    required this.id,
    required this.brandName,
    this.contains = const [],
    this.genericName,
    this.dosage = const [],
    this.type,
    this.userId,
  });

  // Map<String, dynamic> toMap() {
  //   return <String, dynamic>{
  //     'id': id,
  //     'brandName': brandName,
  //     'contains': contains,
  //     'genericName': genericName,
  //     'dosage': dosage,
  //     'type': type,
  //   };
  // }

  factory Medicine.fromJson(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] as String,
      brandName: map['brandName'] as String,
      contains: List.generate(map['contains'].length, (index) => map['contains'][index]),
      genericName: map['genericName'] != null ? map['genericName'] as String : null,
      dosage: List.generate(map['dosage'].length, (index) => map['dosage'][index]),
      type: map['type'] != null ? map['type'] as String : null,
      userId: map['userId'] != null ? map['userId'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'brandName': brandName,
      'contains': contains,
      'genericName': genericName,
      'dosage': dosage,
      'type': type,
      'userId': userId,
    };
  }
}
