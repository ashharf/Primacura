import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/utils.dart';
import '../../../patients/presentation/widget/custom_autocomplete.dart';
import '../../../prescriptions/presentation/screens/home_screen.dart';
import '../../data/models/specialization.dart';
import '../providers/user_provider.dart';

class EnterUserDetailsScreen extends StatefulWidget {
  const EnterUserDetailsScreen({super.key});

  static const routeName = '/enter-user-details';

  @override
  State<EnterUserDetailsScreen> createState() => _EnterUserDetailsScreenState();
}

class _EnterUserDetailsScreenState extends State<EnterUserDetailsScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _specializationController;
  late final TextEditingController _licenseNumberController;
  late final TextEditingController _clinicNameController;
  late final TextEditingController _clinicAddressController;
  late final TextEditingController _clinicTimeController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _degreeController;

  @override
  void initState() {
    final userProvider = context.read<UserProvider>();
    userProvider.getSpecializations();
    userProvider.addUserSpecializationToSelectedAtCompleteYourProfile();

    final user = userProvider.user;

    if (user == null) {
      Utils.showSnackBar(context, Text(AppConstants.pleaseTryLoggingInAgain));
      return;
    }

    _nameController = TextEditingController(text: user.name);
    _specializationController = TextEditingController();
    _licenseNumberController = TextEditingController(text: user.licenseNumber);
    _clinicNameController = TextEditingController(text: user.clinicName);
    _clinicAddressController = TextEditingController(text: user.clinicAddress);
    _clinicTimeController = TextEditingController(text: user.clinicTimings);
    _phoneNumberController = TextEditingController(text: user.phoneNumber);
    _degreeController = TextEditingController(text: user.degree);

    super.initState();
  }

  @override
  void dispose() {
    formKey.currentState?.dispose();

    _nameController.dispose();
    _specializationController.dispose();
    _licenseNumberController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _clinicTimeController.dispose();
    _phoneNumberController.dispose();
    _degreeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete your Profile'),
      ),
      body: Form(
        key: formKey,
        child: Consumer<UserProvider>(
          builder: (context, state, child) {
            return ListView(
              padding: AppConstants.defaultPading,
              children: [
                const SizedBox(height: 20),
                _buildNameField(),
                const SizedBox(height: 20),
                _buildSpecializationField(state),
                const SizedBox(height: 10),
                _buildSpecializationChips(state),
                const SizedBox(height: 20),
                _buildDegreeField(),
                const SizedBox(height: 20),
                _buildLicenseNumberField(),
                const SizedBox(height: 20),
                _buildClinicNameField(),
                const SizedBox(height: 20),
                _buildClinicAddressField(),
                const SizedBox(height: 20),
                _buildClinicTimeField(),
                const SizedBox(height: 20),
                _buildPhoneNumberField(),
                const SizedBox(height: 20),
                _buildSaveButton(state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Name',
        prefixIcon: Icon(
          FontAwesomeIcons.stethoscope,
          size: 20,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your Name. It will appear on Prescriptions';
        }
        return null;
      },
    );
  }

  Widget _buildSpecializationField(UserProvider state) {
    return CustomSearchableDropdown<Specialization>(
      prefixIcon: Icon(
        FontAwesomeIcons.userDoctor,
        size: 20,
      ),
      hintText: "Search Specialization",
      searchLogic: _searchLogic,
      displayText: (item) => item.name,
      textEditingController: _specializationController,
      textCapitalization: TextCapitalization.words,
      items: state.specializations,
      onItemSelected: (item) {
        state.selectSpecialization(item);
        Future.delayed(Duration(milliseconds: 100), () {
          _specializationController.clear();
        });
      },
      onAddSelected: (searchText) {
        final Specialization specialization = Specialization(
          id: Uuid().v4(),
          name: searchText,
        );

        state.addSpecialization(specialization);
        state.selectSpecialization(specialization);
        Future.delayed(Duration(milliseconds: 100), () {
          _specializationController.clear();
        });
      },
    );
  }

  Widget _buildSpecializationChips(UserProvider state) {
    return Wrap(
      spacing: 10,
      children: List.generate(
        state.selectedSpecializations.length,
        (index) => Chip(
          backgroundColor: AppTheme.specializationChipColor,
          label: Text(
            state.selectedSpecializations[index].name,
            style: TextStyle(color: Colors.white),
          ),
          onDeleted: () => state.deletedSelecteddSpecialization(state.selectedSpecializations[index]),
        ),
      ),
    );
  }

  Widget _buildDegreeField() {
    return TextFormField(
      controller: _degreeController,
      decoration: const InputDecoration(
        labelText: 'Degree',
        prefixIcon: Icon(
          FontAwesomeIcons.graduationCap,
          size: 20,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your degree. It will appear on Prescriptions';
        }
        return null;
      },
    );
  }

  Widget _buildLicenseNumberField() {
    return TextFormField(
      controller: _licenseNumberController,
      decoration: const InputDecoration(
        labelText: 'License Number',
        prefixIcon: Icon(
          FontAwesomeIcons.idCard,
          size: 20,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your license number. It will appear on Prescriptions';
        }
        return null;
      },
    );
  }

  Widget _buildClinicNameField() {
    return TextFormField(
      controller: _clinicNameController,
      decoration: const InputDecoration(
        labelText: 'Clinic Name',
        prefixIcon: Icon(
          Icons.local_hospital,
        ),
      ),
    );
  }

  Widget _buildClinicAddressField() {
    return TextFormField(
      controller: _clinicAddressController,
      decoration: const InputDecoration(
        labelText: 'Clinic Address',
        prefixIcon: Icon(
          FontAwesomeIcons.houseChimneyMedical,
          size: 20,
        ),
      ),
      maxLines: 2,
    );
  }

  Widget _buildClinicTimeField() {
    return TextFormField(
      controller: _clinicTimeController,
      decoration: const InputDecoration(
        labelText: 'Clinic Timings',
        prefixIcon: Icon(
          FontAwesomeIcons.solidClock,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      controller: _phoneNumberController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        prefixIcon: Icon(Icons.phone),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton(UserProvider userProvider) {
    return ElevatedButton(
      onPressed: userProvider.isLoading ? null : _save,
      child: userProvider.isLoading ? CircularProgressIndicator() : const Text('Save'),
    );
  }

  List<Specialization> _searchLogic(String searchQuery, Iterable<Specialization> items) {
    final normalizedQuery = searchQuery.trim().toLowerCase();

    final exactMatches = items.where((element) {
      final normalizedBrandName = (element.name).trim().toLowerCase();
      return normalizedBrandName == normalizedQuery;
    }).toList();

    final partialMatches = items.where((element) {
      final normalizedBrandName = (element.name).trim().toLowerCase();
      return normalizedBrandName.contains(normalizedQuery) && normalizedBrandName != normalizedQuery;
    }).toList();

    return [...exactMatches, ...partialMatches];
  }

  Future<void> _save() async {
    final userProvider = context.read<UserProvider>();
    if (formKey.currentState!.validate()) {
      final licenseNumber = _licenseNumberController.text.trim();
      final clinicName = _clinicNameController.text.trim();
      final clinicAddress = _clinicAddressController.text.trim();
      final clinicTime = _clinicTimeController.text.trim();
      final phoneNumber = _phoneNumberController.text.trim();
      final degree = _degreeController.text.trim();
      final user = userProvider.user;
      if (user == null) {
        Utils.showSnackBar(context, Text(AppConstants.pleaseTryLoggingInAgain));
        return;
      }
      final updatedUser = user.copyWith(
        licenseNumber: licenseNumber,
        clinicName: clinicName,
        clinicAddress: clinicAddress,
        clinicTimings: clinicTime,
        phoneNumber: phoneNumber,
        specializations: userProvider.selectedSpecializations,
        degree: degree,
      );
      try {
        await userProvider.updateUser(updatedUser);
        if (mounted) {
          context.go(HomeScreen.routeName);
        }
      } catch (e) {
        if (mounted) {
          Utils.showSnackBar(context, Text(e.toString()));
        }
      }
    }
  }
}
