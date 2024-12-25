import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../models/patient.dart';

class PatientLocalDataSource {
  final Box hivePatientBox;

  PatientLocalDataSource({required this.hivePatientBox});

  Future<void> addPatient(Patient patient) async {
    try {
      await hivePatientBox.put(patient.id, patient.toJson());
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Patient>> getPatients() async {
    try {
      final patients = hivePatientBox
          .toMap()
          .values
          .map(
            (e) => Patient.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
      return patients;
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<Patient>> checkIfPatientExistsWithNumber(String phoneNumber) async {
    try {
      final patients = hivePatientBox
          .toMap()
          .values
          .map(
            (e) => Patient.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
      return patients.where((element) => element.phoneNumber == phoneNumber).toList();
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePatient(Patient patient) async {
    try {
      await hivePatientBox.delete(patient.id);
      await hivePatientBox.put(patient.id, patient.toJson());
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePatient(String patientId) async {
    try {
      await hivePatientBox.delete(patientId);
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }
}
