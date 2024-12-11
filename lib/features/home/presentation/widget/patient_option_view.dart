import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../theme/provider/theme_provider.dart';
import '../../data/models/patient.dart';

@Deprecated("It will be removed in the future release")
class PatientOptionsView extends StatelessWidget {
  const PatientOptionsView({
    super.key,
    required this.options,
    required this.onSelected,
    this.isNewPatient = false,
    this.newPatientEnteredAsNumber = false,
  });

  final Iterable<Patient> options;
  final Function(Patient) onSelected;
  final bool isNewPatient;
  final bool newPatientEnteredAsNumber;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: context.read<ThemeProvider>().currentThemeBrightness == Brightness.light
            ? AppTheme.lightBackgroundColor
            : AppTheme.darkBackgroundColor,
        elevation: 4.0,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) {
            final patient = options.elementAt(index);
            return isNewPatient
                ? ListTile(
                    title: Text(newPatientEnteredAsNumber ? patient.phoneNumber ?? "-" : patient.name ?? "-"),
                    subtitle: Text(
                      "+ Create new patient",
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                    onTap: () {
                      onSelected(patient);
                    },
                  )
                : ListTile(
                    title: Text(
                      "${patient.name ?? "-"}, ${patient.age ?? "-"} ${patient.gender?[0].toUpperCase()}",
                    ),
                    subtitle: Text(patient.phoneNumber ?? "-"),
                    onTap: () {
                      onSelected(patient);
                    },
                  );
          },
        ),
      ),
    );
  }
}
