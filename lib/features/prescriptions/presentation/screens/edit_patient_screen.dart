import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/utils.dart';
import '../../../patients/data/models/patient.dart';
import '../../../patients/presentation/providers/patients_provider.dart';

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
    final patientsProvider = context.read<PatientsProvider>();
    patient = patientsProvider.patients.firstWhere((element) => element.id == widget.patientId);
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
                              context.pop(context);
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                if (context.mounted) {
                                  context.pop(context);
                                  context.pop();
                                  Utils.showSnackBar(context, Text("Patient deleted successfully"));
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  Utils.showSnackBar(context, Text("Something went wrong"));
                                }
                              }
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
            Consumer<PatientsProvider>(
              builder: (context, patientsProvider, child) {
                return ElevatedButton(
                  onPressed: patientsProvider.isLoading
                      ? null
                      : () async {
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
                          try {
                            await patientsProvider.updatePatient(newPatient);
                            if (context.mounted) {
                              Utils.showSnackBar(context, Text("Patient updated successfully"));
                              context.pop();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Utils.showSnackBar(context, Text("Something went wrong"));
                            }
                          }
                          // context.read<PatientCubit>().takePatientBackup(patient);
                          // Navigator.pop(context);
                        },
                  child: patientsProvider.isSearching ? CircularProgressIndicator() : const Text("Update"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
