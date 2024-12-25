import 'dart:typed_data';

import '../../../user/data/models/user.dart';
import 'clinical_findings.dart';
import 'investigation.dart';
import 'patient.dart';
import 'prescription_medicine.dart';
import 'symptomps.dart';

class Prescription {
  final String id;
  final Patient patient;
  final User? doctor;
  DateTime? dateTime;
  final List<ChiefComplaint> chiefComplaints;
  final List<ClinicalFinding> clinicalFindings;
  final List<Investigation> investigations;
  final String? temperature;
  final String? bloodPressure;
  final String? spO2;
  final String? heartRate;
  // final String? investigations;
  final List<PrescriptionMedicine> prescribedMedicines;
  final String? notes;
  Uint8List? qrData;

  Prescription(
      {required this.id,
      required this.patient,
      this.doctor,
      this.chiefComplaints = const [],
      this.temperature,
      this.bloodPressure,
      this.spO2,
      this.heartRate,
      this.clinicalFindings = const [],
      this.investigations = const [],
      this.dateTime,
      this.prescribedMedicines = const [],
      this.notes,
      this.qrData});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'patient': patient.toJson(),
      'doctor': doctor?.toJson(),
      'chiefComplaints': chiefComplaints.map((x) => x.toJson()).toList(),
      'temperature': temperature,
      'bloodPressure': bloodPressure,
      'spO2': spO2,
      'heartRate': heartRate,
      'clinicalFindings': clinicalFindings.map((x) => x.toJson()).toList(),
      'investigations': investigations.map((x) => x.toJson()).toList(),
      'prescribedMedicines': prescribedMedicines.map((x) => x.toJson()).toList(),
      'dateTime': dateTime?.toIso8601String(),
      'comment': notes,
      'qrData': qrData,
    };
  }

  Map<String, dynamic> toJsonForRemoteDatabase() {
    return <String, dynamic>{
      'id': id,
      'patient': patient.toJsonForRemoteDatabase(),
      'doctor': doctor?.toJsonForRemoteDatabase(),
      'chiefComplaints': chiefComplaints.map((x) => x.toJson()).toList(),
      'temperature': temperature,
      'bloodPressure': bloodPressure,
      'spO2': spO2,
      'heartRate': heartRate,
      'clinicalFindings': clinicalFindings.map((x) => x.toJson()).toList(),
      'investigations': investigations.map((x) => x.toJson()).toList(),
      'prescribedMedicines': prescribedMedicines.map((x) => x.toJson()).toList(),
      'dateTime': dateTime?.toIso8601String(),
      'comment': notes,
    };
  }

  factory Prescription.fromJson(Map<String, dynamic> map) {
    return Prescription(
      id: map['id'] as String,
      patient: Patient.fromJson(Map<String, dynamic>.from(map['patient'])),
      doctor: map['doctor'] != null ? User.fromJson(Map<String, dynamic>.from(map['doctor'])) : null,
      chiefComplaints: map['chiefComplaints'] == null
          ? []
          : List<ChiefComplaint>.from(
              (map['chiefComplaints'] as List<dynamic>).map<ChiefComplaint>(
                (x) => ChiefComplaint.fromJson(Map<String, dynamic>.from(x)),
              ),
            ),
      temperature: map['temperature'] != null ? map['temperature'] as String : null,
      bloodPressure: map['bloodPressure'] != null ? map['bloodPressure'] as String : null,
      spO2: map['spO2'] != null ? map['spO2'] as String : null,
      heartRate: map['heartRate'] != null ? map['heartRate'] as String : null,
      clinicalFindings: List<ClinicalFinding>.from(
        (map['clinicalFindings'] as List<dynamic>).map<ClinicalFinding>(
          (x) => ClinicalFinding.fromJson(Map<String, dynamic>.from(x)),
        ),
      ),
      investigations: List<Investigation>.from(
        (map['investigations'] as List<dynamic>).map<Investigation>(
          (x) => Investigation.fromJson(Map<String, dynamic>.from(x)),
        ),
      ),
      prescribedMedicines: List<PrescriptionMedicine>.from(
        (map['prescribedMedicines'] as List<dynamic>).map<PrescriptionMedicine>(
          (x) => PrescriptionMedicine.fromJson(Map<String, dynamic>.from(x)),
        ),
      ),
      notes: map['comment'] != null ? map['comment'] as String : null,
      dateTime: map['dateTime'] != null ? DateTime.parse(map['dateTime'] as String) : null,
      qrData: map['qrData'] != null ? Uint8List.fromList(List<int>.from(map['qrData'])) : null,
    );
  }
}
