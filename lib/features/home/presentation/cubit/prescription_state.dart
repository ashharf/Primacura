// part of 'prescription_cubit.dart';

// @immutable
// sealed class PrescriptionState {
//   final List<Prescription> allPrescriptions;
//   final List<Prescription> filteredPrescriptions;
//   final List<ChiefComplaint> chiefComplaints;
//   final List<Medicine> medicines;
//   final List<Medicine> searchedMedicines;
//   final String? message;

//   const PrescriptionState({
//     this.allPrescriptions = const [],
//     this.filteredPrescriptions = const [],
//     this.chiefComplaints = const [],
//     this.medicines = const [],
//     this.searchedMedicines = const [],
//     this.message,
//   });
// }

// final class PrescriptionInitial extends PrescriptionState {
//   const PrescriptionInitial(
//       {super.allPrescriptions,
//       super.filteredPrescriptions,
//       super.chiefComplaints,
//       super.medicines,
//       super.searchedMedicines,
//       super.message});
// }

// final class PrescriptionLoading extends PrescriptionState {
//   const PrescriptionLoading(
//       {super.allPrescriptions,
//       super.filteredPrescriptions,
//       super.chiefComplaints,
//       super.medicines,
//       super.searchedMedicines,
//       super.message});
// }

// final class PrescriptionLoaded extends PrescriptionState {
//   const PrescriptionLoaded(
//       {required super.allPrescriptions,
//       super.filteredPrescriptions,
//       super.chiefComplaints,
//       super.medicines,
//       super.searchedMedicines,
//       super.message});
// }

// final class PrescriptionError extends PrescriptionState {
//   const PrescriptionError(
//       {required super.allPrescriptions,
//       super.filteredPrescriptions,
//       super.chiefComplaints,
//       super.medicines,
//       super.searchedMedicines,
//       super.message});
// }

// final class PrescriptionAdded extends PrescriptionState {
//   const PrescriptionAdded(
//       {required super.allPrescriptions,
//       super.filteredPrescriptions,
//       super.chiefComplaints,
//       super.medicines,
//       super.searchedMedicines,
//       super.message});
// }

part of 'prescription_cubit.dart';
// import 'package:flutter/foundation.dart' show immutable;
// import 'package:opd_management/features/home/data/models/clinical_findings.dart';
// import 'package:opd_management/features/home/data/models/patient.dart';
// import 'package:opd_management/features/home/data/models/prescription_medicine.dart';
// import 'package:opd_management/features/home/data/models/symptomps.dart';
// import 'package:opd_management/features/home/data/models/units.dart';

// import '../../data/models/investigation.dart';
// import '../../data/models/prescription.dart';

@immutable
class PrescriptionState {
  final bool isLoading;
  final String? message;
  final Patient? patient;
  final List<Prescription> prescriptions;
  final List<Prescription> filteredPrescriptions;
  final List<Prescription> patientPrescriptions;
  final List<ChiefComplaint> chiefComplaints;
  final String? temperature;
  final String? bloodPressure;
  final String? spO2;
  final String? heartRate;
  final List<ClinicalFinding> clinicalFindings;
  final List<Investigation> investigations;
  final String? specialNote;
  // final Medicine? medicine;
  final List<PrescriptionMedicine> prescribedMedicines;
  // final PrescribedDosage? prescribedDosage;
  // final PrescribedFrequency? prescribedFrequency;
  // final PrescribedDuration? prescribedDuration;
  // final bool? isBeforeFood;
  final Prescription? prescription;

  const PrescriptionState({
    this.isLoading = false,
    this.message,
    this.patient,
    this.prescriptions = const [],
    this.filteredPrescriptions = const [],
    this.patientPrescriptions = const [],
    this.chiefComplaints = const [],
    this.temperature,
    this.bloodPressure,
    this.spO2,
    this.heartRate,
    this.clinicalFindings = const [],
    this.investigations = const [],
    this.specialNote,
    // this.medicine,
    this.prescribedMedicines = const [],
    //  this.prescribedDosage= const [],
    // required this.prescribedFrequency,
    // required this.prescribedDuration,
    // required this.isBeforeFood,
    this.prescription,
  });

  factory PrescriptionState.initial() {
    return PrescriptionState(
      isLoading: false,
      message: null,
      patient: null,
      prescriptions: [],
      filteredPrescriptions: [],
      patientPrescriptions: [],
      chiefComplaints: [],
      temperature: null,
      bloodPressure: null,
      spO2: null,
      heartRate: null,
      clinicalFindings: [],
      investigations: [],
      specialNote: null,
      // medicine: null,
      prescribedMedicines: [],
      // prescribedDosage: null,
      // prescribedFrequency: null,
      // prescribedDuration: null,
      // isBeforeFood: null,
      prescription: null,
    );
  }

  factory PrescriptionState.emptyPrescription(PrescriptionState state) {
    return PrescriptionState(
      isLoading: false,
      message: null,
      patient: null,
      prescriptions: state.prescriptions,
      filteredPrescriptions: state.filteredPrescriptions,
      patientPrescriptions: [],
      chiefComplaints: [],
      temperature: null,
      bloodPressure: null,
      spO2: null,
      heartRate: null,
      clinicalFindings: [],
      investigations: [],
      specialNote: null,
      // medicine: null,
      prescribedMedicines: [],
      // prescribedDosage: null,
      // prescribedFrequency: null,
      // prescribedDuration: null,
      // isBeforeFood: null,
      prescription: null,
    );
  }

  PrescriptionState emptyPatient(PrescriptionState state) {
    return PrescriptionState(
      isLoading: false,
      message: null,
      patient: null,
      prescriptions: state.prescriptions,
      filteredPrescriptions: state.filteredPrescriptions,
      patientPrescriptions: [],
      chiefComplaints: [],
      temperature: null,
      bloodPressure: null,
      spO2: null,
      heartRate: null,
      clinicalFindings: [],
      investigations: [],
      specialNote: null,
      // medicine: null,
      prescribedMedicines: [],

      // prescribedDosage: null,
      // prescribedFrequency: null,
      // prescribedDuration: null,
      // isBeforeFood: null,
      prescription: null,
    );
  }

  PrescriptionState copyWith({
    bool? isLoading,
    String? message,
    Patient? patient,
    List<Prescription>? prescriptions,
    List<Prescription>? filteredPrescriptions,
    List<Prescription>? patientPrescriptions,
    List<ChiefComplaint>? chiefComplaints,
    String? temperature,
    String? bloodPressure,
    String? spO2,
    String? heartRate,
    List<ClinicalFinding>? clinicalFindings,
    List<Investigation>? investigations,
    String? specialNote,
    List<PrescriptionMedicine>? prescribedMedicines,
    Prescription? prescription,
  }) {
    return PrescriptionState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      patient: patient ?? this.patient,
      prescriptions: prescriptions ?? this.prescriptions,
      filteredPrescriptions: filteredPrescriptions ?? this.filteredPrescriptions,
      patientPrescriptions: patientPrescriptions ?? this.patientPrescriptions,
      chiefComplaints: chiefComplaints ?? this.chiefComplaints,
      temperature: temperature ?? this.temperature,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      spO2: spO2 ?? this.spO2,
      heartRate: heartRate ?? this.heartRate,
      clinicalFindings: clinicalFindings ?? this.clinicalFindings,
      investigations: investigations ?? this.investigations,
      specialNote: specialNote ?? this.specialNote,
      prescribedMedicines: prescribedMedicines ?? this.prescribedMedicines,
      prescription: prescription ?? this.prescription,
    );
  }
// final class PrescriptionInitial extends PrescriptionState {
//   const PrescriptionInitial({
//     super.isLoading,
//     super.message,
//     super.patient,
//   });
// }

// final class PrescriptionLoaded extends PrescriptionState {

//   const PrescriptionLoaded({
//     super.isLoading,
//     super.message,
//     super.patient,
//     required this.prescriptions,
//     this.filteredPrescriptions = const [],
//   });
// }

// final class PrescriptionOnSelectPatientScreen extends PrescriptionState {

//   const PrescriptionOnSelectPatientScreen({
//     super.isLoading,
//     super.message,
//     super.patient,
//     this.patientPrescriptions = const [],
//   });
// }

// final class PrescriptionOnVitalsScreen extends PrescriptionState {

//   const PrescriptionOnVitalsScreen({
//     super.isLoading,
//     super.message,
//     required super.patient,
//     this.chiefComplaints = const [],
//     this.temperature,
//     this.bloodPressure,
//     this.spO2,
//     this.heartRate,
//     this.clinicalFindings = const [],
//     this.investigations = const [],
//     this.specialNote,
//   });
// }

// final class PrescriptionOnAddMedicineScreen extends PrescriptionState {

//   const PrescriptionOnAddMedicineScreen({
//     super.isLoading,
//     super.message,
//     required super.patient,
//     this.prescribedMedicines = const [],
//     this.prescribedDosage,
//     this.prescribedFrequency,
//     this.prescribedDuration,
//     this.isBeforeFood,
//   });
// }

// final class PrescriptionOnPrescriptionPreviewScreen extends PrescriptionState {

//   const PrescriptionOnPrescriptionPreviewScreen({
//     super.isLoading,
//     super.message,
//     required this.prescription,
//   });
}
