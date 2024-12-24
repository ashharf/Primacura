// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:opd_management/core/utils/utils.dart';
import 'package:opd_management/features/user/presentation/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/functions/app_functions.dart';
import '../../../../core/utils/prescription_utils.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../data/models/patient.dart';
import '../cubit/prescription_cubit.dart';
import '../providers/patients_provider.dart';
import '../widget/custom_autocomplete.dart';
import '../widget/prescription_card.dart';
import 'enter_vitals_screen.dart';

class SelectPatientScreen extends StatefulWidget {
  const SelectPatientScreen({super.key});

  static const routeName = 'enter-patient-details';

  @override
  State<SelectPatientScreen> createState() => _SelectPatientScreenState();
}

class _SelectPatientScreenState extends State<SelectPatientScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  Gender _selectedGender = Gender.male;
  final _phoneNumberRegex = RegExp(r'^[0-9]{10}$');
  bool _newPatientEnteredAsNumber = false;

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<PrescriptionCubit>().clearPatientAndPrescriptionDetails();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Select Patient"),
        ),
        body: Padding(
          padding: AppConstants.defaultPading,
          child: Form(
            key: _formKey,
            child: BlocBuilder<PrescriptionCubit, PrescriptionState>(
              builder: (context, state) {
                final Patient? selectedPatient = state.patient;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Consumer<PatientsProvider>(
                        builder: (context, patientsProvider, child) {
                          return CustomSearchableDropdown<Patient>(
                            prefixIcon: Icon(
                              Icons.search,
                              size: 20,
                            ),
                            hintText: "Search to select patient",
                            searchLogic: _searchLogic,
                            subtitleBuilder: (context, item) => item.phoneNumber != null && item.phoneNumber!.isNotEmpty
                                ? Text(item.phoneNumber!)
                                : null,
                            displayText: (item) => item.name ?? "",
                            textEditingController: _searchController,
                            textCapitalization: TextCapitalization.words,
                            items: patientsProvider.patients,
                            onItemSelected: _onPatientSelected,
                            onAddSelected: _onAddPatientSelected,
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      SizedBox(height: 20),
                      AnimatedOpacity(
                        opacity: selectedPatient != null ? 0.5 : 1,
                        duration: Duration(milliseconds: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              readOnly: selectedPatient != null ? true : false,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                hintText: "Patient Name",
                                prefixIcon: Icon(
                                  FontAwesomeIcons.hospitalUser,
                                  size: 20,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter patient name";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _phoneNumberController,
                              readOnly: selectedPatient != null ? true : false,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: "Patient Phone Number",
                                prefixIcon: Icon(Icons.phone),
                              ),
                              validator: (value) {
                                if (value!.isNotEmpty && !_phoneNumberRegex.hasMatch(value)) {
                                  return "Please enter a valid phone number";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _ageController,
                              readOnly: selectedPatient != null ? true : false,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                hintText: "Patient Age",
                                prefixIcon: Icon(FontAwesomeIcons.personWalkingWithCane),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter patient age";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.venusMars,
                                  size: 20,
                                  // color: Colors.white70,
                                ),
                                SizedBox(width: 20),
                                IgnorePointer(
                                  ignoring: selectedPatient != null ? true : false,
                                  child: DropdownMenu(
                                    dropdownMenuEntries: Gender.values.map(
                                      (e) {
                                        final String genderName = PrescriptionUtils.getGenderString(e);

                                        return DropdownMenuEntry(
                                          value: e,
                                          label: genderName,
                                        );
                                      },
                                    ).toList(),
                                    initialSelection:
                                        selectedPatient != null ? selectedPatient.gender : _selectedGender,
                                    onSelected: (value) {
                                      _selectedGender = value! as Gender;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (state.patientPrescriptions.isNotEmpty) ...[
                        SizedBox(height: 20),
                        Divider(),
                        SizedBox(height: 10),
                      ],
                      BlocBuilder<PrescriptionCubit, PrescriptionState>(
                        builder: (context, state) {
                          final patientPrescriptions = state.patientPrescriptions;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: patientPrescriptions.length,
                            itemBuilder: (context, index) {
                              final prescription = patientPrescriptions[index];
                              return PrescriptionCard(
                                prescription: prescription,
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(20),
          child: BlocBuilder<PrescriptionCubit, PrescriptionState>(
            builder: (context, state) {
              bool isPatientSelected = state.patient != null;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: state.isLoading ? null : () => _next(isPatientSelected),
                child: state.isLoading ? CircularProgressIndicator() : Text("Next"),
              );
            },
          ),
        ),
      ),
    );
  }

  Iterable<Patient> _searchLogic(String searchQuery, Iterable<Patient> items) {
    final normalizedQuery = searchQuery.trim().toLowerCase();

    // Check if the search query is a number
    final isNumberQuery = int.tryParse(normalizedQuery) != null;

    // Separate exact matches and partial matches based on name or phone number
    final exactMatches = items.where((element) {
      if (element.name != null) {
        final normalizedPatientName = element.name!.trim().toLowerCase();
        if (normalizedPatientName == normalizedQuery) {
          return true;
        }
      }
      if (isNumberQuery && element.phoneNumber != null) {
        final normalizedPhoneNumber = element.phoneNumber!.trim();
        return normalizedPhoneNumber == normalizedQuery;
      }
      return false;
    }).toList();

    final partialMatches = items.where((element) {
      if (element.name != null) {
        final normalizedPatientName = element.name!.trim().toLowerCase();
        if (normalizedPatientName.contains(normalizedQuery) && normalizedPatientName != normalizedQuery) {
          return true;
        }
      }
      if (isNumberQuery && element.phoneNumber != null) {
        final normalizedPhoneNumber = element.phoneNumber!.trim();
        return normalizedPhoneNumber.contains(normalizedQuery) && normalizedPhoneNumber != normalizedQuery;
      }
      return false;
    }).toList();

    // Combine exact matches at the top, followed by partial matches
    return [...exactMatches, ...partialMatches];
  }

  void _onPatientSelected(Patient item) {
    context.read<PrescriptionCubit>().onSelectPatient(item);
    _nameController.text = item.name ?? "";
    _phoneNumberController.text = item.phoneNumber ?? "";
    if (item.age != null) {
      _ageController.text = item.age.toString();
    }
    if (item.gender != null) {
      _selectedGender = PrescriptionUtils.getGenderFromString(item.gender!);
    }
    FocusScope.of(context).unfocus();
    Future.delayed(Duration(milliseconds: 100), () {
      _searchController.clear();
    });
  }

  void _onAddPatientSelected(String searchText) {
    final numericRegex = RegExp(r'^[0-9]+$');
    _newPatientEnteredAsNumber = numericRegex.hasMatch(searchText.trim());
    context.read<PrescriptionCubit>().onDeleteSelectedPatient();
    if (_newPatientEnteredAsNumber) {
      _phoneNumberController.text = searchText.trim();
      FocusScope.of(context).unfocus();
      Future.delayed(Duration(milliseconds: 100), () {
        _searchController.clear();
        _nameController.clear();
        _ageController.clear();
        _selectedGender = Gender.male;
      });

      return;
    } else {
      _nameController.text = searchText.trim();
      FocusScope.of(context).unfocus();
      Future.delayed(Duration(milliseconds: 100), () {
        _searchController.clear();
        _phoneNumberController.clear();
        _ageController.clear();
        _selectedGender = Gender.male;
      });
      return;
    }
  }

  _next(bool isPatientSelected) async {
    if (isPatientSelected) {
      context.goNamed(EnterVitalsScreen.routeName);
      return;
    }

    if (_formKey.currentState!.validate()) {
      final patientsProvider = context.read<PatientsProvider>();
      final phoneNumber = _phoneNumberController.text.trim();
      patientsProvider.clearPatientWithSameNumber();
      if (phoneNumber.isNotEmpty) {
        await patientsProvider.checkIfPatientExistsWithNumber(phoneNumber);
      }
      if (patientsProvider.patientsWithSameNumber.isNotEmpty && mounted) {
        final shouldAddPatient = await AppFunctions.showPatientWithSameNumberDialog(context) ?? false;

        if (shouldAddPatient) {
          _addPatient();
          if (mounted) {
            context.goNamed(EnterVitalsScreen.routeName);
            return;
          }
        } else {
          return;
        }
      } else {
        _addPatient();
        if (mounted) {
          context.goNamed(EnterVitalsScreen.routeName);
          return;
        }
      }
    }
  }

  Future<void> _addPatient() async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;
    if (user == null) {
      Utils.showSnackBar(context, Text(AppConstants.pleaseTryLoggingInAgain));
      return;
    }
    final userId = user.id;
    final phoneNumber = _phoneNumberController.text.trim();
    final name = _nameController.text.trim();
    final age = int.parse(_ageController.text.trim());
    final gender = _selectedGender.name;

    final patient = Patient(
      id: Uuid().v1(),
      name: name,
      phoneNumber: phoneNumber,
      doctorId: [userId],
      age: age,
      gender: gender,
    );

    context.read<PrescriptionCubit>().onSelectPatient(patient);
    await context.read<PatientsProvider>().addPatient(patient);
  }
}
