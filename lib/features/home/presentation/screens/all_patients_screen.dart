import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../data/models/patient.dart';
import '../providers/patients_provider.dart';
import 'add_patient_screen.dart';
import 'edit_patient_screen.dart';

@RoutePage()
class AllPatientsScreen extends StatefulWidget {
  const AllPatientsScreen({super.key});

  static const routeName = 'select-patient';

  @override
  State<AllPatientsScreen> createState() => _AllPatientsScreenState();
}

class _AllPatientsScreenState extends State<AllPatientsScreen> {
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    context.read<PatientsProvider>().getPatients();
    super.initState();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Patient"),
        actions: [
          IconButton(
            onPressed: () {
              context.goNamed(AddPatientScreen.routeName);
            },
            icon: const Icon(Icons.add, size: 25),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppConstants.defaultPading,
          child: Consumer<PatientsProvider>(
            builder: (context, patientsProvider, child) {
              bool patientNotFoundInSearching =
                  patientsProvider.isSearching && patientsProvider.searchedPatients.isEmpty;
              return Column(
                children: [
                  TextField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: "Search by Name or Phone Number",
                    ),
                    onChanged: (value) => patientsProvider.searchPatients(phoneNumberController.text),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: patientNotFoundInSearching
                        ? Center(
                            child: Text("Patient not found"),
                          )
                        : ListView.builder(
                            itemCount: patientsProvider.isSearching
                                ? patientsProvider.searchedPatients.length
                                : patientsProvider.patients.length,
                            itemBuilder: (context, index) {
                              final Patient patient;
                              if (patientsProvider.isSearching) {
                                patient = patientsProvider.searchedPatients[index];
                              } else {
                                patient = patientsProvider.patients[index];
                              }
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                                title: Text(
                                    "${patient.name ?? "-"}, ${patient.age ?? "-"} ${patient.gender?[0].toUpperCase()}"),
                                subtitle: Text(patient.phoneNumber ?? "-"),
                                onTap: () {
                                  context
                                      .goNamed(EditPatientScreen.routeName, pathParameters: {'patientId': patient.id});
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
