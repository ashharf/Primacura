import 'package:opd_management/features/home/data/models/prescription.dart';

import '../models/medicine.dart';

import '../data_source/prescription_local_data_source.dart';
import '../data_source/prescription_remote_data_source.dart';
import '../models/units.dart';

abstract class PrescriptionRepository {
  Future<List<Medicine>> getMedicinesFromRemoteDataSource();

  Future<List<DosageUnit>> getDosagesFromLocal();
  Future<List<DurationUnit>> getDurationsFromLocal();
  Future<List<FrequencyUnit>> getFrequenciesFromLocal();

  Future<void> addDosageFromRemoteToLocal();
  Future<void> addFrequencyFromRemoteToLocal();
  Future<void> addDurationFromRemoteToLocal();

  // Future<void> getDosageFromRemote();
  // Future<void> getFrequencyFromRemote();
  // Future<void> getDurationFromRemote();

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
  Future<List<DosageUnit>> getDosagesFromLocal() {
    try {
      return prescriptionLocalDataSource.getDosages();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<FrequencyUnit>> getFrequenciesFromLocal() {
    try {
      return prescriptionLocalDataSource.getFrequencies();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DurationUnit>> getDurationsFromLocal() {
    try {
      return prescriptionLocalDataSource.getDurations();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addDosageFromRemoteToLocal() async {
    try {
      final dosages = await prescriptionRemoteDataSource.getDosages();
      return prescriptionLocalDataSource.addDosages(dosages);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addFrequencyFromRemoteToLocal() async {
    try {
      final frequencies = await prescriptionRemoteDataSource.getFrequencies();
      return prescriptionLocalDataSource.addFrequencies(frequencies);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addDurationFromRemoteToLocal() async {
    try {
      final durations = await prescriptionRemoteDataSource.getDurations();
      return prescriptionLocalDataSource.addDurations(durations);
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
