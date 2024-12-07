import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:opd_management/features/home/presentation/cubit/prescription_cubit.dart';
import 'package:opd_management/features/home/presentation/screens/select_patient_screen.dart';

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
            onDetect: (barcodes) async {
              if (barcodes.barcodes.isEmpty) {
                context.pop();
                showErrorDialog(context);
                return;
              }

              final barcode = barcodes.barcodes.first;
              final data = barcode.rawValue;
              if (data == null) {
                throw "Error";
              } else {
                try {
                  final prescriptionCubit = context.read<PrescriptionCubit>();
                  // final patientCubit = context.read<PatientCubit>();
                  // final allPatients = patientCubit.state.patients;
                  await prescriptionCubit.getPrescriptions();
                  final prescriptions = prescriptionCubit.state.prescriptions;
                  final prescription = prescriptions.firstWhere((element) => element.id == data);
                  // final patient = allPatients.firstWhere((element) => element.id == data);
                  prescriptionCubit.onSelectPatient(prescription.patient);
                  if (context.mounted) {
                    context.pop();
                    context.goNamed(SelectPatientScreen.routeName);
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.pop();
                    showPatientNotFoundDialog(context);
                  }
                }
              }
            },
          ),
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          )
        ],
      ),
    );
  }

  showErrorDialog(BuildContext context) {
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

  showPatientNotFoundDialog(BuildContext context) {
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
