import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../../../core/providers/loading_provider.dart';
import '../../../user/data/models/user.dart';
import '../../data/models/clinical_findings.dart';
import '../../data/models/investigation.dart';
import '../../data/models/medicine.dart';
import '../../../patients/data/models/patient.dart';
import '../../data/models/prescription.dart';
import '../../data/models/prescription_medicine.dart';
import '../../data/models/symptomps.dart';
import '../../data/models/units.dart';
import '../../data/repository/prescription_repository.dart';

class PrescriptionsProvider extends LoadingProvider {
  final PrescriptionRepository _prescriptionRepository;

  PrescriptionsProvider({required PrescriptionRepository prescriptionRepository})
      : _prescriptionRepository = prescriptionRepository;

  Patient? _patient;
  final List<Prescription> _prescriptions = [];
  final List<Prescription> _filteredPrescriptions = [];
  final List<Prescription> _patientPrescriptions = [];
  final List<ChiefComplaint> _chiefComplaints = [];
  String? _temperature;
  String? _bloodPressure;
  String? _spO2;
  String? _heartRate;
  final List<ClinicalFinding> _clinicalFindings = [];
  final List<Investigation> _investigations = [];
  String? _specialNote;
  final List<PrescriptionMedicine> _prescribedMedicines = [];
  Prescription? _prescription;

  final List<DosageUnit> _dosages = [];
  final List<DurationUnit> _durations = [];
  final List<FrequencyUnit> _frequencies = [];
  final List<Medicine> _medicines = [];
  DateTime _selectedDateToShowPrescriptions = DateTime.now();

  Patient? get patient => _patient;
  List<Prescription> get prescriptions => _prescriptions;
  List<Prescription> get filteredPrescriptions => _filteredPrescriptions;
  List<Prescription> get patientPrescriptions => _patientPrescriptions;
  List<ChiefComplaint> get chiefComplaints => _chiefComplaints;
  String? get temperature => _temperature;
  String? get bloodPressure => _bloodPressure;
  String? get spO2 => _spO2;
  String? get heartRate => _heartRate;
  List<ClinicalFinding> get clinicalFindings => _clinicalFindings;
  List<Investigation> get investigations => _investigations;
  String? get specialNote => _specialNote;
  List<PrescriptionMedicine> get prescribedMedicines => _prescribedMedicines;
  Prescription? get prescription => _prescription;

  List<DosageUnit> get dosages => _dosages;
  List<DurationUnit> get durations => _durations;
  List<FrequencyUnit> get frequencies => _frequencies;
  List<Medicine> get medicines => _medicines;
  DateTime get selectedDateToShowPrescriptions => _selectedDateToShowPrescriptions;

  void onSelectPatient(Patient patient) {
    _patient = patient;
    _patientPrescriptions.clear();
    _patientPrescriptions.addAll(
      _prescriptions.where(
        (prescription) => prescription.patient.id == patient.id,
      ),
    );
    notifyListeners();
  }

  void onDeleteSelectedPatient() {
    _patient = null;
    _patientPrescriptions.clear();
    notifyListeners();
  }

  void onCheifComplaintSelected(ChiefComplaint chiefComplaint) {
    _chiefComplaints.add(chiefComplaint);
    notifyListeners();
  }

  void addTemperature(String temperature) {
    _temperature = temperature;
    notifyListeners();
  }

  void addBloodPressure(String bloodPressure) {
    _bloodPressure = bloodPressure;
    notifyListeners();
  }

  void addSpO2(String spO2) {
    _spO2 = spO2;
    notifyListeners();
  }

  void addHeartRate(String heartRate) {
    _heartRate = heartRate;
    notifyListeners();
  }

  void addSpecialNote(String specialNote) {
    _specialNote = specialNote;
    notifyListeners();
  }

  void onChiefComplaintDeleted(ChiefComplaint chiefComplaint) {
    _chiefComplaints.remove(chiefComplaint);
    notifyListeners();
  }

  void onClinicalFindingSelected(ClinicalFinding clinicalFinding) {
    _clinicalFindings.add(clinicalFinding);
    notifyListeners();
  }

  void onClinicalFindingDeleted(ClinicalFinding clinicalFinding) {
    _clinicalFindings.remove(clinicalFinding);
    notifyListeners();
  }

  void onInvestigationSelected(Investigation investigation) {
    _investigations.add(investigation);
    notifyListeners();
  }

  void onInvestigationDeleted(Investigation investigation) {
    _investigations.remove(investigation);
    notifyListeners();
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
    _prescribedMedicines.add(prescriptionMedicine);
    notifyListeners();
  }

  void onMedicineDeleteForPrescription(PrescriptionMedicine prescriptionMedicine) {
    _prescribedMedicines.remove(prescriptionMedicine);
    notifyListeners();
  }

  Future<void> getPrescriptions() async {
    setLoading(true);
    try {
      final pres = await _prescriptionRepository.getPrescriptionsFromLocalData();
      _prescriptions.clear();
      _prescriptions.addAll(pres);

      _filteredPrescriptions.clear();
      _filteredPrescriptions.addAll(_prescriptions.where(
        (element) =>
            element.dateTime?.day == _selectedDateToShowPrescriptions.day &&
            element.dateTime?.month == _selectedDateToShowPrescriptions.month &&
            element.dateTime?.year == _selectedDateToShowPrescriptions.year,
      ));
      _filteredPrescriptions.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  void onMakePrescription({User? user, Uint8List? qrData}) {
    String prescriptionId = Uuid().v4();

    if (_prescription != null) {
      prescriptionId = _prescription!.id;
    }
    final Prescription prescription = Prescription(
      id: prescriptionId,
      doctor: user,
      patient: _patient!,
      qrData: qrData,
      notes: _specialNote,
      chiefComplaints: _chiefComplaints,
      clinicalFindings: _clinicalFindings,
      investigations: _investigations,
      prescribedMedicines: _prescribedMedicines,
      temperature: _temperature,
      bloodPressure: _bloodPressure,
      spO2: _spO2,
      heartRate: _heartRate,
      dateTime: DateTime.now(),
    );
    _prescription = prescription;
    notifyListeners();
  }

  Future<void> getMedicinesFromRemoteDataSource() async {
    final meds = await _prescriptionRepository.getMedicinesFromRemoteDataSource();
    _medicines.clear();
    _medicines.addAll(meds);
    notifyListeners();
  }

  Future<void> getUnits() async {
    try {
      _dosages.addAll(await _prescriptionRepository.getDosageFromRemoteDataSource());
      _frequencies.addAll(await _prescriptionRepository.getFrequencyFromRemoteDataSource());
      _durations.addAll(await _prescriptionRepository.getDurationFromRemoteDataSource());
    } catch (e) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> addPrescriptionToLocalStorage() async {
    setLoading(true);
    try {
      if (_prescription == null) {
        throw "Prescription is empty";
      }
      await _prescriptionRepository.addPrescriptionToLocalData(_prescription!);
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> addPrescriptionToRemoteDatabase() async {
    try {
      if (_prescription == null) {
        return;
      }
      await _prescriptionRepository.addPrescriptionToRemoteDatabase(_prescription!);
    } catch (e) {
      rethrow;
    }
  }

  void clearPatientAndPrescriptionDetails() {
    _patient = null;
    _patientPrescriptions.clear();
    _prescription = null;
    _chiefComplaints.clear();
    _clinicalFindings.clear();
    _investigations.clear();
    _prescribedMedicines.clear();
    _temperature = null;
    _bloodPressure = null;
    _spO2 = null;
    _heartRate = null;
    _specialNote = null;
    notifyListeners();
  }

  void onPrescriptionMedicineReorder(int oldIndex, int newIndex) {
    final PrescriptionMedicine medicine = _prescribedMedicines.removeAt(oldIndex);
    _prescribedMedicines.insert(newIndex, medicine);
    notifyListeners();
  }

  void onDateSelected(DateTime dateTime) {
    _selectedDateToShowPrescriptions = dateTime;
  }
}
