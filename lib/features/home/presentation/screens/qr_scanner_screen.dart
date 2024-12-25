import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../providers/prescriptions_provider.dart';
import 'select_patient_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  static const String routeName = '/qr-scanner-screen';

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.back,
    // torchEnabled: true,
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan Prescription QR"),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: controller,
            overlayBuilder: (context, constraints) => Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
            onDetect: (barcodes) async {
              if (barcodes.barcodes.isEmpty) {
                context.pop();
                _showErrorDialog(context);
                return;
              }

              final barcode = barcodes.barcodes.first;
              final data = barcode.rawValue;
              if (data == null) {
                throw "Error";
              } else {
                try {
                  final prescriptionProvider = context.read<PrescriptionsProvider>();
                  await prescriptionProvider.getPrescriptions();
                  final prescriptions = prescriptionProvider.prescriptions;
                  final prescription = prescriptions.firstWhere((element) => element.id == data);
                  // final patient = allPatients.firstWhere((element) => element.id == data);
                  prescriptionProvider.onSelectPatient(prescription.patient);
                  if (context.mounted) {
                    context.pop();
                    context.goNamed(SelectPatientScreen.routeName);
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.pop();
                    _showPatientNotFoundDialog(context);
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Please scan a valid QR code"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  _showPatientNotFoundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Patient not found"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
