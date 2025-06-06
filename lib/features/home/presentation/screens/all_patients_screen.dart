import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'add_patient_screen.dart';
import '../../../../core/constants/constants.dart';
import '../../data/models/patient.dart';
import '../cubit/patient_cubit.dart';
import 'edit_patient_screen.dart';

import '../../../../core/utils/utils.dart';

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
    context.read<PatientCubit>().getPatients();
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
          padding: AppConstants.defaultPadding,
          child: BlocConsumer<PatientCubit, PatientState>(
            listener: (context, state) {
              if (state is PatientError) {
                Utils.showSnackBar(context, Text(state.message ?? "Something went wrong"));
              }
            },
            builder: (context, state) {
              // final areSearchedPatientsEmpty = state is PatientLoaded && state.searchedPatients.isEmpty;
              // final phoneNumberHaveTenDigits = phoneNumberController.text.length == 10;
              List<Patient> patients = [];
              if (state is PatientLoaded) {
                if (state.searchedPatients.isNotEmpty) {
                  patients = state.searchedPatients;
                } else {
                  patients = state.patients;
                }
              }
              return Column(
                children: [
                  TextField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: "Search by Name or Phone Number",
                    ),
                    onChanged: (value) => context.read<PatientCubit>().searchPatients(phoneNumberController.text),
                  ),
                  SizedBox(height: 10),
                  if (state is PatientLoaded)
                    // state.isSearching && areSearchedPatientsEmpty
                    //     // && context.read<PatientCubit>().isSearching
                    //     ? ListTile(
                    //         contentPadding: EdgeInsets.symmetric(horizontal: 0),
                    //         title: Text("Add this number"),
                    //         subtitle: Text(phoneNumberController.text),
                    //         onTap: () {
                    //           if (phoneNumberHaveTenDigits) {
                    //             context.goNamed(SelectPatientScreen.routeName,
                    //                 pathParameters: {'phoneNumber': phoneNumberController.text});
                    //           } else {
                    //             Utils.showSnackBar(context, Text("Please enter a valid phone number"));
                    //           }
                    //         },
                    //         trailing: Icon(Icons.add),
                    //       )
                    //     :
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.isSearching ? state.searchedPatients.length : patients.length,
                        itemBuilder: (context, index) {
                          final Patient patient;
                          if (state.isSearching) {
                            patient = state.searchedPatients[index];
                          } else {
                            patient = state.patients[index];
                          }
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            title: Text(
                                "${patient.name ?? "-"}, ${patient.age ?? "-"} ${patient.gender?[0].toUpperCase()}"),
                            subtitle: Text(patient.phoneNumber ?? "-"),
                            // trailing: IconButton(
                            //   onPressed: () {
                            //     context
                            //         .goNamed(EditPatientScreen.routeName, pathParameters: {'patientId': patient.id});
                            //   },
                            //   icon: Icon(Icons.edit),
                            // ),
                            onTap: () {
                              context.goNamed(EditPatientScreen.routeName, pathParameters: {'patientId': patient.id});
                            },
                          );
                        },
                      ),
                    ),
                  // ElevatedButton(
                  //   onPressed: arePatientsEmpty && phoneNumberHaveTenDigits
                  //       ? () {
                  //           context.goNamed(EnterPatientDetailsScreen.routeName,
                  //               pathParameters: {'phoneNumber': phoneNumberController.text});
                  //         }
                  //       : null,
                  //   child: Text("Add Patient"),
                  // )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
