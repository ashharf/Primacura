import '../../../../core/providers/loading_provider.dart';
import '../../../../core/services/exception.dart';
import '../../../prescriptions/data/models/clinical_findings.dart';
import '../../../prescriptions/data/models/investigation.dart';
import '../../../prescriptions/data/models/medicine.dart';
import '../../../prescriptions/data/models/symptomps.dart';
import '../../data/models/specialization.dart';
import '../../data/models/user.dart';
import '../../data/repository/user_repository.dart';

class UserProvider extends LoadingProvider {
  final UserRepository _userRepository;

  UserProvider({required UserRepository userRepository}) : _userRepository = userRepository;

  User? _user;
  User? get user => _user;

  final List<Specialization> _specializations = [];
  List<Specialization> get specializations => _specializations;

  final List<Specialization> _selectedSpecializations = [];
  List<Specialization> get selectedSpecializations => _selectedSpecializations;

  Future<void> signInWithGoogle() async {
    try {
      setLoading(true);
      final user = await _userRepository.signInWithGoogle();
      _user = user;
    } catch (e) {
      throw UnknownErrorException(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateUser(User user) async {
    setLoading(true);
    try {
      await _userRepository.updateUser(user);
      _user = user;
    } catch (e) {
      throw UnknownErrorException();
    } finally {
      setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await _userRepository.signOut();
      _user = null;
    } catch (e) {
      throw UnknownErrorException();
    } finally {
      setLoading(false);
    }
  }

  Future<void> getUser() async {
    try {
      setLoading(true);
      _user = await _userRepository.getUser();
    } catch (e) {
      throw UnknownErrorException();
    } finally {
      setLoading(false);
    }
  }

  Future<void> checkAuthState() async {
    try {
      setLoading(true);
      _user = await _userRepository.checkAuthState();

      if (_user == null) {
        return;
      }
    } catch (e) {
      throw UnknownErrorException();
    } finally {
      setLoading(false);
    }
  }

  Future<void> addChiefComplaint(ChiefComplaint chiefComplaint) async {
    try {
      setLoading(true);
      if (user == null) {
        throw UnauthorisedException();
      }
      await _userRepository.addChiefComplaint(_user!.id, chiefComplaint);
    } catch (e) {
      throw UnknownErrorException();
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteChiefComplaint(ChiefComplaint chiefComplaint) async {
    try {
      setLoading(true);
      if (user == null) {
        throw UnauthorisedException();
      }
      await _userRepository.deleteChiefComplaint(_user!.id, chiefComplaint);
    } catch (e) {
      throw UnknownErrorException();
    } finally {
      setLoading(false);
    }
  }

  Future<void> addClinicalFinding(ClinicalFinding clinicalFinding) async {
    try {
      setLoading(true);
      if (user == null) {
        throw UnauthorisedException();
      }
      await _userRepository.addClinicalFinding(_user!.id, clinicalFinding);
    } catch (e) {
      throw UnknownErrorException();
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteClinicalFinding(ClinicalFinding clinicalFinding) async {
    try {
      setLoading(true);
      if (user == null) {
        throw UnauthorisedException();
      }
      await _userRepository.deleteClinicalFinding(_user!.id, clinicalFinding);
    } catch (e) {
      throw UnknownErrorException();
    } finally {
      setLoading(false);
    }
  }

  Future<void> addInvestigation(Investigation investigation) async {
    try {
      setLoading(true);
      if (user == null) {
        throw UnauthorisedException();
      }
      await _userRepository.addInvestigation(_user!.id, investigation);
    } catch (e) {
      throw UnknownErrorException();
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteInvestigation(Investigation investigation) async {
    try {
      setLoading(true);
      if (user == null) {
        throw UnauthorisedException();
      }
      await _userRepository.deleteInvestigation(_user!.id, investigation);
    } catch (e) {
      throw UnknownErrorException();
    } finally {
      setLoading(false);
    }
  }

  Future<void> addMedicineToRemoteDatabase(Medicine medicine) async {
    try {
      setLoading(true);
      await _userRepository.addMedicine(medicine);
    } catch (e) {
      throw UnknownErrorException();
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteMedicineFromRemoteDatabase(String medicineId) async {
    try {
      setLoading(true);
      await _userRepository.deleteMedicineFromRemoteDatabase(medicineId);
    } catch (e) {
      throw UnknownErrorException();
    } finally {
      setLoading(false);
    }
  }

  void addUserSpecializationToSelectedAtCompleteYourProfile() {
    if (_user == null) {
      throw UnauthorisedException();
    }
    _selectedSpecializations.clear();
    _selectedSpecializations.addAll(_user!.specializations);
  }

  void addUserSpecializationToSelected() {
    if (_user == null) {
      throw UnauthorisedException();
    }
    final userSpecializations = _user!.specializations;
    _selectedSpecializations.clear();
    _selectedSpecializations.addAll(userSpecializations.toList());
  }

  Future<void> addSpecialization(Specialization specialization) async {
    await _userRepository.addSpecialization(specialization);
    _specializations.add(specialization);
  }

  Future<void> getSpecializations() async {
    specializations.clear();
    specializations.addAll(await _userRepository.getSpecializations());
  }

  void selectSpecialization(Specialization specialization, {bool isProfileEditing = false}) {
    final isSpecializationAlreadyAdded = _selectedSpecializations.any((item) => item.id == specialization.id);
    if (isSpecializationAlreadyAdded) {
      if (isProfileEditing) {
        throw AppException("Specialization already selected");
      } else {
        throw AppException("User Profile not completed");
      }
    }
    _selectedSpecializations.add(specialization);
    notifyListeners();
  }

  void deletedSelecteddSpecialization(Specialization specialization, {bool isEditingProfile = false}) {
    selectedSpecializations.remove(specialization);
    notifyListeners();
  }
}
