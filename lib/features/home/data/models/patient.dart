enum Gender {
  male,
  female,
  other,
}

Gender getGenderByString(String gender) {
  switch (gender) {
    case 'male':
      return Gender.male;
    case 'female':
      return Gender.female;
    case 'other':
      return Gender.other;
    default:
      return Gender.other;
  }
}

class Patient {
  final String id;
  final String? name;
  final List<String> doctorId;
  final String? gender;
  final String? phoneNumber;
  final int? age;

  Patient({
    required this.id,
    this.name,
    this.doctorId = const [],
    this.gender,
    this.phoneNumber,
    this.age,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'doctorId': doctorId,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'age': age,
    };
  }

  Map<String, dynamic> toJsonForRemoteDatabase() {
    return <String, dynamic>{
      'id': id,
      'doctorId': doctorId,
      'gender': gender,
      'age': age,
    };
  }

  factory Patient.fromJson(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as String,
      name: map['name'] != null ? map['name'] as String : null,
      doctorId: (map['doctorId'] as List<dynamic>).map((e) => e as String).toList(),
      gender: map['gender'] != null ? map['gender'] as String : null,
      phoneNumber: map['phoneNumber'] as String?,
      age: map['age'] != null ? map['age'] as int : null,
    );
  }
}
