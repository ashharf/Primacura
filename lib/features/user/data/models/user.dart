// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../../prescriptions/data/models/clinical_findings.dart';
import '../../../prescriptions/data/models/investigation.dart';
import '../../../prescriptions/data/models/medicine.dart';
import '../../../prescriptions/data/models/symptomps.dart';
import 'specialization.dart';

class User {
  final String id;
  final String email;
  final String? name;
  final String? uniqueId;
  final List<Specialization> specializations;
  final String? degree;
  final String? licenseNumber;
  final String? clinicName;
  final String? clinicAddress;
  final String? clinicTimings;
  final String? phoneNumber;
  final List<ChiefComplaint> chiefComplaints;
  final List<ClinicalFinding> clinicalFindings;
  final List<Investigation> investigations;
  final List<Medicine> medicines;
  final String? logoUrl;
  final String? signatureUrl;
  String? token;

  User({
    required this.id,
    required this.email,
    this.uniqueId,
    this.name,
    this.specializations = const [],
    this.degree,
    this.clinicName,
    this.clinicAddress,
    this.clinicTimings,
    this.licenseNumber,
    this.phoneNumber,
    this.chiefComplaints = const [],
    this.clinicalFindings = const [],
    this.investigations = const [],
    this.medicines = const [],
    this.logoUrl,
    this.signatureUrl,
    this.token,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'uniqueId': uniqueId,
      'username': name,
      'speciality': specializations.map((e) => e.toJson()).toList(),
      'degree': degree,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'clinicTimings': clinicTimings,
      'phoneNumber': phoneNumber,
      'licenseNumber': licenseNumber,
      'chiefComplaints': chiefComplaints.map((e) => e.toJson()).toList(),
      'clinicalFindings': clinicalFindings.map((e) => e.toJson()).toList(),
      'investigations': investigations.map((e) => e.toJson()).toList(),
      'medicines': medicines.map((e) => e.toJson()).toList(),
      'logoUrl': logoUrl,
      'signatureUrl': signatureUrl,
    };
  }

  Map<String, dynamic> toJsonForRemoteDatabase() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'uniqueId': uniqueId,
      'username': name,
      'speciality': specializations.map((e) => e.toJson()).toList(),
      'degree': degree,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'clinicTimings': clinicTimings,
      'phoneNumber': phoneNumber,
      'licenseNumber': licenseNumber,
    };
  }

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(),
      email: map['email'] as String,
      uniqueId: map['uniqueId'],
      name: map['username'] != null ? map['username'] as String : null,
      specializations: map['speciality'] == null
          ? []
          : (map['speciality'] as List<dynamic>)
              .map((e) => Specialization.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
      degree: map['degree'],
      licenseNumber: map['licenseNumber'],
      clinicName: map['clinicName'],
      clinicAddress: map['clinicAddress'],
      clinicTimings: map['clinicTimings'],
      phoneNumber: map['phoneNumber'],
      chiefComplaints: map['chiefComplaints'] == null
          ? []
          : (map['chiefComplaints'] as List<dynamic>)
              .map(
                (e) => ChiefComplaint.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList(),
      clinicalFindings: map['clinicalFindings'] == null
          ? []
          : (map['clinicalFindings'] as List<dynamic>)
              .map(
                (e) => ClinicalFinding.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList(),
      investigations: map['investigations'] == null
          ? []
          : (map['investigations'] as List<dynamic>)
              .map(
                (e) => Investigation.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList(),
      medicines: map['medicines'] == null
          ? []
          : (map['medicines'] as List<dynamic>)
              .map(
                (e) => Medicine.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? uniqueId,
    String? name,
    List<Specialization>? specializations,
    String? degree,
    String? licenseNumber,
    String? clinicName,
    String? clinicAddress,
    String? clinicTimings,
    String? phoneNumber,
    List<ChiefComplaint>? chiefComplaints,
    List<ClinicalFinding>? clinicalFindings,
    List<Medicine>? medicines,
    String? logoUrl,
    String? signatureUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      uniqueId: uniqueId ?? this.uniqueId,
      name: name ?? this.name,
      specializations: specializations ?? this.specializations,
      degree: degree ?? this.degree,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      clinicTimings: clinicTimings ?? this.clinicTimings,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      chiefComplaints: chiefComplaints ?? this.chiefComplaints,
      clinicalFindings: clinicalFindings ?? this.clinicalFindings,
      medicines: medicines ?? this.medicines,
      logoUrl: logoUrl ?? this.logoUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
    );
  }
}
