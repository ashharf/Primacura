import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/home/data/models/units.dart';
import '../../features/home/presentation/providers/patients_provider.dart';
import '../../features/home/presentation/providers/prescriptions_provider.dart';

class AppFunctions {
  static Future<bool?> showPatientWithSameNumberDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final patientsWithSamePhoneNumber = context.read<PatientsProvider>().patientsWithSameNumber;
        return AlertDialog(
          title: Text(
              "${patientsWithSamePhoneNumber.length > 1 ? "Patients" : "Patient"} with same number ${patientsWithSamePhoneNumber.length > 1 ? "exist" : "exists"}"),
          content: SizedBox(
            height: 200.h,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  patientsWithSamePhoneNumber.length,
                  (index) {
                    final patient = patientsWithSamePhoneNumber.elementAt(index);
                    return ListTile(
                      onTap: () {
                        context.read<PrescriptionsProvider>().onSelectPatient(patient);
                        Navigator.pop(context, false);
                        FocusScope.of(context).unfocus();
                      },
                      title: Text(
                        "${patient.name ?? "-"}, ${patient.age ?? "-"} ${patient.gender?[0].toUpperCase()}",
                      ),
                      subtitle: Text(patient.phoneNumber ?? "-"),
                    );
                  },
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // addPatient();
                Navigator.pop(context, true);
                // context.goNamed(EnterVitalsScreen.routeName);
              },
              child: Text("Add with same Phone Number"),
            ),
          ],
        );
      },
    );
  }

  static String getDosageString(
      {required String? medicineName, required String? dosageString, DosageUnit? dosageUnit}) {
    if (medicineName == null || medicineName.isEmpty) return "";
    if (dosageString == null || dosageString.isEmpty) return medicineName;
    return "$medicineName ";
  }

  static String getFrequencyString({required FrequencyUnit frequencyUnit}) {
    return frequencyUnit.name;
  }

  static String getFoodState({bool isAfterFood = false, bool isBeforeFood = false, bool isEmptyStomach = false}) {
    return "${isAfterFood ? "(After Food)" : ""}${isBeforeFood ? "(Before Food)" : ""}${isEmptyStomach ? "(Empty Stomach)" : ""}";
  }

  static String getDurationString({required String? duration, required DurationUnit? durationUnit}) {
    if (duration == null || duration.isEmpty) return "";
    if (durationUnit == null) return duration;
    return "$duration ${durationUnit.name}";
  }

  static String getFrequencyAndDurationString({
    required FrequencyUnit? frequencyUnit,
    required String? duration,
    DurationUnit? durationUnit,
    bool isAfterFood = false,
    bool isBeforeFood = false,
    bool isEmptyStomach = false,
  }) {
    // log("duration: $duration, durationUnit: ${durationUnit?.name}");
    if (duration == null || duration.isEmpty) {
      return "${frequencyUnit?.name ?? ""} ${isAfterFood ? "(After Food)" : ""}${isBeforeFood ? "(Before Food)" : ""}${isEmptyStomach ? "(Empty Stomach)" : ""}";
    }
    if (durationUnit == null) {
      return "${frequencyUnit?.name ?? ""} ${isAfterFood ? "(After Food)" : ""}${isBeforeFood ? "(Before Food)" : ""}${isEmptyStomach ? "(Empty Stomach)" : ""}";
    }
    return "${frequencyUnit?.name ?? ""} x $duration ${durationUnit.name} ${isAfterFood ? "(After Food)" : ""}${isBeforeFood ? "(Before Food)" : ""}${isEmptyStomach ? "(Empty Stomach)" : ""}";
  }
}
