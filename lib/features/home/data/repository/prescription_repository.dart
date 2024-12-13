import 'package:opd_management/features/home/data/models/prescription.dart';

import '../models/medicine.dart';

import '../data_source/prescription_local_data_source.dart';
import '../data_source/prescription_remote_data_source.dart';
import '../models/units.dart';

abstract class PrescriptionRepository {
  Future<List<Medicine>> getMedicinesFromRemoteDataSource();

  Future<List<DosageUnit>> getDosageFromRemote();
  Future<List<FrequencyUnit>> getFrequencyFromRemote();
  Future<List<DurationUnit>> getDurationFromRemote();

  Future<DateTime> getDosageSyncTime();
  Future<DateTime> getFrequencySyncTime();
  Future<DateTime> getDurationSyncTime();

  Future<void> addPrescription(Prescription prescription);
  Future<List<Prescription>> getPrescriptions();
}

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final PrescriptionRemoteDataSource prescriptionRemoteDataSource;
  final PrescriptionLocalDataSource prescriptionLocalDataSource;

  PrescriptionRepositoryImpl({required this.prescriptionRemoteDataSource, required this.prescriptionLocalDataSource});

  @override
  Future<List<Medicine>> getMedicinesFromRemoteDataSource() async {
    try {
      // return prescriptionLocalDataSource.getMedicines();
      return prescriptionRemoteDataSource.getMedicinesFromFirestore();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DosageUnit>> getDosageFromRemote() async {
    try {
      return prescriptionRemoteDataSource.getDosages();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<FrequencyUnit>> getFrequencyFromRemote() async {
    try {
      return prescriptionRemoteDataSource.getFrequencies();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DurationUnit>> getDurationFromRemote() async {
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

  // @override
  // Future<void> getDosageFromRemote() {

  // }

  // @override
  // Future<void> getDurationFromRemote() {
  //   // TODO: implement getDurationFromRemote
  //   throw UnimplementedError();
  // }

  // @override
  // Future<void> getFrequencyFromRemote() {
  //   // TODO: implement getFrequencyFromRemote
  //   throw UnimplementedError();
  // }

  @override
  Future<void> addPrescription(Prescription prescription) async {
    try {
      return prescriptionLocalDataSource.addPrescription(prescription);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Prescription>> getPrescriptions() async {
    try {
      return prescriptionLocalDataSource.getPrescriptions();
    } catch (e) {
      rethrow;
    }
  }
}
