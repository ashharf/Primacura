import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/functions/app_functions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/prescription_utils.dart';
import '../providers/prescriptions_provider.dart';
import '../widget/custom_progress_indicator.dart';
import 'pdf_view_screen.dart';

class PrescriptionReviewScreen extends StatelessWidget {
  const PrescriptionReviewScreen({super.key});

  static const String routeName = '/prescription-review';
  static final GlobalKey _qrRepaintBoundryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prescription Review"),
      ),
      body: Consumer<PrescriptionsProvider>(
        builder: (context, prescriptionProvider, _) {
          return Column(
            children: [
              CustomProgressIndicator(
                currentStep: 3,
                totalSteps: 3,
              ),
              Expanded(
                child: ListView(
                  padding: AppConstants.defaultPading,
                  children: [
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Text("Rx", style: Theme.of(context).textTheme.titleLarge),
                        Spacer(),
                        RepaintBoundary(
                          key: _qrRepaintBoundryKey,
                          child: QrImageView(
                            padding: EdgeInsets.zero,
                            data: prescriptionProvider.prescription!.id,
                            backgroundColor: Colors.white,
                            version: QrVersions.auto,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    if (prescriptionProvider.prescription != null &&
                        (prescriptionProvider.prescription!.temperature != null &&
                                prescriptionProvider.prescription!.temperature!.isNotEmpty ||
                            prescriptionProvider.prescription!.bloodPressure != null &&
                                prescriptionProvider.prescription!.bloodPressure!.isNotEmpty ||
                            prescriptionProvider.prescription!.spO2 != null &&
                                prescriptionProvider.prescription!.spO2!.isNotEmpty ||
                            prescriptionProvider.prescription!.heartRate != null &&
                                prescriptionProvider.prescription!.heartRate!.isNotEmpty)) ...[
                      Text("Vitals", style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          if (prescriptionProvider.prescription?.temperature != null) ...[
                            Text(
                                "Temperature - ${prescriptionProvider.prescription?.temperature ?? ""} ${prescriptionProvider.prescription?.temperature != null && prescriptionProvider.prescription!.temperature!.isNotEmpty ? "°F" : ""} "),
                          ],
                          if (prescriptionProvider.prescription?.bloodPressure != null) ...[
                            Spacer(),
                            Text("BP - ${prescriptionProvider.prescription?.bloodPressure ?? ""} mmHg"),
                          ]
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          if (prescriptionProvider.prescription?.spO2 != null)
                            Text("SpO2 - ${prescriptionProvider.prescription?.spO2 ?? ""}"),
                          if (prescriptionProvider.prescription?.heartRate != null) ...[
                            Spacer(),
                            Text("Heart Rate - ${prescriptionProvider.prescription?.heartRate ?? ""}"),
                          ]
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                    if (prescriptionProvider.prescription != null &&
                        prescriptionProvider.prescription!.chiefComplaints.isNotEmpty) ...[
                      Row(
                        children: [
                          Text("Chief Complaints", style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      SizedBox(height: 10),
                      if (prescriptionProvider.prescription != null &&
                          prescriptionProvider.prescription!.chiefComplaints.isNotEmpty)
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: List.generate(
                            prescriptionProvider.prescription!.chiefComplaints.length,
                            (index) => Chip(
                              label: Text(prescriptionProvider.prescription!.chiefComplaints[index].name),
                              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                      Text("Clinical Findings", style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 10),
                      if (prescriptionProvider.prescription != null &&
                          prescriptionProvider.prescription!.clinicalFindings.isNotEmpty)
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: List.generate(
                            prescriptionProvider.prescription!.clinicalFindings.length,
                            (index) => Chip(
                              label: Text(prescriptionProvider.prescription!.clinicalFindings[index].name),
                              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                    ],
                    if (prescriptionProvider.prescription != null &&
                        prescriptionProvider.prescription!.investigations.isNotEmpty) ...[
                      Text("Investigations", style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 10),
                      if (prescriptionProvider.prescription != null &&
                          prescriptionProvider.prescription!.investigations.isNotEmpty)
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: List.generate(
                            prescriptionProvider.prescription!.investigations.length,
                            (index) => Chip(
                              label: Text(prescriptionProvider.prescription!.investigations[index].name),
                              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                    ],
                    if (prescriptionProvider.prescription != null &&
                        prescriptionProvider.prescription!.prescribedMedicines.isNotEmpty) ...[
                      Text("Medications", style: Theme.of(context).textTheme.titleMedium),
                      ...List.generate(prescriptionProvider.prescription!.prescribedMedicines.length, (index) {
                        final prefMedicine = prescriptionProvider.prescription!.prescribedMedicines[index];
                        return ListTile(
                          leading: Text(
                            "${index + 1}.",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          minLeadingWidth: 0,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            AppFunctions.getDosageString(
                                medicineName: prefMedicine.medicine.brandName,
                                dosageString: prefMedicine.dosage?.text,
                                dosageUnit: prefMedicine.dosage?.dosageUnit),
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
                                    if (prefMedicine.frequency != null &&
                                        prefMedicine.frequency?.frequencyUnit.icon != null &&
                                        prefMedicine.dosage != null &&
                                        prefMedicine.dosage?.text != null &&
                                        prefMedicine.dosage!.text!.isNotEmpty)
                                      Text(
                                        PrescriptionUtils.getFrequencyIcon(
                                            prefMedicine.frequency!.frequencyUnit.icon!, prefMedicine.dosage!),
                                      ),
                                    if (prefMedicine.notes != null && prefMedicine.notes!.isNotEmpty)
                                      Text(prefMedicine.notes!),
                                  ],
                                ),
                        );
                      }),
                    ],
                    SizedBox(height: 20),
                    if (prescriptionProvider.prescription != null &&
                        prescriptionProvider.prescription!.notes != null &&
                        prescriptionProvider.prescription!.notes!.isNotEmpty) ...[
                      Text("Special Notes", style: Theme.of(context).textTheme.titleMedium),
                      Text(prescriptionProvider.prescription!.notes!)
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<PrescriptionsProvider>(
        builder: (context, reviewScreenProvider, _) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: reviewScreenProvider.isLoading
                  ? null
                  : () async {
                      final prescription = reviewScreenProvider.prescription;
                      prescription!.dateTime = DateTime.now();

                      reviewScreenProvider.addPrescriptionToRemoteDatabase();

                      final capturedImage = await _makeQRImage();
                      prescription.qrData = capturedImage;

                      if (context.mounted) {
                        context.pushNamed(PdfViewScreen.routeName, extra: [prescription, true]);
                      }
                    },
              child: reviewScreenProvider.isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Text("View PDF"),
            ),
          );
        },
      ),
    );
  }

  Future<Uint8List> _makeQRImage() async {
    try {
      // Get the boundary of the widget
      RenderRepaintBoundary boundary = _qrRepaintBoundryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Capture the widget as an image
      ui.Image image = await boundary.toImage(pixelRatio: 5.0); // Adjust pixelRatio if needed
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      return pngBytes;
      // Now, pngBytes contains the PNG image data of the widget
      // You can save it, upload it, or display it as needed
    } catch (e) {
      rethrow;
    }
  }
}
