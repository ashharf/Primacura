import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/constants.dart';
import '../models/medicine.dart';
import '../models/prescription.dart';
import '../models/units.dart';

class PrescriptionRemoteDataSource {
  final FirebaseFirestore firebaseFirestore;

  PrescriptionRemoteDataSource({required this.firebaseFirestore});

  Future<List<DosageUnit>> getDosages() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await firebaseFirestore.collection(AppConstants.dosagesCollection).get();
      final List<DosageUnit> dosages = querySnapshot.docs.map((doc) => DosageUnit.fromJson(doc.data())).toList();
      return dosages;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FrequencyUnit>> getFrequencies() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await firebaseFirestore.collection(AppConstants.frequencyCollection).orderBy('position').get();
      final List<FrequencyUnit> frequencies = querySnapshot.docs.map(
        (doc) {
          return FrequencyUnit.fromJson(doc.data());
        },
      ).toList();

      return frequencies;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DurationUnit>> getDurations() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await firebaseFirestore.collection(AppConstants.durationCollection).get();
      final List<DurationUnit> durations = querySnapshot.docs.map((doc) => DurationUnit.fromJson(doc.data())).toList();
      return durations;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Medicine>> getMedicinesFromFirestore() {
    try {
      return firebaseFirestore.collection(AppConstants.medicinesCollection).get().then((snapshot) {
        return snapshot.docs
            .map(
              (doc) => Medicine.fromJson(
                doc.data(),
              ),
            )
            .toList();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPrescriptionToFirestore(Prescription prescription) async {
    try {
      await firebaseFirestore.collection(AppConstants.prescriptionsCollection).doc(prescription.id).set(
            prescription.toJsonForRemoteDatabase(),
          );
    } catch (e) {
      rethrow;
    }
  }

  // Future<void> getMedicinesFromAssetsAndAddToFirestore() async {
  //   final String response = await rootBundle.loadString('assets/indian_medicines.json');
  //   final data = await json.decode(response);
  //   for (var medicineJson in data) {
  //     final medicine = Medicine(
  //       id: Uuid().v1(),
  //       brandName: medicineJson['brandName'],
  //       contains: List.generate(medicineJson['contains'].length, (index) => medicineJson['contains'][index]),
  //       genericName: medicineJson['genericName'],
  //       dosage: List.generate(medicineJson['dosage'].length, (index) => medicineJson['dosage'][index]),
  //       type: medicineJson['type'],
  //     );

  //     try {
  //       firebaseFirestore.collection("medicines").doc(medicine.id).set(medicine.toJson());
  //     } catch (e) {
  //       log(e.toString());
  //     }
  //   }
  // }
}
