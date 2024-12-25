import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/utils.dart';
import '../../../patients/presentation/widget/custom_autocomplete.dart';
import '../../data/models/specialization.dart';
import '../providers/logo_and_signature_provider.dart';
import '../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static const String routeName = 'edit-profile';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _specializationController;
  late final TextEditingController _licenseNumberController;
  late final TextEditingController _clinicNameController;
  late final TextEditingController _clinicAddressController;
  late final TextEditingController _clinincTimingController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _degreeController;

  @override
  void initState() {
    final userProvider = context.read<UserProvider>();
    userProvider.getSpecializations();
    userProvider.addUserSpecializationToSelected();

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
    _clinincTimingController = TextEditingController(text: user.clinicTimings);
    _phoneNumberController = TextEditingController(text: user.phoneNumber);
    _degreeController = TextEditingController(text: user.degree);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LogoAndSignatureProvider>(
      create: (context) => LogoAndSignatureProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: ListView(
          padding: AppConstants.defaultPading,
          children: [
            Form(
              key: formKey,
              child: Consumer<UserProvider>(
                builder: (context, state, child) {
                  return Column(
                    children: [
                      TextFormField(
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
                            return 'Please enter your Name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
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
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _licenseNumberController,
                        decoration: const InputDecoration(
                          label: Text('License Number'),
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
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _clinicNameController,
                        decoration: const InputDecoration(
                          label: Text('Clinic Name'),
                          prefixIcon: Icon(
                            Icons.local_hospital,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _clinicAddressController,
                        keyboardType: TextInputType.streetAddress,
                        decoration: const InputDecoration(
                          label: Text('Clinic Address'),
                          prefixIcon: Icon(
                            FontAwesomeIcons.houseChimneyMedical,
                            size: 20,
                          ),
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _clinincTimingController,
                        decoration: const InputDecoration(
                          label: Text('Clinic Timings'),
                          prefixIcon: Icon(
                            FontAwesomeIcons.solidClock,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          label: Text('Phone Number'),
                          prefixIcon: Icon(
                            Icons.phone,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      CustomSearchableDropdown<Specialization>(
                        prefixIcon: Icon(
                          FontAwesomeIcons.userDoctor,
                          size: 20,
                        ),
                        hintText: "Search Specialization",
                        searchLogic: (searchQuery, items) {
                          final normalizedQuery = searchQuery.trim().toLowerCase();

                          // Separate exact matches and partial matches
                          final exactMatches = items.where((element) {
                            final normalizedBrandName = (element.name).trim().toLowerCase();
                            return normalizedBrandName == normalizedQuery;
                          }).toList();

                          final partialMatches = items.where((element) {
                            final normalizedBrandName = (element.name).trim().toLowerCase();
                            return normalizedBrandName.contains(normalizedQuery) &&
                                normalizedBrandName != normalizedQuery;
                          }).toList();

                          // Combine exact matches at the top, followed by partial matches
                          return [...exactMatches, ...partialMatches];
                        },
                        displayText: (item) => item.name,
                        textEditingController: _specializationController,
                        textCapitalization: TextCapitalization.words,
                        items: state.specializations,
                        onItemSelected: (item) {
                          // setState(() {
                          state.selectSpecialization(item, isProfileEditing: true);
                          Future.delayed(Duration(milliseconds: 100), () {
                            _specializationController.clear();
                          });
                          // });
                        },
                        onAddSelected: (searchText) {
                          final Specialization specialization = Specialization(
                            id: Uuid().v4(),
                            name: searchText,
                          );

                          state.addSpecialization(specialization);
                          state.selectSpecialization(specialization, isProfileEditing: true);
                          Future.delayed(Duration(milliseconds: 100), () {
                            _specializationController.clear();
                          });
                          // setState(() {});
                        },
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 10,
                          children: List.generate(
                            state.selectedSpecializations.length,
                            (index) => Chip(
                              backgroundColor: AppTheme.specializationChipColor,
                              label: Text(
                                state.selectedSpecializations[index].name,
                                style: TextStyle(color: Colors.white),
                              ),
                              onDeleted: () => state.deletedSelecteddSpecialization(
                                state.selectedSpecializations[index],
                                isEditingProfile: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // LogoAndSignature(),
            // SizedBox(height: 100),
            Consumer<UserProvider>(
              builder: (context, state, child) => ElevatedButton(
                // style: ElevatedButton.styleFrom(minimumSize: Size(300, 40)),
                onPressed: state.isLoading ? null : _onSave,
                child: state.isLoading ? CircularProgressIndicator() : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSave() async {
    if (formKey.currentState!.validate()) {
      final userProvider = context.read<UserProvider>();
      final user = userProvider.user;
      if (user == null) {
        Utils.showSnackBar(context, Text(AppConstants.pleaseTryLoggingInAgain));
        return;
      }
      final updatedUser = user.copyWith(
        specializations: userProvider.selectedSpecializations,
        licenseNumber: _licenseNumberController.text.trim(),
        clinicName: _clinicNameController.text.trim(),
        clinicAddress: _clinicAddressController.text.trim(),
        clinicTimings: _clinincTimingController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        degree: _degreeController.text.trim(),
        name: _nameController.text.trim(),
      );

      try {
        await userProvider.updateUser(updatedUser);
        if (!mounted) return;
        context.pop();
        Utils.showSnackBar(context, Text('Profile Updated Successfully'));
      } catch (e) {
        Utils.showSnackBar(context, Text(e.toString()));
      }
    }
  }
}
