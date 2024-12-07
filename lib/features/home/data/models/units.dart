// ignore_for_file: public_member_api_docs, sort_constructors_first

class DosageUnit {
  final String id;
  final String name;

  DosageUnit({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory DosageUnit.fromJson(Map<String, dynamic> map) {
    return DosageUnit(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }

  // static List<Dosage> dosages = [
  //   Dosage(id: Uuid().v1(), name: "mg"),
  //   Dosage(id: Uuid().v1(), name: "g"),
  //   Dosage(id: Uuid().v1(), name: "µg"),
  //   Dosage(id: Uuid().v1(), name: "IU"),
  //   Dosage(id: Uuid().v1(), name: "%"),
  //   Dosage(id: Uuid().v1(), name: "Drops"),
  //   Dosage(id: Uuid().v1(), name: "Puffs"),
  //   Dosage(id: Uuid().v1(), name: "Tablets"),
  //   Dosage(id: Uuid().v1(), name: "Capsules"),
  //   Dosage(id: Uuid().v1(), name: "Teaspoon"),
  //   Dosage(id: Uuid().v1(), name: "Tablespoon"),
  // ];

  @override
  bool operator ==(covariant DosageUnit other) {
    if (identical(this, other)) return true;

    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class FrequencyUnit {
  final String id;
  final String name;
  final String? icon;

  FrequencyUnit({required this.id, required this.name, this.icon});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  factory FrequencyUnit.fromJson(Map<String, dynamic> map) {
    return FrequencyUnit(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String?,
    );
  }

  // static List<Frequency> frequencies = [
  //   Frequency(id: Uuid().v1(), name: "Once daily"),
  //   Frequency(id: Uuid().v1(), name: "Twice daily"),
  //   Frequency(id: Uuid().v1(), name: "Three times a day"),
  //   Frequency(id: Uuid().v1(), name: "Four times a day"),
  //   Frequency(id: Uuid().v1(), name: "As needed"),
  //   Frequency(id: Uuid().v1(), name: "Once weekly"),
  //   Frequency(id: Uuid().v1(), name: "Twice weekly"),
  //   Frequency(id: Uuid().v1(), name: "Every other day"),
  //   Frequency(id: Uuid().v1(), name: "In the morning"),
  //   Frequency(id: Uuid().v1(), name: "At bedtime"),
  // ];

  @override
  bool operator ==(covariant FrequencyUnit other) {
    if (identical(this, other)) return true;

    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class DurationUnit {
  final String id;
  final String name;

  DurationUnit({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory DurationUnit.fromJson(Map<String, dynamic> map) {
    return DurationUnit(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }
  // static List<Duration> durations = [
  //   Duration(id: Uuid().v1(), name: "Days"),
  //   Duration(id: Uuid().v1(), name: "Weeks"),
  //   Duration(id: Uuid().v1(), name: "Months"),
  // ];

  @override
  bool operator ==(covariant DurationUnit other) {
    if (identical(this, other)) return true;

    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class PrescriptionDosage {
  final String? text;
  final DosageUnit? dosageUnit;

  PrescriptionDosage({
    required this.text,
    required this.dosageUnit,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'text': text,
      'dosageUnit': dosageUnit?.toJson(),
    };
  }

  factory PrescriptionDosage.fromJson(Map<String, dynamic> map) {
    return PrescriptionDosage(
      text: map['text'] as String,
      dosageUnit: DosageUnit.fromJson(
        Map<String, dynamic>.from(map['dosageUnit'] as Map),
      ),
    );
  }
}

class PrescriptionFrequency {
  final String? text;
  final FrequencyUnit frequencyUnit;

  PrescriptionFrequency({
    required this.text,
    required this.frequencyUnit,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'text': text,
      'frequencyUnit': frequencyUnit.toJson(),
    };
  }

  factory PrescriptionFrequency.fromJson(Map<String, dynamic> map) {
    return PrescriptionFrequency(
        text: map['text'] != null ? map['text'] as String : null,
        frequencyUnit: FrequencyUnit.fromJson(Map<String, dynamic>.from(map['frequencyUnit'] as Map)));
  }
}

class PrescriptionDuration {
  final String text;
  final DurationUnit durationUnit;
  PrescriptionDuration({
    required this.text,
    required this.durationUnit,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'text': text,
      'durationUnit': durationUnit.toJson(),
    };
  }

  factory PrescriptionDuration.fromJson(Map<String, dynamic> map) {
    return PrescriptionDuration(
      text: map['text'] as String,
      durationUnit: DurationUnit.fromJson(
        Map<String, dynamic>.from(map['durationUnit'] as Map),
      ),
    );
  }
}
