import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/models/patient.dart';
import '../../data/repository/patients_repository.dart';

part 'patient_state.dart';

class PatientCubit extends Cubit<PatientState> {
  PatientCubit({required this.patientRepository}) : super(PatientInitial());
  final PatientRepository patientRepository;
  // bool isSearching = false;

  // final List<Patient> _cachedPatients = [];

  List<Patient> patientsWithSameNumber = [];

  Future<void> getPatients() async {
    try {
      emit(PatientLoading());
      final List<Patient> patients = await patientRepository.getPatients();
      // _cachedPatients.clear();
      // _cachedPatients.addAll(patients);
      emit(PatientLoaded(patients: patients));
    } catch (e) {
      emit(PatientError(message: e.toString()));
    }
  }

  Future<void> addPatient(Patient patient) async {
    try {
      emit(PatientLoading(patients: state.patients));
      await patientRepository.addPatient(patient);
      state.patients.add(patient);
      emit(PatientAdded(patients: state.patients));
      emit(PatientLoaded(patients: state.patients));
    } catch (e) {
      emit(PatientError(message: e.toString()));
    }
  }

  void searchPatients(String query) {
    final patients = state.patients;
    if (query.isEmpty) {
      emit(PatientLoaded(
        patients: state.patients,
        isSearching: false,
        searchedPatients: [],
      ));
      return;
    }
    final searchedPatients = patients.where((patient) {
      return patient.name!.toLowerCase().contains(query) || patient.phoneNumber!.contains(query);
    }).toList();
    emit(PatientLoaded(
      patients: patients,
      searchedPatients: searchedPatients,
      isSearching: true,
    ));
  }

  Future<void> updatePatient(Patient patient) async {
    try {
      final patients = (state as PatientLoaded).patients;
      emit(PatientLoading(patients: patients));
      await patientRepository.updatePatient(patient);
      patients.removeWhere((item) => item.id == patient.id);
      patients.add(patient);
      emit(PatientActionSuccess(message: "Patient updated successfully"));
      emit(PatientLoaded(patients: patients));
    } catch (e) {
      emit(PatientError(message: e.toString()));
    }
  }

  Future<void> deletePatient(Patient patient) async {
    try {
      final patients = (state as PatientLoaded).patients;
      emit(PatientLoading());
      await patientRepository.deletePatient(patient);
      patients.removeWhere((item) => item.id == patient.id);
      emit(PatientDeleted(
        message: "Patient deleted successfully",
        patients: state.patients,
      ));
      emit(PatientLoaded(patients: patients));
    } catch (e) {
      emit(PatientError(message: e.toString()));
    }
  }

  Future<void> checkIfPatientExistsWithNumber(String phoneNumber) async {
    try {
      patientsWithSameNumber.clear();
      patientsWithSameNumber = await patientRepository.checkIfPatientExistsWithNumber(phoneNumber);
      emit(PatientLoaded(patients: state.patients));
    } catch (e) {
      emit(PatientError(message: e.toString()));
    }
  }

  void clearPatientWithSameNumber() {
    patientsWithSameNumber.clear();
    emit(PatientLoaded(patients: state.patients));
  }

  Future<void> takePatientBackup(Patient patient) async {
    try {
      emit(PatientLoading());
      await patientRepository.takepatientBackup(patient);
      emit(PatientActionSuccess(message: "Patient backup taken successfully"));
    } catch (e) {
      emit(PatientError(message: e.toString()));
    }
  }
}
