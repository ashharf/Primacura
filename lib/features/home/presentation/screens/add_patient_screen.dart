import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/functions/app_functions.dart';
import '../cubit/prescription_cubit.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/constants.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../data/models/patient.dart';
import '../cubit/patient_cubit.dart';
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
  final phoneNumberRegex = RegExp(r'^[0-9]{10}$');
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
                  // onChanged: (value) => context.read<PatientCubit>().searchPatients,
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
                  // onChanged: (value) {
                  //   context.read<PatientCubit>().deleteSelectedPatient();
                  // },
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
                  // onChanged: (value) {
                  //     context.read<PatientCubit>().deleteSelectedPatient();
                  // },
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
                BlocConsumer<PatientCubit, PatientState>(
                  listener: (context, state) {
                    if (state is PatientAdded) {
                      context.pop();
                    }
                  },
                  builder: (context, state) {
                    bool patientSelected = context.read<PrescriptionCubit>().state.patient != null;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: state is PatientLoading
                          ? null
                          : () async {
                              if (patientSelected) {
                                context.goNamed(EnterVitalsScreen.routeName);
                                return;
                              }

                              if (formKey.currentState!.validate()) {
                                final patientCubit = context.read<PatientCubit>();
                                final phoneNumber = phoneNumberController.text.trim();
                                await patientCubit.checkIfPatientExistsWithNumber(phoneNumber);
                                if (patientCubit.patientsWithSameNumber.isNotEmpty && context.mounted) {
                                  final shouldAddPatient =
                                      await AppFunctions.showPatientWithSameNumberDialog(context) ?? false;
                                  if (shouldAddPatient) {
                                    await addPatient();
                                    // if (context.mounted) {
                                    //   context.pop();
                                    // }
                                  } else {
                                    return;
                                  }
                                } else {
                                  addPatient();
                                }
                              }
                            },
                      child: state is PatientLoading ? CircularProgressIndicator() : Text("Add Patient"),
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
    final userId = (context.read<UserCubit>().state as UserAuthenticated).user.id;
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
    await context.read<PatientCubit>().addPatient(patient);
  }
}
