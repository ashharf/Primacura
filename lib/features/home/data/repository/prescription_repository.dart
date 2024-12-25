import '../data_source/prescription_local_data_source.dart';
import '../data_source/prescription_remote_data_source.dart';
import '../models/medicine.dart';
import '../models/prescription.dart';
import '../models/units.dart';

abstract class PrescriptionRepository {
  Future<List<Medicine>> getMedicinesFromRemoteDataSource();
  Future<List<DosageUnit>> getDosageFromRemoteDataSource();
  Future<List<FrequencyUnit>> getFrequencyFromRemoteDataSource();
  Future<List<DurationUnit>> getDurationFromRemoteDataSource();
  Future<DateTime> getDosageSyncTime();
  Future<DateTime> getFrequencySyncTime();
  Future<DateTime> getDurationSyncTime();
  Future<void> addPrescriptionToLocalData(Prescription prescription);
  Future<List<Prescription>> getPrescriptionsFromLocalData();
  Future<void> addPrescriptionToRemoteDatabase(Prescription prescription);
}

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final PrescriptionRemoteDataSource prescriptionRemoteDataSource;
  final PrescriptionLocalDataSource prescriptionLocalDataSource;

  PrescriptionRepositoryImpl({required this.prescriptionRemoteDataSource, required this.prescriptionLocalDataSource});

  @override
  Future<List<Medicine>> getMedicinesFromRemoteDataSource() async {
    try {
      // return prescriptionLocalDataSource.getMedicines();
      return prescriptionRemoteDataSource.getMedicines();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DosageUnit>> getDosageFromRemoteDataSource() async {
    try {
      return prescriptionRemoteDataSource.getDosages();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<FrequencyUnit>> getFrequencyFromRemoteDataSource() async {
    try {
      return prescriptionRemoteDataSource.getFrequencies();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DurationUnit>> getDurationFromRemoteDataSource() async {
    try {
      return prescriptionRemoteDataSource.getDurations();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DateTime> getDosageSyncTime() {
    try {
      return prescriptionLocalDataSource.getLastDosagesSyncTime();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DateTime> getDurationSyncTime() {
    try {
      return prescriptionLocalDataSource.getLastFrequenciesSyncTime();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DateTime> getFrequencySyncTime() {
    try {
      return prescriptionLocalDataSource.getLastDurationsSyncTime();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addPrescriptionToLocalData(Prescription prescription) async {
    try {
      return prescriptionLocalDataSource.addPrescription(prescription);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Prescription>> getPrescriptionsFromLocalData() async {
    try {
      return prescriptionLocalDataSource.getPrescriptions();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addPrescriptionToRemoteDatabase(Prescription prescription) async {
    try {
      return prescriptionRemoteDataSource.addPrescription(prescription);
    } catch (e) {
      rethrow;
    }
  }
}
