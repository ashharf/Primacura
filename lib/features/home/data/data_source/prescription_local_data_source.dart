import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:opd_management/features/home/data/models/prescription.dart';

import '../../../../core/constants/constants.dart';
import '../models/medicine.dart';
import '../models/units.dart';

class PrescriptionLocalDataSource {
  final Box hivePrescriptionBox;
  final Box hiveMedicineBox;
  final Box hiveDosageBox;
  final Box hiveFrequencyBox;
  final Box hiveDurationBox;
  final Box<String> hiveAccessTokenBox;

  PrescriptionLocalDataSource({
    required this.hivePrescriptionBox,
    required this.hiveMedicineBox,
    required this.hiveDosageBox,
    required this.hiveFrequencyBox,
    required this.hiveDurationBox,
    required this.hiveAccessTokenBox,
  });

  Future<List<Medicine>> getMedicines() async {
    try {
      return hiveMedicineBox
          .toMap()
          .values
          .map(
            (e) => Medicine.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addDosages(List<DosageUnit> dosages) async {
    try {
      await hiveDosageBox.put(
        AppConstants.dosagesCollection,
        dosages
            .map(
              (e) => e.toJson(),
            )
            .toList(),
      );
      await hiveDosageBox.put(
        "timestamp",
        DateTime.now().toIso8601String(),
      );
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addFrequencies(List<FrequencyUnit> frequencies) async {
    try {
      await hiveFrequencyBox.put(
        AppConstants.frequencyCollection,
        frequencies
            .map(
              (e) => e.toJson(),
            )
            .toList(),
      );
      await hiveFrequencyBox.put(
        "timestamp",
        DateTime.now().toIso8601String(),
      );
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addDurations(List<DurationUnit> durations) async {
    try {
      await hiveDurationBox.put(
        AppConstants.durationCollection,
        durations
            .map(
              (e) => e.toJson(),
            )
            .toList(),
      );
      await hiveDurationBox.put(
        "timestamp",
        DateTime.now().toIso8601String(),
      );
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DosageUnit>> getDosages() async {
    try {
      final dynamicData = hiveDosageBox.get(AppConstants.dosagesCollection);

      // Check if the data is null or empty, return an empty list if so
      if (dynamicData == null) {
        return [];
      }

      // Cast the dynamic data to a list of dynamic objects and map it to Dosage
      final List<dynamic> dynamicList = dynamicData as List<dynamic>;

      // Convert the dynamic list to List<Dosage> using fromJson
      return dynamicList.map((e) => DosageUnit.fromJson(Map<String, dynamic>.from(e))).toList();
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FrequencyUnit>> getFrequencies() async {
    try {
      final dynamicData = hiveFrequencyBox.get(AppConstants.frequencyCollection);

      // Check if the data is null or empty, return an empty list if so
      if (dynamicData == null) {
        return [];
      }

      // Cast the dynamic data to a list of dynamic objects and map it to Dosage
      final List<dynamic> dynamicList = dynamicData as List<dynamic>;

      // Convert the dynamic list to List<Dosage> using fromJson
      return dynamicList.map((e) => FrequencyUnit.fromJson(Map<String, dynamic>.from(e))).toList();
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DurationUnit>> getDurations() async {
    try {
      final dynamicData = hiveDurationBox.get(AppConstants.durationCollection);

      // Check if the data is null or empty, return an empty list if so
      if (dynamicData == null) {
        return [];
      }

      // Cast the dynamic data to a list of dynamic objects and map it to Dosage
      final List<dynamic> dynamicList = dynamicData as List<dynamic>;

      // Convert the dynamic list to List<Dosage> using fromJson
      return dynamicList.map((e) => DurationUnit.fromJson(Map<String, dynamic>.from(e))).toList();
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  Future<DateTime> getLastDosagesSyncTime() async {
    try {
      return DateTime.parse(hiveDosageBox.get(
        "timestamp",
      ));
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  Future<DateTime> getLastFrequenciesSyncTime() async {
    try {
      return DateTime.parse(hiveFrequencyBox.get("timestamp"));
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  Future<DateTime> getLastDurationsSyncTime() async {
    try {
      return DateTime.parse(hiveDurationBox.get(
        "timestamp",
      ));
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPrescription(Prescription prescription) async {
    try {
      log(prescription.toJson().toString());
      await hivePrescriptionBox.put(
        prescription.id,
        prescription.toJson(),
      );
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Prescription>> getPrescriptions() async {
    try {
      final data = hivePrescriptionBox
          .toMap()
          .values
          .map(
            (e) => Prescription.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();

      log(data.toString());
      return data;
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getAccessToken() async {
    try {
      final accessToken = hiveAccessTokenBox.get(
        "accessToken",
      );
      if (accessToken != null) {
        return accessToken;
      } else {
        throw "Access token not found";
      }
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      rethrow;
    }
  }
}
