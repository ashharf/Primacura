import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../prescriptions/data/models/prescription.dart';
import '../../../prescriptions/presentation/screens/pdf_view_screen.dart';

class PrescriptionCard extends StatelessWidget {
  const PrescriptionCard({
    super.key,
    required this.prescription,
  });

  final Prescription prescription;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.secondaryColor,
      child: ListTile(
        onTap: () => context.pushNamed(PdfViewScreen.routeName, extra: [prescription, false]),
        leading: prescription.dateTime != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('hh:mm').format(prescription.dateTime!),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    DateFormat('a').format(prescription.dateTime!),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : Text(
                "-",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
        title: Text(
          prescription.patient.name ?? "-",
          style: TextStyle(
            // color: AppTheme.tertiaryColor,
            color: Colors.white,
          ),
        ),
        subtitle: prescription.dateTime != null
            ? Text(
                DateFormat.MMMEd().format(prescription.dateTime!),
                style: TextStyle(
                  color: Colors.white,
                ),
              )
            : Text("-",
                style: TextStyle(
                  color: Colors.white,
                )),
      ),
    );
  }
}
