import 'medicine.dart';
import 'units.dart';

class PrescriptionMedicine {
  final Medicine medicine;
  // final DosageUnit? dosage;
  final PrescriptionDosage? dosage;
  final PrescriptionFrequency? frequency;
  final PrescriptionDuration? duration;
  // final String? dosageString;
  // final FrequencyUnit frequency;
  // final DurationUnit? durationUnit;
  // final String? durationString;
  bool isAfterFood;
  bool isBeforeFood;
  bool isEmptyStomach;

  String? notes;

  PrescriptionMedicine({
    required this.medicine,
    this.dosage,
    this.frequency,
    this.duration,
    this.isAfterFood = false,
    this.isBeforeFood = false,
    this.isEmptyStomach = false,
    this.notes,
  });

  // Map<String, dynamic> toJson() {
  //   return <String, dynamic>{
  //     'medicine': medicine.toMap(),
  //     'dosage': dosage?.toJson(),
  //     'dosageString': dosageString,
  //     'frequency': frequency.toJson(),
  //     'duration': durationUnit?.toJson(),
  //     'durationString': durationString,
  //     'isBeforeFood': isBeforeFood,
  //   };
  // }

  Map<String, dynamic> toJson() {
    return {
      'medicine': medicine.toJson(),
      'dosage': dosage?.toJson(),
      'frequency': frequency?.toJson(),
      'duration': duration?.toJson(),
      'isAfterFood': isAfterFood,
      'isBeforeFood': isBeforeFood,
      'isEmptyStomach': isEmptyStomach,
      'notes': notes,
    };
  }

  // factory PrescriptionMedicine.fromJson(Map<String, dynamic> map) {
  //   return PrescriptionMedicine(
  //     medicine: Medicine.fromJson(Map<String, dynamic>.from(map['medicine'])),
  //     dosage: map['dosage'] != null ? DosageUnit.fromJson(Map<String, dynamic>.from(map['dosage'])) : null,
  //     dosageString: map['dosageString'] != null ? map['dosageString'] as String : null,
  //     // frequency: map['frequency'] != null ? MedFrequency.fromJson(Map<String, dynamic>.from(map['frequency'])) : null,
  //     frequency: FrequencyUnit.fromJson(Map<String, dynamic>.from(map['frequency'])),
  //     durationUnit: map['duration'] != null ? DurationUnit.fromJson(Map<String, dynamic>.from(map['duration'])) : null,
  //     durationString: map['durationString'] != null ? map['durationString'] as String : null,
  //     // dosage: map['dosage'] != null ? map['dosage'] as String : null,
  //     // frequency: map['frequency'] != null ? map['frequency'] as String : null,
  //     // duration: map['duration'] != null ? map['duration'] as String : null,
  //     isBeforeFood: map['isBeforeFood'] as bool,
  //   );
  // }

  factory PrescriptionMedicine.fromJson(Map<String, dynamic> map) {
    return PrescriptionMedicine(
      medicine: Medicine.fromJson((map['medicine'] as Map).map((key, value) => MapEntry(key as String, value))),
      dosage:
          map['dosage'] != null ? PrescriptionDosage.fromJson(Map<String, dynamic>.from(map['dosage'] as Map)) : null,
      frequency: map['frequency'] != null
          ? PrescriptionFrequency.fromJson(Map<String, dynamic>.from(map['frequency'] as Map))
          : null,
      duration: map['duration'] != null
          ? PrescriptionDuration.fromJson(Map<String, dynamic>.from(map['duration'] as Map))
          : null,
      isAfterFood: map['isAfterFood'] as bool? ?? false,
      isBeforeFood: map['isBeforeFood'] as bool? ?? false,
      isEmptyStomach: map['isEmptyStomach'] as bool? ?? false,
      notes: map['notes'] as String?,
    );
  }
}
