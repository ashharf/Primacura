import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../home/data/models/clinical_findings.dart';
import '../../../home/data/models/investigation.dart';
import '../../../home/data/models/medicine.dart';
import '../../../home/data/models/symptomps.dart';
import '../../data/models/specialization.dart';
import '../../data/models/user.dart';
import '../../data/repository/user_repository.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository authRepository;
  UserCubit({required this.authRepository}) : super(UserInitial());

  final List<Specialization> specializations = [];
  final List<Specialization> selectedSpecializations = [];

  Future<void> signInWithGoogle() async {
    try {
      emit(UserLoading());
      final user = await authRepository.signInWithGoogle();

      if (user.licenseNumber == null) {
        emit(UserProfileNotCompleted(user: user));
        return;
      }
      emit(UserAuthenticated(user: user));
    } catch (e) {
      emit(UserAuthError(error: e.toString()));
    }
  }

  Future<void> updateUser(User user) async {
    emit(UserLoading());
    await authRepository.updateUser(user);
    emit(UserActionSuccess());
    emit(UserAuthenticated(user: user));
  }

  Future<void> signOut() async {
    // emit(UserLoading());
    await authRepository.signOut();
    emit(UserUnauthenticated());
  }

  Future<void> getUser() async {
    try {
      // emit(UserLoading());
      final user = await authRepository.getUser();
      emit(UserAuthenticated(user: user));
    } catch (e) {
      emit(UserError(user: (state as UserAuthenticated).user, error: e.toString()));
    }
  }

  Future<void> checkAuthState() async {
    final user = await authRepository.checkAuthState();

    if (user == null) {
      emit(UserUnauthenticated());
      return;
    }

    if (user.licenseNumber == null) {
      emit(UserProfileNotCompleted(user: user));
      return;
    }

    emit(UserAuthenticated(user: user));
    addUserSpecializationToSelected();
  }

  void addUserSpecializationToSelectedAtCompleteYourProfile() {
    selectedSpecializations.clear();
    selectedSpecializations.addAll((state as UserProfileNotCompleted).user.specializations);
  }

  void addUserSpecializationToSelected() {
    final userSpecializations = (state as UserAuthenticated).user.specializations;
    selectedSpecializations.clear();
    selectedSpecializations.addAll(userSpecializations.toList());
  }

  Future<void> addSpecialization(Specialization specialization) async {
    await authRepository.addSpecialization(specialization);
    specializations.add(specialization);
  }

  Future<void> getSpecializations() async {
    specializations.clear();
    specializations.addAll(await authRepository.getSpecializations());
  }

  void selectSpecialization(Specialization specialization, {bool isProfileEditing = false}) {
    final isSpecializationAlreadyAdded = selectedSpecializations.any((item) => item.id == specialization.id);
    if (isSpecializationAlreadyAdded) {
      if (isProfileEditing) {
        emit(UserError(user: (state as UserAuthenticated).user, error: "Specialization already selected"));
        emit(UserAuthenticated(user: (state as UserError).user));
      } else {
        emit(
          UserError(
            user: (state as UserProfileNotCompleted).user,
            error: "Specialization already selected",
          ),
        );
        emit(UserProfileNotCompleted(user: (state as UserError).user));
      }
      return;
    }
    selectedSpecializations.add(specialization);
    if (isProfileEditing) {
      emit(UserAuthenticated(user: (state as UserAuthenticated).user));
    } else {
      emit(UserProfileNotCompleted(user: (state as UserProfileNotCompleted).user));
    }
  }

  void deletedSelecteddSpecialization(Specialization specialization, {bool isEditingProfile = false}) {
    selectedSpecializations.remove(specialization);
    if (isEditingProfile) {
      emit(UserAuthenticated(user: (state as UserAuthenticated).user));
    } else {
      emit(UserProfileNotCompleted(user: (state as UserProfileNotCompleted).user));
    }
  }

  Future<void> addChiefComplaint(ChiefComplaint chiefComplaint) async {
    await authRepository.addChiefComplaint((state as UserAuthenticated).user.id, chiefComplaint);
    (state as UserAuthenticated).user.chiefComplaints.add(chiefComplaint);
  }

  Future<void> deleteChiefComplaint(ChiefComplaint chiefComplaint) async {
    await authRepository.deleteChiefComplaint((state as UserAuthenticated).user.id, chiefComplaint);
    (state as UserAuthenticated).user.chiefComplaints.remove(chiefComplaint);
  }

  Future<void> addClinicalFinding(ClinicalFinding clinicalFinding) async {
    await authRepository.addClinicalFinding((state as UserAuthenticated).user.id, clinicalFinding);
    (state as UserAuthenticated).user.clinicalFindings.add(clinicalFinding);
  }

  Future<void> deleteClinicalFinding(ClinicalFinding clinicalFinding) async {
    await authRepository.deleteClinicalFinding((state as UserAuthenticated).user.id, clinicalFinding);
    (state as UserAuthenticated).user.clinicalFindings.remove(clinicalFinding);
  }

  Future<void> addInvestigation(Investigation investigation) async {
    await authRepository.addInvestigation((state as UserAuthenticated).user.id, investigation);
    (state as UserAuthenticated).user.investigations.add(investigation);
  }

  Future<void> deleteInvestigation(Investigation investigation) async {
    await authRepository.deleteInvestigation((state as UserAuthenticated).user.id, investigation);
    (state as UserAuthenticated).user.investigations.remove(investigation);
  }

  Future<void> addMedicineToRemoteDatabase(Medicine medicine) async {
    await authRepository.addMedicineToRemoteDatabase(medicine);
  }

  Future<void> deleteMedicineFromRemoteDatabase(String medicineId) async {
    try {
      await authRepository.deleteMedicineFromRemoteDatabase(medicineId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createFileInGoogleDrive() async {
    try {
      await authRepository.createFileInGoogleDrive();
    } catch (e) {
      rethrow;
    }
  }
}
