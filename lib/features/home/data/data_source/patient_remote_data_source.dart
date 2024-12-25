import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/services/google_drive_service.dart';
import '../models/patient.dart';

class PatientRemoteDataSource {
  final FirebaseFirestore firebaseFirestore;
  final GoogleDriveService googleDriveService;

  PatientRemoteDataSource({required this.firebaseFirestore, required this.googleDriveService});

  Future<void> addPatient(Patient patient) async {
    try {
      await firebaseFirestore.collection(AppConstants.patientCollection).doc(patient.id).set(
            patient.toJsonForRemoteDatabase(),
          );
    } on FirebaseException catch (e) {
      throw e.message ?? "Failed to add patient";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePatient(Patient patient) async {
    try {
      await firebaseFirestore.collection(AppConstants.patientCollection).doc(patient.id).update(
            patient.toJsonForRemoteDatabase(),
          );
    } on FirebaseException catch (e) {
      throw e.message ?? "Failed to update patient";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePatient(Patient patient) async {
    try {
      await firebaseFirestore.collection(AppConstants.patientCollection).doc(patient.id).delete();
    } on FirebaseException catch (e) {
      throw e.message ?? "Failed to delete patient";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> takePatientBackup(Patient patient) async {
    try {
      final bool fileExists = await googleDriveService.checkIfFileExists(AppConstants.googleDrivePatientsFileName);
      if (fileExists) {
        final file = await googleDriveService.downloadFile(AppConstants.googleDrivePatientsFileName);
        log(file.toString());
      } else {
        await googleDriveService.uploadFile(
          AppConstants.googleDrivePatientsFileName,
          patient.toJson().toString(),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
