import 'package:hive/hive.dart';
import '../../../home/data/models/medicine.dart';

class UserLocalDataSource {
  final Box<dynamic> hiveMedicinesBox;
  final Box<String> hiveAccessTokenBox;

  UserLocalDataSource({required this.hiveMedicinesBox, required this.hiveAccessTokenBox});

  Future<bool> hasMedicines() async {
    return hiveMedicinesBox.isNotEmpty;
  }

  Future<void> addMedicines(List<Medicine> medicines) async {
    await hiveMedicinesBox.addAll(medicines.map((e) => e.toJson()).toList());
  }

  Future<List<Medicine>> getMedicines() async {
    return hiveMedicinesBox
        .toMap()
        .values
        .map(
          (e) => Medicine.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  Future<void> saveAccessToken(String accessToken) async {
    try {
      await hiveAccessTokenBox.put('accessToken', accessToken);
    } catch (e) {
      throw Exception('App will not be able to take backup of your data due to local storage error');
    }
  }

  Future<String> getAccessToken() async {
    try {
      return hiveAccessTokenBox.get('accessToken') ?? '';
    } catch (e) {
      throw Exception('App will not be able to take backup of your data due to local storage error');
    }
  }
}
