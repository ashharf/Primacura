import '../../../../core/providers/loading_provider.dart';
import '../../data/models/patient.dart';
import '../../data/repository/patients_repository.dart';

class PatientsProvider extends LoadingProvider {
  final PatientRepository _patientRepository;

  PatientsProvider({required PatientRepository patientRepository}) : _patientRepository = patientRepository;

  final List<Patient> _patients = [];
  List<Patient> get patients => _patients;

  final List<Patient> _searchedPatients = [];
  List<Patient> get searchedPatients => _searchedPatients;

  final List<Patient> _patientsWithSameNumber = [];
  List<Patient> get patientsWithSameNumber => _patientsWithSameNumber;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  Future<void> getPatients() async {
    try {
      setLoading(true);
      final List<Patient> patients = await _patientRepository.getPatientsFromLocalData();
      _patients.clear();
      _patients.addAll(patients);
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> addPatient(Patient patient) async {
    setLoading(true);
    try {
      await _patientRepository.addPatientToLocalData(patient);
      _patients.add(patient);
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  void searchPatients(String query) {
    final patients = _patients;
    if (query.isEmpty) {
      _isSearching = false;
      _searchedPatients.clear();
      notifyListeners();
      return;
    }
    final searchResults = patients.where((patient) {
      return patient.name!.toLowerCase().contains(query) || patient.phoneNumber!.contains(query);
    }).toList();
    _isSearching = true;
    _searchedPatients.clear();
    _searchedPatients.addAll(searchResults);
    notifyListeners();
  }

  Future<void> updatePatient(Patient patient) async {
    setLoading(true);
    try {
      await _patientRepository.updatePatientInLocalData(patient);
      final index = _patients.indexWhere((element) => element.id == patient.id);
      _patients[index] = patient;
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> deletePatient(Patient patient) async {
    setLoading(true);
    try {
      await _patientRepository.deletePatientFromlocalData(patient);
      _patients.removeWhere((element) => element.id == patient.id);
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> checkIfPatientExistsWithNumber(String phoneNumber) async {
    try {
      setLoading(true);
      final patients = await _patientRepository.checkIfPatientExistsWithNumber(phoneNumber);
      _patientsWithSameNumber.clear();
      _patientsWithSameNumber.addAll(patients);
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  void clearPatientWithSameNumber() {
    _patientsWithSameNumber.clear();
  }

  // Future<void> takePatientBackup(Patient patient) async {
  //   try {
  //     emit(PatientLoading());
  //     await patientRepository.takepatientBackup(patient);
  //     emit(PatientActionSuccess(message: "Patient backup taken successfully"));
  //   } catch (e) {
  //     emit(PatientError(message: e.toString()));
  //   }
  // }
}
