import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/services/http_service.dart';
import '../../../home/data/models/clinical_findings.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/constants.dart';
import '../../../home/data/models/investigation.dart';
import '../../../home/data/models/medicine.dart';
import '../../../home/data/models/symptomps.dart';

import '../models/specialization.dart';
import '../models/user.dart' as app;

class UserRemoteDataSource {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  UserRemoteDataSource({
    required this.googleSignIn,
    required this.firebaseAuth,
    required this.firebaseFirestore,
  });

  Future<app.User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
              // scopes: [
              //   'https://www.googleapis.com/auth/drive.file',
              // ],
              )
          .signIn();

      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleAuth == null) throw Exception('Account not selected');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCreds = await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCreds.user == null) throw Exception('Failed to sign in with Google');

      final existingUser = await checkIfUserExists(userCreds.user!.uid);
      if (existingUser != null) return existingUser;

      app.User user = app.User(
        id: userCreds.user!.uid,
        email: userCreds.user!.email!,
        name: userCreds.user!.displayName,
        accessToken: googleAuth.accessToken,
      );

      await firebaseFirestore
          .collection(AppConstants.userCollection)
          .doc(
            userCreds.user!.uid,
          )
          .set(
            user.toJson(),
          );

      return user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Failed to sign in with Google";
    } catch (e) {
      rethrow;
    }
  }

  Future<app.User> updateUser(app.User user) async {
    try {
      await firebaseFirestore
          .collection(AppConstants.userCollection)
          .doc(
            user.id,
          )
          .update(
            user.toJson(),
          );
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<app.User?> checkIfUserExists(String uid) async {
    try {
      final existingUser = await firebaseFirestore.collection(AppConstants.userCollection).doc(uid).get();
      if (existingUser.data() == null) return null;
      return app.User.fromJson(existingUser.data()!);
    } catch (e) {
      rethrow;
    }
  }

  Future<app.User> getUser() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      final existingUser = await firebaseFirestore.collection(AppConstants.userCollection).doc(currentUser!.uid).get();
      return app.User.fromJson(existingUser.data()!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      await firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<app.User?> checkAuthState() async {
    try {
      final currentUser = firebaseAuth.currentUser;

      if (currentUser == null) return null;
      final existingUser = await checkIfUserExists(currentUser.uid);
      return existingUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addSpecialization(Specialization specialization) async {
    try {
      return firebaseFirestore
          .collection(AppConstants.specializationCollection)
          .doc(
            specialization.id,
          )
          .set(
            specialization.toJson(),
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Specialization>> getSpecializations() async {
    try {
      final specialzations =
          await firebaseFirestore.collection(AppConstants.specializationCollection).get().then((snapshot) {
        return snapshot.docs
            .map(
              (doc) => Specialization.fromJson(
                doc.data(),
              ),
            )
            .toList();
      });

      return specialzations;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addSymptomp(ChiefComplaint symptomp, String userId) async {
    try {
      await firebaseFirestore.collection(AppConstants.userCollection).doc(userId).update(
        {
          "chiefComplaints": FieldValue.arrayUnion([symptomp.toJson()]),
        },
      );
    } on FirebaseException catch (e) {
      throw e.message ?? "Can't add symptomp to Database";
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChiefComplaint>> getChiefComplaints(String userId) async {
    try {
      final snapshot = await firebaseFirestore.collection(AppConstants.userCollection).doc(userId).get();
      final chiefComplaints = snapshot.data()?['chiefComplaints'] as List<dynamic>;
      return chiefComplaints.map((symptomp) => ChiefComplaint.fromJson(symptomp as Map<String, dynamic>)).toList();
    } on FirebaseException catch (e) {
      throw e.message ?? "Can't get chiefComplaints from Database";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteChiefComplaint(ChiefComplaint chiefComplaint, String userId) async {
    try {
      await firebaseFirestore.collection(AppConstants.userCollection).doc(userId).update(
        {
          "chiefComplaints": FieldValue.arrayRemove([chiefComplaint.toJson()]),
        },
      );
    } on FirebaseException catch (e) {
      throw e.message ?? "Can't delete chiefComplaint from Database";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addClinicalFinding(ClinicalFinding clinicalFinding, String userId) async {
    try {
      await firebaseFirestore.collection(AppConstants.userCollection).doc(userId).update(
        {
          "clinicalFindings": FieldValue.arrayUnion([clinicalFinding.toJson()]),
        },
      );
    } on FirebaseException catch (e) {
      throw e.message ?? "Can't add clinical finding to Database";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteClinicalFinding(ClinicalFinding clinicalFinding, String userId) async {
    try {
      await firebaseFirestore.collection(AppConstants.userCollection).doc(userId).update(
        {
          "clinicalFindings": FieldValue.arrayRemove([clinicalFinding.toJson()]),
        },
      );
    } on FirebaseException catch (e) {
      throw e.message ?? "Can't delete clinical finding from Database";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addInvestigation(Investigation investigation, String userId) async {
    try {
      await firebaseFirestore.collection(AppConstants.userCollection).doc(userId).update(
        {
          "investigations": FieldValue.arrayUnion([investigation.toJson()]),
        },
      );
    } on FirebaseException catch (e) {
      throw e.message ?? "Can't add investigation to Database";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteInvestigation(Investigation investigation, String userId) async {
    try {
      await firebaseFirestore.collection(AppConstants.userCollection).doc(userId).update(
        {
          "investigations": FieldValue.arrayRemove([investigation.toJson()]),
        },
      );
    } on FirebaseException catch (e) {
      throw e.message ?? "Can't delete investigation from Database";
    } catch (e) {
      rethrow;
    }
  }

  // Future<List<ClinicalFinding>> getClinicalFindings(String userId) async {
  //   try {
  //     final snapshot = await firebaseFirestore.collection(AppConstants.userCollection).doc(userId).get();
  //     final clinicalFindings = snapshot.data()?['clinicalFindings'] as List<dynamic>;
  //     return clinicalFindings
  //         .map((clinicalFinding) => ClinicalFinding.fromJson(clinicalFinding as Map<String, dynamic>))
  //         .toList();
  //   } on FirebaseException catch (e) {
  //     throw e.message ?? "Can't get clinical findings from Database";
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

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

  Future<void> addMedicineToFirestore(Medicine medicine) async {
    try {
      await firebaseFirestore.collection(AppConstants.medicinesCollection).doc(medicine.id).set(
            medicine.toJson(),
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMedicineFromFirestore(String medicineId) async {
    try {
      await firebaseFirestore.collection(AppConstants.medicinesCollection).doc(medicineId).delete();
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated('Use getMedicinesFromFirestore() instead')
  Future<void> getMedicinesFromJsonFileAndAddToFirestore() async {
    try {
      final medicines = await rootBundle.loadString('assets/indian_medicines.json');
      final medicinesList = jsonDecode(medicines) as List<dynamic>;
      for (var medicineData in medicinesList) {
        final Medicine medicine = Medicine(
          id: Uuid().v1(),
          brandName: medicineData['brandName'],
          genericName: medicineData['genericName'],
          contains: List.generate(
            medicineData['contains'].length,
            (index) => medicineData['contains'][index],
          ),
          dosage: List.generate(
            medicineData['dosage'].length,
            (index) => medicineData['dosage'][index],
          ),
          type: medicineData['type'],
        );
        await addMedicineToFirestore(medicine);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createFileInGoogleDrive(String accessToken) async {
    try {
      final response = await HttpService.get("https://www.googleapis.com/drive/v3/files", headers: {
        "Authorization": "Bearer $accessToken",
      });
      log(response.toString());
    } catch (e) {
      rethrow;
    }
  }
}
