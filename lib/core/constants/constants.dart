import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppConstants {
  static final defaultPading = EdgeInsets.symmetric(horizontal: 30.w);
  static const double defaultBorderRadius = 12;

  static const String userCollection = 'users';
  static const String patientCollection = 'patients';
  static const String specializationCollection = 'specialization';
  static const String medicinesCollection = 'medicines';
  static const String dosagesCollection = 'dosage';
  static const String frequencyCollection = 'frequency';
  static const String durationCollection = 'duration';
  static const String prescriptionsCollection = 'prescriptions';
  static const googleDrivePatientsFileName = 'patients_backup.json';
  static const googleDrivePrescriptionsFileName = 'prescriptions_backup.json';
}
