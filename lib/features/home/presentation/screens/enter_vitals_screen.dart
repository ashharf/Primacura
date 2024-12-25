import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/blood_pressure_input_parameters.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/utils.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../data/models/clinical_findings.dart';
import '../../data/models/investigation.dart';
import '../../data/models/patient.dart';
import '../../data/models/symptomps.dart';
import '../providers/prescriptions_provider.dart';
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
    final prescriptionProvider = context.read<PrescriptionsProvider>();
    final temperature = prescriptionProvider.temperature;
    final bloodPressure = prescriptionProvider.bloodPressure;
    final spO2 = prescriptionProvider.spO2;
    final heartRate = prescriptionProvider.heartRate;
    final specialNotes = prescriptionProvider.specialNote;
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
        child: Consumer<PrescriptionsProvider>(
          builder: (context, prescriptionProvider, _) {
            final Patient selectedPatient = prescriptionProvider.patient!;

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
                      Consumer<PrescriptionsProvider>(
                        builder: (context, prescriptionProvider, _) {
                          return Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: List.generate(
                              prescriptionProvider.chiefComplaints.length,
                              (index) => Chip(
                                label: Text(prescriptionProvider.chiefComplaints[index].name),
                                onDeleted: () {
                                  prescriptionProvider
                                      .onChiefComplaintDeleted(prescriptionProvider.chiefComplaints[index]);
                                },
                                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.6),
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
                      Consumer<PrescriptionsProvider>(
                        builder: (context, prescriptionProvider, _) {
                          return Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: List.generate(
                              prescriptionProvider.clinicalFindings.length,
                              (index) => Chip(
                                label: Text(prescriptionProvider.clinicalFindings[index].name),
                                onDeleted: () {
                                  prescriptionProvider
                                      .onClinicalFindingDeleted(prescriptionProvider.clinicalFindings[index]);
                                },
                                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.6),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30.h),
                      Text("Investigations", style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 10.h),
                      _buildInvestigationsDropdown(),
                      Consumer<PrescriptionsProvider>(
                        builder: (context, prescriptionProvider, _) {
                          return Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: List.generate(
                              prescriptionProvider.investigations.length,
                              (index) => Chip(
                                label: Text(prescriptionProvider.investigations[index].name),
                                onDeleted: () {
                                  prescriptionProvider
                                      .onInvestigationDeleted(prescriptionProvider.investigations[index]);
                                },
                                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.6),
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
                      Consumer<PrescriptionsProvider>(
                        builder: (context, prescriptionProvider, _) {
                          return ElevatedButton.icon(
                            onPressed: () {
                              if (prescriptionProvider.patient == null) {
                                Utils.showSnackBar(context, Text("Something went wrong. Please select patient"));
                                return;
                              }
                              prescriptionProvider.addTemperature(_temperatureController.text.trim());
                              prescriptionProvider.addBloodPressure(_bloodPressureController.text.trim());
                              prescriptionProvider.addSpO2(_spO2Controller.text.trim());
                              prescriptionProvider.addHeartRate(_heartRateController.text.trim());
                              prescriptionProvider.addSpecialNote(_specialNotesController.text.trim());

                              context.goNamed(AddMedicinesScreen.routeName);
                            },
                            label: Icon(
                              Icons.arrow_forward_outlined,
                              color: Colors.white,
                            ),
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

  Widget _buildInvestigationsDropdown() {
    final prescriptionProvider = context.read<PrescriptionsProvider>();
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
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
          items: userProvider.user!.investigations,
          shouldUnFocusOnSelect: false,
          showItemDeleteButton: (item) => true,
          onItemSelected: (item) {
            prescriptionProvider.onInvestigationSelected(item);
            Future.delayed(Duration(milliseconds: 1), () {
              _investigationSearchController.clear();
            });
          },
          onAddSelected: (searchText) {
            final Investigation investigation = Investigation(
              id: Uuid().v4(),
              name: searchText.trim(),
            );

            userProvider.addInvestigation(investigation);
            prescriptionProvider.onInvestigationSelected(investigation);

            Future.delayed(Duration(milliseconds: 1), () {
              _investigationSearchController.clear();
            });

            setState(() {});
          },
          onDelete: (item) {
            userProvider.deleteInvestigation(item);
            setState(() {});
          },
          textCapitalization: TextCapitalization.words,
        );
      },
    );
  }

  Widget _buildClinicalFindingDrodown() {
    final prescriptionProvider = context.read<PrescriptionsProvider>();
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
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
          items: userProvider.user!.clinicalFindings,
          showItemDeleteButton: (item) => true,
          shouldUnFocusOnSelect: false,
          onItemSelected: (item) {
            prescriptionProvider.onClinicalFindingSelected(item);
            Future.delayed(Duration(milliseconds: 1), () {
              _clinicalFindingsSearchController.clear();
            });
          },
          onAddSelected: (searchText) {
            final ClinicalFinding chiefComplaint = ClinicalFinding(
              id: Uuid().v4(),
              name: searchText.trim(),
            );

            userProvider.addClinicalFinding(chiefComplaint);
            prescriptionProvider.onClinicalFindingSelected(chiefComplaint);

            Future.delayed(Duration(milliseconds: 1), () {
              _clinicalFindingsSearchController.clear();
            });

            // setState(() {});
          },
          onDelete: (item) {
            userProvider.deleteClinicalFinding(item);
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
        Consumer<PrescriptionsProvider>(
          builder: (context, prescriptionProvider, _) {
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

  Widget _buildCheifComplaintDropDown() {
    final prescriptionProvider = context.read<PrescriptionsProvider>();
    return Consumer<UserProvider>(
      builder: (context, state, _) {
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
          items: state.user!.chiefComplaints,
          shouldUnFocusOnSelect: false,
          showItemDeleteButton: (item) => true,
          onItemSelected: (item) {
            prescriptionProvider.onCheifComplaintSelected(item);
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

            state.addChiefComplaint(chiefComplaint);
            prescriptionProvider.onCheifComplaintSelected(chiefComplaint);

            setState(() {});
          },
          onDelete: (item) {
            state.deleteChiefComplaint(item);
            setState(() {});
          },
          textCapitalization: TextCapitalization.words,
        );
      },
    );
  }
}
