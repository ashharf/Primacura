import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/functions/app_functions.dart';
import '../../../../core/utils/utils.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../data/models/patient.dart';
import '../providers/patients_provider.dart';
import '../providers/prescriptions_provider.dart';
import 'enter_vitals_screen.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  static const routeName = 'add-patient';

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final RegExp phoneNumberRegex = RegExp(r'^[0-9]{10}$');
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Gender selectedGender = Gender.male;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Patient Form"),
      ),
      body: Padding(
        padding: AppConstants.defaultPading,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Patient Name",
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
                  controller: phoneNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Patient Phone Number",
                  ),
                  validator: (value) {
                    if (value!.isNotEmpty && !phoneNumberRegex.hasMatch(value)) {
                      return "Please enter a valid phone number";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Patient Age",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter patient age";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                DropdownMenu(
                  dropdownMenuEntries: Gender.values
                      .map(
                        (e) => DropdownMenuEntry(
                          value: e,
                          label: e.name.toUpperCase(),
                        ),
                      )
                      .toList(),
                  initialSelection: selectedGender,
                  onSelected: (value) {
                    selectedGender = value!;
                  },
                ),
                SizedBox(height: 50),
                Consumer<PatientsProvider>(
                  builder: (context, patientsProvider, child) {
                    bool patientSelected = context.read<PrescriptionsProvider>().patient != null;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: patientsProvider.isLoading
                          ? null
                          : () async {
                              if (patientSelected) {
                                context.goNamed(EnterVitalsScreen.routeName);
                                return;
                              }

                              if (formKey.currentState!.validate()) {
                                final phoneNumber = phoneNumberController.text.trim();
                                await patientsProvider.checkIfPatientExistsWithNumber(phoneNumber);
                                if (patientsProvider.patientsWithSameNumber.isNotEmpty && context.mounted) {
                                  final shouldAddPatient =
                                      await AppFunctions.showPatientWithSameNumberDialog(context) ?? false;
                                  if (shouldAddPatient) {
                                    await addPatient();
                                  } else {
                                    return;
                                  }
                                } else {
                                  addPatient();
                                }
                              }
                            },
                      child: patientsProvider.isLoading ? CircularProgressIndicator() : Text("Add Patient"),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addPatient() async {
    final userProvider = context.read<UserProvider>();
    if (userProvider.user == null) {
      Utils.showSnackBar(context, Text(AppConstants.pleaseTryLoggingInAgain));
      return;
    }
    final userId = userProvider.user!.id;
    final phoneNumber = phoneNumberController.text.trim();
    final name = nameController.text.trim();
    final age = int.parse(ageController.text.trim());
    final gender = selectedGender.name;

    final patient = Patient(
      id: Uuid().v1(),
      name: name,
      phoneNumber: phoneNumber,
      doctorId: [userId],
      age: age,
      gender: gender,
    );
    try {
      await context.read<PatientsProvider>().addPatient(patient);
      if (mounted) {
        context.pop();
        Utils.showSnackBar(context, Text("Patient added successfully"));
      }
    } catch (e) {
      if (mounted) {
        Utils.showSnackBar(context, Text("Something went wrong"));
      }
    }
  }
}
