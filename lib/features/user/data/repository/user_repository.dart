import '../../../prescriptions/data/models/clinical_findings.dart';
import '../../../prescriptions/data/models/investigation.dart';
import '../../../prescriptions/data/models/medicine.dart';
import '../../../prescriptions/data/models/symptomps.dart';
import '../data_source/user_local_data_source.dart';
import '../data_source/user_remote_data_source.dart';
import '../models/specialization.dart';
import '../models/user.dart';

abstract class UserRepository {
  Future<User> signInWithGoogle();
  Future<void> signOut();
  Future<User> updateUser(User user);
  Future<User?> checkAuthState();
  Future<void> addSpecialization(Specialization specialization);
  Future<List<Specialization>> getSpecializations();
  Future<User> getUser();
  Future<void> addChiefComplaint(String userId, ChiefComplaint symptomp);
  Future<void> deleteChiefComplaint(String userId, ChiefComplaint symptomp);
  Future<void> addClinicalFinding(String userId, ClinicalFinding clinicalFinding);
  Future<void> deleteClinicalFinding(String userId, ClinicalFinding clinicalFinding);
  Future<void> addInvestigation(String userId, Investigation investigation);
  Future<void> deleteInvestigation(String userId, Investigation investigation);
  Future<List<Medicine>> getMedicinesFromLocalDatabase();
  Future<List<Medicine>> getMedicinesFromRemoteDatabase();
  Future<void> addMedicineToRemoteDatabase(Medicine medicine);
  Future<void> deleteMedicineFromRemoteDatabase(String medicineId);
  Future<void> createFileInGoogleDrive();
}

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource userRemoteDataSource;
  final UserLocalDataSource userLocalDataSource;

  UserRepositoryImpl({
    required this.userRemoteDataSource,
    required this.userLocalDataSource,
  });
  @override
  Future<User> signInWithGoogle() async {
    try {
      final User user = await userRemoteDataSource.signInWithGoogle();
      if (user.accessToken != null) {
        userLocalDataSource.saveAccessToken(user.accessToken!);
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> updateUser(User user) {
    try {
      return userRemoteDataSource.updateUser(user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> checkAuthState() async {
    try {
      return userRemoteDataSource.checkAuthState();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() {
    try {
      return userRemoteDataSource.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addSpecialization(Specialization specialization) async {
    try {
      return userRemoteDataSource.addSpecialization(specialization);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Specialization>> getSpecializations() async {
    try {
      return await userRemoteDataSource.getSpecializations();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> getUser() {
    try {
      return userRemoteDataSource.getUser();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addChiefComplaint(String userId, ChiefComplaint symptomp) async {
    try {
      await userRemoteDataSource.addChiefComplaint(symptomp, userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Medicine>> getMedicinesFromRemoteDatabase() async {
    try {
      return await userRemoteDataSource.getMedicines();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Medicine>> getMedicinesFromLocalDatabase() async {
    try {
      return await userLocalDataSource.getMedicines();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addMedicineToRemoteDatabase(Medicine medicine) async {
    try {
      return userRemoteDataSource.addMedicine(medicine);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addClinicalFinding(String userId, ClinicalFinding clinicalFinding) {
    try {
      return userRemoteDataSource.addClinicalFinding(clinicalFinding, userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addInvestigation(String userId, Investigation investigation) {
    try {
      return userRemoteDataSource.addInvestigation(investigation, userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteMedicineFromRemoteDatabase(String medicineId) async {
    try {
      return userRemoteDataSource.deleteMedicine(medicineId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteClinicalFinding(String userId, ClinicalFinding clinicalFinding) async {
    try {
      return userRemoteDataSource.deleteClinicalFinding(clinicalFinding, userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteChiefComplaint(String userId, ChiefComplaint symptomp) {
    try {
      return userRemoteDataSource.deleteChiefComplaint(symptomp, userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteInvestigation(String userId, Investigation investigation) {
    try {
      return userRemoteDataSource.deleteInvestigation(investigation, userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createFileInGoogleDrive() async {
    try {
      final accessToken = await userLocalDataSource.getAccessToken();
      return userRemoteDataSource.createFileInGoogleDrive(accessToken);
    } catch (e) {
      rethrow;
    }
  }
}
