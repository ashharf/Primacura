import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/utils.dart';
import '../../data/models/patient.dart';

import '../../../../core/constants/constants.dart';
import '../cubit/patient_cubit.dart';

class EditPatientScreen extends StatefulWidget {
  const EditPatientScreen({required this.patientId, super.key});

  final String patientId;

  static const String routeName = 'edit-patient';

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  late final Patient patient;
  late final TextEditingController nameController;
  late final TextEditingController phoneNumberController;
  late final TextEditingController ageController;
  Gender gender = Gender.male;

  @override
  void initState() {
    final patientCubit = context.read<PatientCubit>();
    patient = (patientCubit.state as PatientLoaded).patients.firstWhere((element) => element.id == widget.patientId);
    nameController = TextEditingController(text: patient.name);
    phoneNumberController = TextEditingController(text: patient.phoneNumber);
    ageController = TextEditingController(text: patient.age.toString());
    if (patient.gender != null) gender = getGenderByString(patient.gender!);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Patient"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text("Delete Patient"),
                        content: Text("Are you sure you want to delete this patient?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<PatientCubit>().deletePatient(patient);
                              Navigator.pop(context);
                            },
                            child: Text("Delete"),
                          ),
                        ],
                      ));
            },
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppConstants.defaultPading,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            DropdownMenu(
              dropdownMenuEntries: Gender.values
                  .map(
                    (e) => DropdownMenuEntry(
                      value: e,
                      label: e.name.toUpperCase(),
                    ),
                  )
                  .toList(),
              initialSelection: gender,
              onSelected: (value) {
                gender = value!;
              },
            ),
            SizedBox(height: 100),
            BlocConsumer<PatientCubit, PatientState>(
              listener: (context, state) {
                if (state is PatientError) {
                  Utils.showSnackBar(context, Text(state.message ?? "Something went wrong"));
                }

                if (state is PatientActionSuccess) {
                  Utils.showSnackBar(context, Text(state.message ?? "Action Successful"));
                }

                if (state is PatientDeleted) {
                  context.pop();
                  Utils.showSnackBar(context, Text(state.message ?? "Patient Deleted"));
                }
              },
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state is PatientLoading
                      ? null
                      : () {
                          final newName = nameController.text;
                          final newPhoneNumber = phoneNumberController.text;
                          final newAge = int.parse(ageController.text);
                          final Gender newGender = gender;
                          final newPatient = Patient(
                            id: patient.id,
                            name: newName,
                            phoneNumber: newPhoneNumber,
                            age: newAge,
                            gender: newGender.name,
                          );
                          context.read<PatientCubit>().updatePatient(newPatient);
                          context.read<PatientCubit>().takePatientBackup(patient);
                          // Navigator.pop(context);
                        },
                  child: state is PatientLoading ? CircularProgressIndicator() : const Text("Update"),
                );
              },
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     context.read<PatientCubit>().deletePatient(patient);
            //     Navigator.pop(context);
            //   },
            //   child: const Text("Delete"),
            // ),
          ],
        ),
      ),
    );
  }
}
