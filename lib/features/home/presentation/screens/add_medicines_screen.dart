import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/functions/app_functions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/utils.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../data/models/medicine.dart';
import '../../data/models/prescription_medicine.dart';
import '../../data/models/units.dart';
import '../cubit/prescription_cubit.dart';
import '../widget/custom_autocomplete.dart';
import '../widget/custom_progress_indicator.dart';
import '../widget/info_widget.dart';
import 'prescription_review_screen.dart';

class AddMedicinesScreen extends StatefulWidget {
  const AddMedicinesScreen({super.key});

  static const String routeName = '/add-medicines';

  @override
  State<AddMedicinesScreen> createState() => _AddMedicinesScreenState();
}

class _AddMedicinesScreenState extends State<AddMedicinesScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Medicine? _selectedMedicine;

  bool _isBeforeFood = false;
  bool _isEmptyStomach = false;
  bool _isAfterFood = false;

  DosageUnit? _selectedDosageUnit;
  FrequencyUnit? _selectedFrequency;
  DurationUnit? _selectedDurationUnit;

  @override
  void initState() {
    final prescriptionCubit = context.read<PrescriptionCubit>();

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timestamp) {
      try {
        _selectedDosageUnit = prescriptionCubit.dosages.first;
        _selectedDurationUnit = prescriptionCubit.durations.first;
        setState(() {});
      } catch (e) {
        Utils.showSnackBar(
          context,
          Text("Error while fetching from server. Please check your internet and restart the app"),
        );
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    _searchController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Medicines"),
      ),
      body: BlocBuilder<PrescriptionCubit, PrescriptionState>(
        builder: (context, state) {
          final prescriptionCubit = BlocProvider.of<PrescriptionCubit>(context);
          return BlocBuilder<UserCubit, UserState>(
            builder: (context, userState) {
              return Column(
                children: [
                  CustomProgressIndicator(
                    currentStep: 2,
                    totalSteps: 3,
                  ),
                  Expanded(
                    child: ListView(
                      padding: AppConstants.defaultPadding,
                      children: [
                        SizedBox(height: 10.h),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Form(
                              key: _formKey,
                              child: CustomSearchableDropdown<Medicine>(
                                prefixIcon: Icon(
                                  FontAwesomeIcons.pills,
                                  size: 20,
                                ),
                                hintText: "Search Medicine eg Tab. Dolo 650",
                                searchLogic: _searchLogic,
                                displayText: (item) => item.brandName,
                                textEditingController: _searchController,
                                textCapitalization: TextCapitalization.words,
                                items: prescriptionCubit.medicines,
                                showItemDeleteButton: (item) => item.userId == userState.user?.id,
                                onItemSelected: (item) {
                                  setState(() {
                                    _selectedMedicine = item;
                                  });
                                },
                                onAddSelected: _onAddSelected,
                                onDelete: (item) {
                                  prescriptionCubit.medicines.remove(item);
                                  context.read<UserCubit>().deleteMedicineFromRemoteDatabase(item.id);
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            _buildDosageWidget(),
                            SizedBox(height: 10),
                            _buildFrequencyWidget(),
                            SizedBox(height: 10),
                            _buildDurationWidget(),
                            SizedBox(height: 10),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppTheme.primaryColor,
                              value: _isEmptyStomach,
                              onChanged: (value) => onIsEmptyStomachChanged(value),
                              title: Text("Empty Stomach"),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppTheme.primaryColor,
                              value: _isBeforeFood,
                              onChanged: (value) => onIsBeforeFoodChanged(value),
                              title: Text("Before Food"),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppTheme.primaryColor,
                              value: _isAfterFood,
                              onChanged: (value) => onIsAfterFoodChanged(value),
                              title: Text("After Food"),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _notesController,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: "Notes",
                                prefixIcon: Icon(FontAwesomeIcons.notesMedical),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _selectedMedicine == null
                                  ? null
                                  : () {
                                      if (_dosageController.text.isNotEmpty && _selectedFrequency == null) {
                                        showFrequencyNotEnteredDialog(context);
                                      } else {
                                        addToPrescription(context);
                                      }
                                    },
                              child: Text("Add to Prescription"),
                            ),
                            SizedBox(height: 10),
                            Divider(),
                            if (state.prescribedMedicines.isNotEmpty)
                              ReorderableListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final prefMedicine = state.prescribedMedicines[index];

                                  return ListTile(
                                    leading: Icon(Icons.drag_handle),
                                    // shape: RoundedRectangleBorder(
                                    //   borderRadius: BorderRadius.circular(8),
                                    // ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                    key: ValueKey(prefMedicine.hashCode),
                                    title: Text(
                                      AppFunctions.getDosageString(
                                        medicineName: prefMedicine.medicine.brandName,
                                        dosageString: prefMedicine.dosage?.text,
                                        dosageUnit: prefMedicine.dosage?.dosageUnit,
                                      ),
                                    ),
                                    subtitle: AppFunctions.getFrequencyAndDurationString(
                                                  frequencyUnit: prefMedicine.frequency?.frequencyUnit,
                                                  duration: prefMedicine.duration?.text,
                                                  durationUnit: prefMedicine.duration?.durationUnit,
                                                  isAfterFood: prefMedicine.isAfterFood,
                                                  isBeforeFood: prefMedicine.isBeforeFood,
                                                  isEmptyStomach: prefMedicine.isEmptyStomach,
                                                ) ==
                                                " " &&
                                            (prefMedicine.notes == null || prefMedicine.notes!.isEmpty)
                                        ? null
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppFunctions.getFrequencyAndDurationString(
                                                  frequencyUnit: prefMedicine.frequency?.frequencyUnit,
                                                  duration: prefMedicine.duration?.text,
                                                  durationUnit: prefMedicine.duration?.durationUnit,
                                                  isAfterFood: prefMedicine.isAfterFood,
                                                  isBeforeFood: prefMedicine.isBeforeFood,
                                                  isEmptyStomach: prefMedicine.isEmptyStomach,
                                                ),
                                              ),
                                              if (prefMedicine.notes != null && prefMedicine.notes!.isNotEmpty)
                                                Text(prefMedicine.notes!),
                                            ],
                                          ),
                                    trailing: SizedBox(
                                      width: 90,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              showEditMedicineDialog(prefMedicine);
                                            },
                                            icon: Icon(Icons.edit),
                                          ),
                                          IconButton(
                                            // padding: EdgeInsets.zero,
                                            style: IconButton.styleFrom(
                                              // padding: EdgeInsets.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              // backgroundColor: Colors.amber,
                                            ),
                                            onPressed: () {
                                              showDeleteMedicineDialog(prefMedicine);
                                            },
                                            icon: Icon(Icons.delete),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                itemCount: state.prescribedMedicines.length,
                                onReorder: (oldIndex, newIndex) {
                                  if (oldIndex < newIndex) {
                                    newIndex -= 1;
                                  }
                                  prescriptionCubit.onPrescriptionMedicineReorder(oldIndex, newIndex);
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: BlocBuilder<PrescriptionCubit, PrescriptionState>(
          builder: (context, state) {
            return ElevatedButton(
              onPressed: state.prescribedMedicines.isEmpty
                  ? null
                  : () {
                      context.read<PrescriptionCubit>().onMakePrescription(
                            user: context.read<UserCubit>().state.user,
                          );
                      context.goNamed(PrescriptionReviewScreen.routeName);
                    },
              child: Text("Review Prescription"),
            );
          },
        ),
      ),
    );
  }

  Future<void> showDeleteMedicineDialog(PrescriptionMedicine prefMedicine) {
    final prescriptionCubit = context.read<PrescriptionCubit>();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Medicine"),
        content: Text("Are you sure you want to delete ${prefMedicine.medicine.brandName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              prescriptionCubit.onMedicineDeleteForPrescription(prefMedicine);
              Navigator.of(context).pop();
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> showEditMedicineDialog(PrescriptionMedicine prefMedicine) {
    final prescriptionCubit = context.read<PrescriptionCubit>();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Medicine: ${prefMedicine.medicine.brandName}'),
        content: Text('Are you sure you want to edit this medicine?'),
        actions: [
          TextButton(
            onPressed: () {
              _selectedMedicine = prefMedicine.medicine;
              _searchController.text = prefMedicine.medicine.brandName;
              _dosageController.text = prefMedicine.dosage?.text?.trim() ?? "";
              _selectedDosageUnit = prefMedicine.dosage?.dosageUnit;
              _frequencyController.text = prefMedicine.frequency?.text?.trim() ?? "";
              _selectedFrequency = prefMedicine.frequency?.frequencyUnit;
              _durationController.text = prefMedicine.duration?.text.trim() ?? "";
              _selectedDurationUnit = prefMedicine.duration?.durationUnit;
              _notesController.text = prefMedicine.notes?.trim() ?? "";
              _isAfterFood = prefMedicine.isAfterFood;
              _isBeforeFood = prefMedicine.isBeforeFood;
              _isEmptyStomach = prefMedicine.isEmptyStomach;
              prescriptionCubit.onMedicineDeleteForPrescription(prefMedicine);
              setState(() {});
              Navigator.of(context).pop();
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('No'),
          ),
        ],
      ),
    );
  }

  Future<void> showFrequencyNotEnteredDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Frequency not selected"),
              content: Text("To show dosage on prescription you must select a frequency"),
              actions: [
                TextButton(
                  onPressed: () {
                    addToPrescription(context);
                    Navigator.pop(context);
                  },
                  child: Text("Add Medicine anyway"),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Ok"),
                ),
              ],
            ));
  }

  void addToPrescription(BuildContext context) {
    final prescriptionCubit = context.read<PrescriptionCubit>();
    context.read<PrescriptionCubit>().onMedicineAddForPrescription(
          medicine: _selectedMedicine!,
          prescribedDosage: PrescriptionDosage(
            text: _dosageController.text,
            dosageUnit: _selectedDosageUnit!,
          ),
          prescribedFrequency: _selectedFrequency == null
              ? null
              : PrescriptionFrequency(
                  text: _frequencyController.text,
                  frequencyUnit: _selectedFrequency!,
                ),
          prescribedDuration: PrescriptionDuration(
            text: _durationController.text,
            durationUnit: _selectedDurationUnit!,
          ),
          isAfterFood: _isAfterFood,
          isBeforeFood: _isBeforeFood,
          isEmptyStomach: _isEmptyStomach,
          notes: _notesController.text,
        );
    _searchController.clear();
    _dosageController.clear();
    _frequencyController.clear();
    _durationController.clear();
    _notesController.clear();
    setState(() {
      _selectedMedicine = null;
      _isBeforeFood = false;
      _isEmptyStomach = false;
      _isAfterFood = false;
      _selectedDosageUnit = prescriptionCubit.dosages.first;
      // selectedFrequency = prescriptionCubit.frequencies.first;
      _selectedFrequency = null;
      _selectedDurationUnit = prescriptionCubit.durations.first;
    });
    FocusScope.of(context).unfocus();
  }

  Widget _buildDosageWidget() {
    final PrescriptionCubit prescriptionCubit = BlocProvider.of<PrescriptionCubit>(context);
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: TextField(
            controller: _dosageController,
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration(
              labelText: 'Dosage',
              // prefixIcon: Icon(
              //   Icons.vaccines,
              // ),
            ),
          ),
        ),
        DropdownButton<DosageUnit>(
          underline: SizedBox.shrink(),
          // alignment: Alignment.center,
          value: _selectedDosageUnit,
          hint: Text("Select Dosage Unit"),
          items: List.generate(prescriptionCubit.dosages.length, (index) {
            final dosage = prescriptionCubit.dosages[index];
            return DropdownMenuItem(
              value: dosage,
              child: Text(dosage.name),
            );
          }),
          onChanged: (value) {
            setState(() {
              _selectedDosageUnit = value;
            });
          },
        ),
        Spacer(),
        InfoWidget(
          infoText:
              "Select Tablets, Capsules, or ml (for Syrup) etc from the dropdown and enter the quantity to be taken per dose.",
          iconData: Icons.info_outline,
          iconColor: AppTheme.primaryColor,
        )
      ],
    );
  }

  Widget _buildFrequencyWidget() {
    final prescriptionCubit = BlocProvider.of<PrescriptionCubit>(context);
    return Row(
      children: [
        // SizedBox(width: 13),
        // Icon(FontAwesomeIcons.repeat, size: 20),
        // SizedBox(width: 15),
        if (_selectedFrequency?.name == "Custom")
          SizedBox(
            width: 100,
            child: TextField(
              controller: _frequencyController,
              decoration: const InputDecoration(
                labelText: 'Frequency',
              ),
            ),
          ),
        DropdownButton<FrequencyUnit>(
          underline: SizedBox.shrink(),
          value: _selectedFrequency,
          hint: Text("Select Frequency"),
          items: List.generate(prescriptionCubit.frequencies.length + 1, (index) {
            if (index == prescriptionCubit.frequencies.length) {
              return DropdownMenuItem(
                value: null,
                child: Text("Select Frequency"),
              );
            }
            final frequency = prescriptionCubit.frequencies[index];
            return DropdownMenuItem(
              value: frequency,
              child: Text(frequency.name),
            );
          }),
          onChanged: (value) {
            setState(() {
              _selectedFrequency = value;
            });
          },
        ),
        Spacer(),
        InfoWidget(
          infoText: "Select the frequency of the medicine from the dropdown.",
          iconData: Icons.info_outline,
          iconColor: AppTheme.primaryColor,
        )
      ],
    );
  }

  Widget _buildDurationWidget() {
    final prescriptionCubit = BlocProvider.of<PrescriptionCubit>(context);
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Duration',
              // prefixIcon: Icon(
              //   FontAwesomeIcons.calendarDays,
              //   size: 20,
              // ),
            ),
          ),
        ),
        DropdownButton<DurationUnit>(
          underline: SizedBox.shrink(),
          value: _selectedDurationUnit,
          hint: Text("Select Duration Unit"),
          items: List.generate(prescriptionCubit.durations.length, (index) {
            final duration = prescriptionCubit.durations[index];
            return DropdownMenuItem(
              value: duration,
              child: Text(duration.name),
            );
          }),
          onChanged: (value) {
            setState(() {
              _selectedDurationUnit = value;
            });
          },
        )
      ],
    );
  }

  void onIsAfterFoodChanged(bool value) {
    setState(() {
      _isAfterFood = value;
    });
  }

  void onIsBeforeFoodChanged(bool value) {
    setState(() {
      _isBeforeFood = value;
    });
  }

  void onIsEmptyStomachChanged(bool value) {
    setState(() {
      _isEmptyStomach = value;
    });
  }

  Iterable<Medicine> _searchLogic(String searchQuery, Iterable<Medicine> items) {
    final normalizedQuery = searchQuery.trim().toLowerCase();

    // Separate exact matches and partial matches
    final exactMatches = items.where((element) {
      final normalizedBrandName = (element.brandName).trim().toLowerCase();
      return normalizedBrandName == normalizedQuery;
    }).toList();

    final partialMatches = items.where((element) {
      final normalizedBrandName = (element.brandName).trim().toLowerCase();
      return normalizedBrandName.contains(normalizedQuery) && normalizedBrandName != normalizedQuery;
    }).toList();

    // Combine exact matches at the top, followed by partial matches
    return [...exactMatches, ...partialMatches];
  }

  void _onAddSelected(String searchText) {
    final userCubit = context.read<UserCubit>();
    final prescriptionCubit = context.read<PrescriptionCubit>();
    final userState = userCubit.state;
    final Medicine medicine = Medicine(
      id: Uuid().v4(),
      brandName: searchText.trim(),
      userId: userState.user?.id,
    );
    userCubit.addMedicineToRemoteDatabase(medicine);
    prescriptionCubit.medicines.add(medicine);
    setState(() {
      _selectedMedicine = medicine;
    });
  }
}
