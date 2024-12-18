import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/blood_pressure_input_parameters.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/utils.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../data/models/clinical_findings.dart';
import '../../data/models/investigation.dart';
import '../../data/models/patient.dart';
import '../../data/models/symptomps.dart';
import '../cubit/prescription_cubit.dart';
import '../widget/custom_autocomplete.dart';
import '../widget/custom_progress_indicator.dart';
import 'add_medicines_screen.dart';

class EnterVitalsScreen extends StatefulWidget {
  const EnterVitalsScreen({super.key});

  static const String routeName = '/enter-vitals';

  @override
  State<EnterVitalsScreen> createState() => _EnterVitalsScreenState();
}

class _EnterVitalsScreenState extends State<EnterVitalsScreen> {
  final TextEditingController _chiefComplaintSearchController = TextEditingController();
  final TextEditingController _clinicalFindingsSearchController = TextEditingController();
  final TextEditingController _investigationSearchController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _spO2Controller = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _specialNotesController = TextEditingController();

  @override
  void initState() {
    final PrescriptionCubit prescriptionCubit = context.read<PrescriptionCubit>();
    final temperature = prescriptionCubit.state.temperature;
    final bloodPressure = prescriptionCubit.state.bloodPressure;
    final spO2 = prescriptionCubit.state.spO2;
    final heartRate = prescriptionCubit.state.heartRate;
    final specialNotes = prescriptionCubit.state.specialNote;
    _temperatureController.text = temperature ?? "";
    _bloodPressureController.text = bloodPressure ?? "";
    _spO2Controller.text = spO2 ?? "";
    _heartRateController.text = heartRate ?? "";
    _specialNotesController.text = specialNotes ?? "";
    super.initState();
  }

  @override
  void dispose() {
    _chiefComplaintSearchController.dispose();
    _clinicalFindingsSearchController.dispose();
    _investigationSearchController.dispose();
    _temperatureController.dispose();
    _bloodPressureController.dispose();
    _spO2Controller.dispose();
    _heartRateController.dispose();
    _specialNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Vitals"),
      ),
      body: SafeArea(
        child: BlocConsumer<PrescriptionCubit, PrescriptionState>(
          listener: (context, state) {
            if (state.message != null) {
              Utils.showSnackBar(context, Text(state.message ?? "Something went wrong"));
            }
          },
          builder: (context, prescriptionState) {
            final prescriptionCubit = context.read<PrescriptionCubit>();
            final Patient selectedPatient = prescriptionState.patient!;

            return Column(
              children: [
                CustomProgressIndicator(
                  currentStep: 1,
                  totalSteps: 3,
                ),
                SizedBox(height: 10.h),
                Container(
                  margin: AppConstants.defaultPading,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        selectedPatient.name ?? "-",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Gender: ${selectedPatient.gender?.substring(0, 1).toUpperCase()}${selectedPatient.gender?.substring(1).toLowerCase()}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          // Spacer(),
                          Text(
                            "Age: ${selectedPatient.age.toString()}",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: AppConstants.defaultPading,
                    children: [
                      SizedBox(height: 30.h),
                      Text("Add Chief Complaints", style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 10.h),
                      _buildCheifComplaintDropDown(),
                      BlocBuilder<PrescriptionCubit, PrescriptionState>(
                        builder: (context, state) {
                          return Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: List.generate(
                              // prescriptionCubit.selectedSymptoms.length,
                              state.chiefComplaints.length,
                              (index) => Chip(
                                label: Text(state.chiefComplaints[index].name),
                                onDeleted: () {
                                  context
                                      .read<PrescriptionCubit>()
                                      .onChiefComplaintDeleted(state.chiefComplaints[index]);
                                },
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.6),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30.h),
                      Text("Vitals", style: Theme.of(context).textTheme.titleMedium),
                      _buildVitals(),
                      SizedBox(height: 30.h),
                      Text("Clinical Findings", style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 10.h),
                      _buildClinicalFindingDrodown(),
                      BlocBuilder<PrescriptionCubit, PrescriptionState>(
                        builder: (context, state) {
                          return Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: List.generate(
                              state.clinicalFindings.length,
                              (index) => Chip(
                                label: Text(state.clinicalFindings[index].name),
                                onDeleted: () {
                                  context
                                      .read<PrescriptionCubit>()
                                      .onClinicalFindingDeleted(state.clinicalFindings[index]);
                                },
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.6),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30.h),
                      Text("Investigations", style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 10.h),
                      _buildInvestigationsDropdown(),
                      BlocBuilder<PrescriptionCubit, PrescriptionState>(
                        builder: (context, state) {
                          return Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: List.generate(
                              state.investigations.length,
                              (index) => Chip(
                                label: Text(state.investigations[index].name),
                                onDeleted: () {
                                  context.read<PrescriptionCubit>().onInvestigationDeleted(state.investigations[index]);
                                },
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.6),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30.h),
                      TextField(
                        controller: _specialNotesController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Add Special Notes',
                          prefixIcon: Icon(
                            FontAwesomeIcons.notesMedical,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                      BlocBuilder<PrescriptionCubit, PrescriptionState>(
                        builder: (context, state) {
                          return ElevatedButton.icon(
                            onPressed: () {
                              if (state.patient == null) {
                                Utils.showSnackBar(context, Text("Something went wrong. Please select patient"));
                                return;
                              }
                              prescriptionCubit.addTemperature(_temperatureController.text.trim());
                              prescriptionCubit.addBloodPressure(_bloodPressureController.text.trim());
                              prescriptionCubit.addSpO2(_spO2Controller.text.trim());
                              prescriptionCubit.addHeartRate(_heartRateController.text.trim());
                              prescriptionCubit.addSpecialNote(_specialNotesController.text.trim());

                              context.goNamed(AddMedicinesScreen.routeName);
                            },
                            label: Icon(Icons.arrow_forward_outlined),
                            icon: Text("Add Medicines"),
                          );
                        },
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  BlocBuilder<UserCubit, UserState> _buildInvestigationsDropdown() {
    final prescriptionCubit = context.read<PrescriptionCubit>();
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return CustomSearchableDropdown<Investigation>(
          prefixIcon: Icon(
            FontAwesomeIcons.microscope,
            size: 20,
          ),
          hintText: "Search Investigations",
          searchLogic: (searchQuery, items) {
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
          },
          displayText: (item) => item.name,
          textEditingController: _investigationSearchController,
          items: (state as UserAuthenticated).user.investigations,
          shouldUnFocusOnSelect: false,
          showItemDeleteButton: (item) => true,
          onItemSelected: (item) {
            context.read<PrescriptionCubit>().onInvestigationSelected(item);
            Future.delayed(Duration(milliseconds: 1), () {
              _investigationSearchController.clear();
            });
          },
          onAddSelected: (searchText) {
            final Investigation investigation = Investigation(
              id: Uuid().v4(),
              name: searchText.trim(),
            );

            context.read<UserCubit>().addInvestigation(investigation);
            prescriptionCubit.onInvestigationSelected(investigation);

            Future.delayed(Duration(milliseconds: 1), () {
              _investigationSearchController.clear();
            });

            setState(() {});
          },
          onDelete: (item) {
            context.read<UserCubit>().deleteInvestigation(item);
            setState(() {});
          },
          textCapitalization: TextCapitalization.words,
        );
      },
    );
  }

  BlocBuilder<UserCubit, UserState> _buildClinicalFindingDrodown() {
    final prescriptionCubit = context.read<PrescriptionCubit>();
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return CustomSearchableDropdown<ClinicalFinding>(
          prefixIcon: Icon(
            FontAwesomeIcons.magnifyingGlassPlus,
            size: 20,
          ),
          hintText: "Search Clinical Findings",
          searchLogic: (searchQuery, items) {
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
          },
          displayText: (item) => item.name,
          textEditingController: _clinicalFindingsSearchController,
          items: (state as UserAuthenticated).user.clinicalFindings,
          showItemDeleteButton: (item) => true,
          shouldUnFocusOnSelect: false,
          onItemSelected: (item) {
            context.read<PrescriptionCubit>().onClinicalFindingSelected(item);
            Future.delayed(Duration(milliseconds: 1), () {
              _clinicalFindingsSearchController.clear();
            });
          },
          onAddSelected: (searchText) {
            final ClinicalFinding chiefComplaint = ClinicalFinding(
              id: Uuid().v4(),
              name: searchText.trim(),
            );

            context.read<UserCubit>().addClinicalFinding(chiefComplaint);
            prescriptionCubit.onClinicalFindingSelected(chiefComplaint);

            Future.delayed(Duration(milliseconds: 1), () {
              _clinicalFindingsSearchController.clear();
            });

            // setState(() {});
          },
          onDelete: (item) {
            context.read<UserCubit>().deleteClinicalFinding(item);
            setState(() {});
          },
          textCapitalization: TextCapitalization.words,
        );
      },
    );
  }

  Column _buildVitals() {
    return Column(
      children: [
        BlocBuilder<PrescriptionCubit, PrescriptionState>(
          builder: (context, state) {
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _temperatureController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Temperature',
                      prefixIcon: Icon(
                        FontAwesomeIcons.temperatureEmpty,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: TextFormField(
                    controller: _bloodPressureController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Blood Pressure',
                      prefixIcon: Icon(
                        FontAwesomeIcons.droplet,
                        size: 20,
                      ),
                    ),
                    inputFormatters: [BloodPressureInputFormatter()],
                  ),
                )
              ],
            );
          },
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _spO2Controller,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'SpO2',
                  prefixIcon: Icon(
                    Icons.masks_outlined,
                  ),
                ),
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: TextFormField(
                controller: _heartRateController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Heart Rate',
                  prefixIcon: Icon(
                    FontAwesomeIcons.heartPulse,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  BlocBuilder<UserCubit, UserState> _buildCheifComplaintDropDown() {
    final prescriptionCubit = context.read<PrescriptionCubit>();
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return CustomSearchableDropdown<ChiefComplaint>(
          prefixIcon: Icon(
            FontAwesomeIcons.headSideVirus,
            size: 20,
          ),
          hintText: "Search Chief Complaint",
          searchLogic: (searchQuery, items) {
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
          },
          displayText: (item) => item.name,
          textEditingController: _chiefComplaintSearchController,
          items: (state as UserAuthenticated).user.chiefComplaints,
          shouldUnFocusOnSelect: false,
          showItemDeleteButton: (item) => true,
          onItemSelected: (item) {
            context.read<PrescriptionCubit>().onCheifComplaintSelected(item);
            Future.delayed(Duration(milliseconds: 1), () {
              _chiefComplaintSearchController.clear();
            });
          },
          onAddSelected: (searchText) {
            final ChiefComplaint chiefComplaint = ChiefComplaint(
              id: Uuid().v4(),
              name: searchText.trim(),
            );
            Future.delayed(Duration(milliseconds: 1), () {
              _chiefComplaintSearchController.clear();
            });

            context.read<UserCubit>().addChiefComplaint(chiefComplaint);
            prescriptionCubit.onCheifComplaintSelected(chiefComplaint);

            setState(() {});
          },
          onDelete: (item) {
            context.read<UserCubit>().deleteChiefComplaint(item);
            setState(() {});
          },
          textCapitalization: TextCapitalization.words,
        );
      },
    );
  }
}
