part of 'prescription_cubit.dart';

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
  final List<PrescriptionMedicine> prescribedMedicines;
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
    this.prescribedMedicines = const [],
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
      prescribedMedicines: [],
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
      prescribedMedicines: [],
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
      prescribedMedicines: [],
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
}
