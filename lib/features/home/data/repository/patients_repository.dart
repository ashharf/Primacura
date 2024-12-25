import '../data_source/patient_local_data_source.dart';
import '../models/patient.dart';

abstract class PatientRepository {
  Future<List<Patient>> getPatientsFromLocalData();
  Future<void> addPatientToLocalData(Patient patient);
  Future<void> updatePatientInLocalData(Patient patient);
  Future<void> deletePatientFromlocalData(Patient patient);
  Future<List<Patient>> checkIfPatientExistsWithNumber(String phoneNumber);
}

class PatientRepositoryWithLocalDatabaseImpl implements PatientRepository {
  final PatientLocalDataSource patientLocalDataSource;

  PatientRepositoryWithLocalDatabaseImpl({required this.patientLocalDataSource});

  @override
  Future<List<Patient>> getPatientsFromLocalData() async {
    try {
      final patients = await patientLocalDataSource.getPatients();
      return patients;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addPatientToLocalData(Patient patient) async {
    try {
      await patientLocalDataSource.addPatient(patient);
      // await patientRemoteDataSource.addPatient(patient);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updatePatientInLocalData(Patient patient) async {
    try {
      await patientLocalDataSource.updatePatient(patient);
      // await patientRemoteDataSource.updatePatient(patient);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deletePatientFromlocalData(Patient patient) async {
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
}
