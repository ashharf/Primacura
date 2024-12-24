import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:opd_management/features/home/presentation/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/utils.dart';
import '../../../home/presentation/widget/custom_autocomplete.dart';
import '../../data/models/specialization.dart';
import '../provider/user_provider.dart';

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
                      return 'Please enter your Name. It will appear on Prescriptions';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomSearchableDropdown<Specialization>(
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
                    // setState(() {
                    state.selectSpecialization(item);
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
                    state.selectSpecialization(specialization);
                    Future.delayed(Duration(milliseconds: 100), () {
                      _specializationController.clear();
                    });
                    // setState(() {});
                  },
                ),
                SizedBox(height: 10),
                Wrap(
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
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                TextFormField(
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
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _clinicNameController,
                  decoration: const InputDecoration(
                    labelText: 'Clinic Name',
                    prefixIcon: Icon(
                      Icons.local_hospital,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _clinicAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Clinic Address',
                    prefixIcon: Icon(
                      FontAwesomeIcons.houseChimneyMedical,
                      size: 20,
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _clinicTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Clinic Timings',
                    prefixIcon: Icon(
                      FontAwesomeIcons.solidClock,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
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
                ),
                const SizedBox(height: 20),
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    return ElevatedButton(
                      onPressed: userProvider.isLoading
                          ? null
                          : () async {
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
                                  if (context.mounted) {
                                    context.go(HomeScreen.routeName);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    Utils.showSnackBar(context, Text(e.toString()));
                                  }
                                }
                              }
                            },
                      child: userProvider.isLoading ? CircularProgressIndicator() : const Text('Save'),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Specialization> _searchLogic(String searchQuery, Iterable<Specialization> items) {
    final normalizedQuery = searchQuery.trim().toLowerCase();

    // Separate exact matches and partial matches
    final exactMatches = items.where((element) {
      final normalizedBrandName = (element.name).trim().toLowerCase();
      return normalizedBrandName == normalizedQuery;
    }).toList();

    final partialMatches = items.where((element) {
      final normalizedBrandName = (element.name).trim().toLowerCase();
      return normalizedBrandName.contains(normalizedQuery) && normalizedBrandName != normalizedQuery;
    }).toList();

    // Combine exact matches at the top, followed by partial matches
    return [...exactMatches, ...partialMatches];
  }
}
