import '../data_source/patient_local_data_source.dart';
import '../data_source/patient_remote_data_source.dart';
import '../models/patient.dart';

abstract class PatientRepository {
  Future<List<Patient>> getPatients();
  Future<void> addPatient(Patient patient);
  Future<void> updatePatient(Patient patient);
  Future<void> deletePatient(Patient patient);
  Future<List<Patient>> checkIfPatientExistsWithNumber(String phoneNumber);
  Future<void> takepatientBackup(Patient patient);
}

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource patientRemoteDataSource;
  final PatientLocalDataSource patientLocalDataSource;

  PatientRepositoryImpl({required this.patientRemoteDataSource, required this.patientLocalDataSource});

  @override
  Future<List<Patient>> getPatients() async {
    try {
      final patients = await patientLocalDataSource.getPatients();
      return patients;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addPatient(Patient patient) async {
    try {
      await patientLocalDataSource.addPatient(patient);
      // await patientRemoteDataSource.addPatient(patient);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updatePatient(Patient patient) async {
    try {
      await patientLocalDataSource.updatePatient(patient);
      // await patientRemoteDataSource.updatePatient(patient);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deletePatient(Patient patient) async {
    try {
      await patientLocalDataSource.deletePatient(patient.id);
      // await patientRemoteDataSource.deletePatient(patient);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Patient>> checkIfPatientExistsWithNumber(String phoneNumber) {
    try {
      return patientLocalDataSource.checkIfPatientExistsWithNumber(phoneNumber);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> takepatientBackup(Patient patient) async {
    try {
      return patientRemoteDataSource.takePatientBackup(patient);
    } catch (e) {
      rethrow;
    }
  }
}
