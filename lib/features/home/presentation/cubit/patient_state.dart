part of 'patient_cubit.dart';

@immutable
sealed class PatientState {
  final List<Patient> patients;
  final List<Patient> searchedPatients;
  final bool isSearching;
  final String? message;

  const PatientState(
      {this.patients = const [], this.searchedPatients = const [], this.isSearching = false, this.message});
}

final class PatientInitial extends PatientState {
  const PatientInitial({super.patients, super.searchedPatients, super.isSearching, super.message});
}

final class PatientLoading extends PatientState {
  const PatientLoading({super.patients, super.searchedPatients, super.isSearching, super.message});
}

final class PatientLoaded extends PatientState {
  const PatientLoaded({required super.patients, super.searchedPatients, super.isSearching, super.message});
}

final class PatientAdded extends PatientState {
  const PatientAdded({super.patients, super.searchedPatients, super.isSearching, super.message});
}

final class PatientActionSuccess extends PatientState {
  const PatientActionSuccess({super.patients, super.searchedPatients, super.isSearching, super.message});
}

final class PatientDeleted extends PatientState {
  const PatientDeleted({super.patients, super.searchedPatients, super.isSearching, super.message});
}

final class PatientError extends PatientState {
  const PatientError({super.patients, super.searchedPatients, super.isSearching, super.message});
}
