import 'dart:developer';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:opd_management/features/home/data/models/investigation.dart';
import 'package:uuid/uuid.dart';
import '../../../user/data/models/user.dart';
import '../../data/models/clinical_findings.dart';
import '../../data/models/medicine.dart';
import '../../data/models/units.dart';
import '../../data/repository/prescription_repository.dart';
import '../../data/models/prescription.dart';
import '../../data/models/prescription_medicine.dart';
import '../../data/models/symptomps.dart';

import '../../data/models/patient.dart';

part 'prescription_state.dart';

class PrescriptionCubit extends Cubit<PrescriptionState> {
  PrescriptionCubit({required this.prescriptionRepository}) : super(PrescriptionState());

  final List<DosageUnit> dosages = [];
  final List<DurationUnit> durations = [];
  final List<FrequencyUnit> frequencies = [];
  final List<Medicine> medicines = [];
  DateTime selectedDateToShowPrescriptions = DateTime.now();

  final PrescriptionRepository prescriptionRepository;

  void onSelectPatient(Patient patient) {
    final patientPrescriptions =
        state.prescriptions.where((prescription) => prescription.patient.id == patient.id).toList();
    emit(
      state.copyWith(
        patient: patient,
        patientPrescriptions: patientPrescriptions,
      ),
    );
  }

  void onDeleteSelectedPatient() {
    emit(state.emptyPatient(state));
    log(state.patient.toString());
  }

  void onCheifComplaintSelected(ChiefComplaint chiefComplaint) {
    emit(
      state.copyWith(
        patient: state.patient,
        chiefComplaints: [...state.chiefComplaints, chiefComplaint],
      ),
    );
  }

  void addTemperature(String temperature) {
    emit(
      state.copyWith(
        temperature: temperature,
      ),
    );
  }

  void addBloodPressure(String bloodPressure) {
    emit(
      state.copyWith(
        bloodPressure: bloodPressure,
      ),
    );
  }

  void addSpO2(String spO2) {
    emit(
      state.copyWith(
        spO2: spO2,
      ),
    );
  }

  void addHeartRate(String heartRate) {
    emit(
      state.copyWith(
        heartRate: heartRate,
      ),
    );
  }

  void addSpecialNote(String specialNote) {
    emit(
      state.copyWith(
        specialNote: specialNote,
      ),
    );
  }

  void onChiefComplaintDeleted(ChiefComplaint chiefComplaint) {
    final chiefComplaints = state.chiefComplaints;
    chiefComplaints.remove(chiefComplaint);
    emit(state.copyWith(chiefComplaints: chiefComplaints));
  }

  void onClinicalFindingSelected(ClinicalFinding clinicalFinding) {
    emit(
      state.copyWith(
        clinicalFindings: [...state.clinicalFindings, clinicalFinding],
      ),
    );
  }

  void onClinicalFindingDeleted(ClinicalFinding clinicalFinding) {
    final clinicalFindings = state.clinicalFindings;
    clinicalFindings.remove(clinicalFinding);
    emit(state.copyWith(clinicalFindings: clinicalFindings));
  }

  void onInvestigationSelected(Investigation investigation) {
    emit(
      state.copyWith(
        investigations: [...state.investigations, investigation],
      ),
    );
  }

  void onInvestigationDeleted(Investigation investigation) {
    final investigations = state.investigations;
    investigations.remove(investigation);
    emit(state.copyWith(investigations: investigations));
  }

  void onMedicineAddForPrescription({
    required Medicine medicine,
    PrescriptionDosage? prescribedDosage,
    PrescriptionFrequency? prescribedFrequency,
    PrescriptionDuration? prescribedDuration,
    bool isAfterFood = false,
    bool isBeforeFood = false,
    bool isEmptyStomach = false,
    String? notes,
  }) {
    final PrescriptionMedicine prescriptionMedicine = PrescriptionMedicine(
        medicine: medicine,
        dosage: prescribedDosage,
        frequency: prescribedFrequency,
        duration: prescribedDuration,
        isAfterFood: isAfterFood,
        isBeforeFood: isBeforeFood,
        isEmptyStomach: isEmptyStomach,
        notes: notes);
    emit(
      state.copyWith(
        prescribedMedicines: [
          ...state.prescribedMedicines,
          prescriptionMedicine,
        ],
      ),
    );
  }

  void onMedicineDeleteForPrescription(PrescriptionMedicine prescriptionMedicine) {
    final prescribedMedicines = state.prescribedMedicines;
    prescribedMedicines.remove(prescriptionMedicine);
    emit(
      state.copyWith(
        prescribedMedicines: prescribedMedicines,
      ),
    );
  }

  Future<void> getPrescriptions() async {
    emit(
      state.copyWith(
        isLoading: true,
      ),
    );
    try {
      final pres = await prescriptionRepository.getPrescriptions();
      log(pres.length.toString());

      //     // selectedPatientPrescriptions.clear();
      emit(state.copyWith(prescriptions: pres));

      final List<Prescription> fPres = state.prescriptions
          .where(
            (element) =>
                element.dateTime?.day == selectedDateToShowPrescriptions.day &&
                element.dateTime?.month == selectedDateToShowPrescriptions.month &&
                element.dateTime?.year == selectedDateToShowPrescriptions.year,
          )
          .toList();
      fPres.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
      emit(state.copyWith(
        filteredPrescriptions: fPres,
        isLoading: false,
      ));
    } catch (e) {
      state.copyWith(message: e.toString());
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  void onMakePrescription({User? user, Uint8List? qrData}) {
    final Prescription prescription = Prescription(
      id: Uuid().v4(),
      doctor: user,
      patient: state.patient!,
      qrData: qrData,
      notes: state.specialNote,
      chiefComplaints: state.chiefComplaints,
      clinicalFindings: state.clinicalFindings,
      investigations: state.investigations,
      prescribedMedicines: state.prescribedMedicines,
      temperature: state.temperature,
      bloodPressure: state.bloodPressure,
      spO2: state.spO2,
      heartRate: state.heartRate,
      dateTime: DateTime.now(),
    );
    emit(
      state.copyWith(
        prescription: prescription,
        isLoading: false,
      ),
    );
  }

  Future<void> getMedicinesFromRemoteDataSource() async {
    final meds = await prescriptionRepository.getMedicinesFromRemoteDataSource();
    // for (var element in meds) {
    //   if (element.brandName == 'Test') {
    //     log(element.brandName);
    //   }
    // }
    medicines.clear();
    medicines.addAll(meds);
    emit(state.copyWith(isLoading: false));
  }

  Future<void> getUnits() async {
    // TODO make this sync from remote directly
    try {
      dosages.clear();
      frequencies.clear();
      durations.clear();
      dosages.addAll(await prescriptionRepository.getDosagesFromLocal());
      frequencies.addAll(await prescriptionRepository.getFrequenciesFromLocal());
      durations.addAll(await prescriptionRepository.getDurationsFromLocal());
      // frequencies.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> syncUnitsFromRemote() async {
    try {
      await prescriptionRepository.addDosageFromRemoteToLocal();
      await prescriptionRepository.addFrequencyFromRemoteToLocal();
      await prescriptionRepository.addDurationFromRemoteToLocal();

      // dosages.addAll(await prescriptionRepository.getDosagesFromLocal());
      // frequencies.addAll(await prescriptionRepository.getFrequenciesFromLocal());
      // durations.addAll(await prescriptionRepository.getDurationsFromLocal());
      getUnits();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> addPrescriptionToLocalStorage() async {
    emit(state.copyWith(isLoading: true));
    try {
      if (state.prescription == null) {
        emit(state.copyWith(message: "Prescription is empty"));
        return;
      }
      await prescriptionRepository.addPrescription(state.prescription!);
    } catch (e) {
      state.copyWith(message: "An error occured while saving prescription");
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  // void selectPatient(Patient patient) {
  //   emit(state.copyWith(patient: patient));
  // }

  void clearPatientAndPrescriptionDetails() {
    emit(PrescriptionState.emptyPrescription(state));
  }

  void onPrescriptionMedicineReorder(int oldIndex, int newIndex) {
    final List<PrescriptionMedicine> prescribedMedicines = state.prescribedMedicines;
    final PrescriptionMedicine medicine = prescribedMedicines.removeAt(oldIndex);
    prescribedMedicines.insert(newIndex, medicine);
    emit(state.copyWith(prescribedMedicines: prescribedMedicines));
  }
}
