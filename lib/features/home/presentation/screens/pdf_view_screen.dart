import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/functions/app_functions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/prescription_utils.dart';
import '../../../../core/utils/utils.dart';
import '../../../../gen/assets.gen.dart';
import '../../data/models/prescription.dart';
import '../cubit/prescription_cubit.dart';
import 'enter_vitals_screen.dart';
import 'home_screen.dart';
import 'select_patient_screen.dart';

class PdfViewScreen extends StatefulWidget {
  static const String routeName = 'pdf-view';

  final Prescription prescription;
  final bool showDoneButton;
  const PdfViewScreen({
    super.key,
    required this.prescription,
    this.showDoneButton = false,
  });

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  final pdf = pw.Document(title: "Prescription");
  Uint8List? savedPdf;
  bool isLoading = false;

  final Map<String, PdfPageFormat> pageFormats = {
    'Letter': PdfPageFormat.letter,
    'A4': PdfPageFormat.a4,
    'A5': PdfPageFormat.a5,
    'A6': PdfPageFormat.a6,
    'Legal': PdfPageFormat.legal,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.prescription.patient.name ?? ""),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : savedPdf == null
                ? Center(
                    child: Text("No Prescription Found"),
                  )
                : InteractiveViewer(
                    maxScale: 5,
                    child: PdfPreview(
                      build: (format) {
                        return savedPdf!;
                      },
                      pageFormats: pageFormats,
                      canChangePageFormat: false,
                      canChangeOrientation: false,
                      canDebug: false,
                      enableScrollToPage: true,
                      pdfFileName:
                          "${widget.prescription.patient.name ?? "Prescription | ${DateFormat("dd MMMM yyyy").format(widget.prescription.dateTime!)}.pdf"} | ${DateFormat("dd MMMM yyyy").format(widget.prescription.dateTime!)}.pdf",
                      shareActionExtraSubject:
                          "${widget.prescription.patient.name ?? "Prescription | ${DateFormat("dd MMMM yyyy").format(widget.prescription.dateTime!)}"} | ${DateFormat("dd MMMM yyyy").format(widget.prescription.dateTime!)}",
                    ),
                  ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(20),
          child: widget.showDoneButton
              ? ElevatedButton(
                  onPressed: onDone,
                  child: Text("Done"),
                )
              : ElevatedButton.icon(
                  onPressed: onEdit,
                  label: Text("Edit"),
                  icon: Icon(
                    Icons.edit,
                    size: 20,
                  ),
                ),
        ));
  }

  Future<void> generatePdf() async {
    setState(() {
      isLoading = true;
    });

    final drAcharyaLogo = await rootBundle.load(Assets.icons.acharyaLogo.path);
    final imageBytes = drAcharyaLogo.buffer.asUint8List();
    pw.Image clinicLogoImage = pw.Image(pw.MemoryImage(imageBytes));

    final doctorAcharyaSignature = await rootBundle.load(Assets.icons.signature.path);
    final doctorAcharyaSignatureBytes = doctorAcharyaSignature.buffer.asUint8List();
    pw.Image doctorAcharyaSignatureImage = pw.Image(pw.MemoryImage(doctorAcharyaSignatureBytes));

    final rodOfAsclepiusLogo = await rootBundle.load(Assets.icons.rodOfAsclepius.path);
    final rodOfAsclepiusBytes = rodOfAsclepiusLogo.buffer.asUint8List();
    pw.Image rodOfAsclepiusImage = pw.Image(pw.MemoryImage(rodOfAsclepiusBytes));
    final drAcharyaEmail = "acharya.ps@gmail.com";

    try {
      pdf.addPage(
        //   pw.MultiPage(
        //     margin: pw.EdgeInsets.all(30),
        //     header: (context) => _buildHeader(clinicLogoImage, rodOfAsclepiusImage),
        //     build: (context) => [
        //       pw.SizedBox(height: 20),
        //       pw.Row(
        //         crossAxisAlignment: pw.CrossAxisAlignment.start,
        //         children: [
        //           pw.Expanded(
        //             flex: 2,
        //             child: pw.Column(
        //               crossAxisAlignment: pw.CrossAxisAlignment.start,
        //               children: [
        //                 pw.Text(
        //                   "Name: ${widget.prescription.patient.name ?? ""}",
        //                 ),
        //                 pw.SizedBox(height: 5),
        //                 pw.Text(
        //                   "Age: ${widget.prescription.patient.age ?? ""}",
        //                 ),
        //                 pw.SizedBox(height: 5),
        //                 pw.Row(
        //                   children: [
        //                     pw.Text(
        //                       "Gender: ",
        //                     ),
        //                     pw.Text(
        //                       widget.prescription.patient.gender?.substring(0, 1).toUpperCase() ?? "",
        //                     ),
        //                     pw.Text(
        //                       widget.prescription.patient.gender?.substring(1).toLowerCase() ?? "",
        //                     ),
        //                   ],
        //                 )
        //               ],
        //             ),
        //           ),
        //           if (widget.prescription.dateTime != null)
        //             pw.Expanded(
        //               flex: 1,
        //               child: pw.Padding(
        //                 padding: pw.EdgeInsets.symmetric(horizontal: 8),
        //                 child: pw.Column(
        //                   crossAxisAlignment: pw.CrossAxisAlignment.start,
        //                   children: [
        //                     pw.Text("Date: ${DateFormat("dd MMMM yyyy").format(widget.prescription.dateTime!)}"),
        //                     pw.Text("Time: ${DateFormat.jmz().format(widget.prescription.dateTime!)}")
        //                   ],
        //                 ),
        //               ),
        //             ),
        //         ],
        //       ),
        //       pw.Divider(),
        //       if (widget.prescription.chiefComplaints.isNotEmpty) ...[
        //         pw.Padding(
        //           padding: pw.EdgeInsets.only(bottom: 20),
        //           child: pw.Column(
        //             crossAxisAlignment: pw.CrossAxisAlignment.start,
        //             children: [
        //               pw.Text(
        //                 "Chief Complaints",
        //                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //               ),
        //               pw.SizedBox(height: 5),
        //               ...List.generate(
        //                 widget.prescription.chiefComplaints.length,
        //                 (index) {
        //                   final chiefComplaint = widget.prescription.chiefComplaints[index];
        //                   return pw.Text(
        //                     "${index + 1}. ${chiefComplaint.name}",
        //                   );
        //                 },
        //               ),
        //             ],
        //           ),
        //         )
        //       ],
        //       if (widget.prescription.clinicalFindings.isNotEmpty) ...[
        //         pw.Padding(
        //           padding: pw.EdgeInsets.only(bottom: 20),
        //           child: pw.Column(
        //             crossAxisAlignment: pw.CrossAxisAlignment.start,
        //             children: [
        //               pw.Text(
        //                 "Clinical Findings",
        //                 style: pw.TextStyle(
        //                   fontWeight: pw.FontWeight.bold,
        //                   fontSize: 14,
        //                 ),
        //               ),
        //               pw.SizedBox(height: 5),
        //               ...List.generate(
        //                 widget.prescription.clinicalFindings.length,
        //                 (index) {
        //                   final clinicalFinding = widget.prescription.clinicalFindings[index];
        //                   return
        //                       //  pw.Column(
        //                       //   crossAxisAlignment: pw.CrossAxisAlignment.start,
        //                       //   children: [
        //                       pw.Text(
        //                     "${index + 1}. ${clinicalFinding.name}",
        //                   );
        //                   //   ],
        //                   // );
        //                 },
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //       if ((widget.prescription.temperature != null && widget.prescription.temperature!.isNotEmpty) ||
        //           (widget.prescription.bloodPressure != null && widget.prescription.bloodPressure!.isNotEmpty) ||
        //           (widget.prescription.heartRate != null && widget.prescription.heartRate!.isNotEmpty) ||
        //           (widget.prescription.spO2 != null && widget.prescription.spO2!.isNotEmpty))
        //         pw.Padding(
        //           padding: pw.EdgeInsets.only(bottom: 20),
        //           child: pw.Column(
        //             crossAxisAlignment: pw.CrossAxisAlignment.start,
        //             children: [
        //               pw.Text(
        //                 "Vitals",
        //                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //               ),
        //               pw.SizedBox(height: 5),
        //               if (widget.prescription.bloodPressure != null && widget.prescription.bloodPressure!.isNotEmpty) ...[
        //                 // pw.SizedBox(height: 5),
        //                 pw.Text(
        //                   "BP: ${widget.prescription.bloodPressure ?? "-"} mmHg",
        //                   // style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //                 ),
        //               ],
        //               if (widget.prescription.heartRate != null && widget.prescription.heartRate!.isNotEmpty) ...[
        //                 // pw.SizedBox(height: 5),
        //                 pw.Text(
        //                   "Heart Rate: ${widget.prescription.heartRate ?? "-"} bpm",
        //                   // style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //                 ),
        //               ],
        //               if (widget.prescription.temperature != null && widget.prescription.temperature!.isNotEmpty) ...[
        //                 // pw.SizedBox(height: 5),
        //                 pw.Text(
        //                   "Temp: ${widget.prescription.temperature ?? "-"}°F",
        //                   // style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //                 ),
        //               ],
        //               if (widget.prescription.spO2 != null && widget.prescription.spO2!.isNotEmpty) ...[
        //                 // pw.SizedBox(height: 5),
        //                 pw.Text(
        //                   "SpO2: ${widget.prescription.spO2 ?? "-"}%",
        //                   // style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //                 ),
        //               ],
        //             ],
        //           ),
        //         ),
        //       if (widget.prescription.investigations.isNotEmpty) ...[
        //         pw.Text(
        //           "Investigations",
        //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //         ),
        //         pw.SizedBox(height: 5),
        //         ...List.generate(
        //           widget.prescription.investigations.length,
        //           (index) {
        //             final investigation = widget.prescription.investigations[index];
        //             return pw.Column(
        //               crossAxisAlignment: pw.CrossAxisAlignment.start,
        //               children: [
        //                 pw.Text(
        //                   "${index + 1}. ${investigation.name}",
        //                 ),
        //               ],
        //             );
        //           },
        //         ),
        //         // pw.SizedBox(height: 20),
        //       ],
        //       pw.Divider(),
        //       pw.Text(
        //         "Rx",
        //         style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
        //       ),
        //       pw.SizedBox(height: 20),
        //       ...List.generate(
        //         widget.prescription.prescribedMedicines.length,
        //         (index) {
        //           final prefMedicine = widget.prescription.prescribedMedicines[index];
        //           return pw.Column(
        //             crossAxisAlignment: pw.CrossAxisAlignment.start,
        //             children: [
        //               pw.Text(
        //                 "${index + 1}. ${AppFunctions.getDosageString(
        //                   medicineName: prefMedicine.medicine.brandName,
        //                   dosageString: prefMedicine.dosage?.text,
        //                   dosageUnit: prefMedicine.dosage?.dosageUnit,
        //                 )}",
        //                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        //               ),
        //               pw.SizedBox(height: 1),
        //               pw.Text(
        //                 AppFunctions.getFrequencyAndDurationString(
        //                   frequencyUnit: prefMedicine.frequency?.frequencyUnit,
        //                   duration: prefMedicine.duration?.text,
        //                   durationUnit: prefMedicine.duration?.durationUnit,
        //                   isAfterFood: prefMedicine.isAfterFood,
        //                   isBeforeFood: prefMedicine.isBeforeFood,
        //                   isEmptyStomach: prefMedicine.isEmptyStomach,
        //                 ),
        //               ),
        //               pw.SizedBox(height: 1),
        //               if (prefMedicine.frequency != null &&
        //                   prefMedicine.frequency?.frequencyUnit.icon != null &&
        //                   prefMedicine.dosage != null &&
        //                   prefMedicine.dosage?.text != null &&
        //                   prefMedicine.dosage!.text!.isNotEmpty)
        //                 pw.Text(
        //                   PrescriptionUtils.getFrequencyIcon(
        //                       prefMedicine.frequency!.frequencyUnit.icon!, prefMedicine.dosage!),
        //                 ),
        //               // if (prefMedicine.notes != null && prefMedicine.notes!.isNotEmpty)
        //               //   pw.Text(prefMedicine.notes!),
        //               pw.SizedBox(height: 7),
        //             ],
        //           );
        //         },
        //       ),
        //       if (widget.prescription.notes != null && widget.prescription.notes!.isNotEmpty) ...[
        //         // pw.Spacer(),
        //         pw.SizedBox(height: widget.prescription.prescribedMedicines.length >= 5 ? 20 : 40),
        //         // pw.Spacer(),
        //         pw.Text("--"),
        //         pw.SizedBox(height: 5),
        //         pw.Text(
        //           "Special Notes",
        //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //         ),
        //         pw.SizedBox(height: 3),
        //         pw.Text(widget.prescription.notes!),
        //       ],
        //       pw.SizedBox(height: 20),
        //     ],
        //     // build: (context) => [
        //     //   pw.Divider(),
        //     //   pw.Row(
        //     //     crossAxisAlignment: pw.CrossAxisAlignment.start,
        //     //     children: [
        //     //       pw.Expanded(
        //     //         flex: 2,
        //     //         child: pw.Column(
        //     //           crossAxisAlignment: pw.CrossAxisAlignment.start,
        //     //           children: [
        //     //             pw.Text(
        //     //               "Name: ${widget.prescription.patient.name ?? ""}",
        //     //             ),
        //     //             pw.SizedBox(height: 5),
        //     //             pw.Text(
        //     //               "Age: ${widget.prescription.patient.age ?? ""}",
        //     //             ),
        //     //             pw.SizedBox(height: 5),
        //     //             pw.Row(
        //     //               children: [
        //     //                 pw.Text(
        //     //                   "Gender: ",
        //     //                 ),
        //     //                 pw.Text(
        //     //                   widget.prescription.patient.gender?.substring(0, 1).toUpperCase() ?? "",
        //     //                 ),
        //     //                 pw.Text(
        //     //                   widget.prescription.patient.gender?.substring(1).toLowerCase() ?? "",
        //     //                 ),
        //     //               ],
        //     //             )
        //     //           ],
        //     //         ),
        //     //       ),
        //     //       if (widget.prescription.dateTime != null)
        //     //         pw.Expanded(
        //     //           flex: 1,
        //     //           child: pw.Padding(
        //     //             padding: pw.EdgeInsets.symmetric(horizontal: 8),
        //     //             child: pw.Column(
        //     //               crossAxisAlignment: pw.CrossAxisAlignment.start,
        //     //               children: [
        //     //                 pw.Text("Date: ${DateFormat("dd MMMM yyyy").format(widget.prescription.dateTime!)}"),
        //     //                 pw.Text("Time: ${DateFormat.jmz().format(widget.prescription.dateTime!)}")
        //     //               ],
        //     //             ),
        //     //           ),
        //     //         ),
        //     //     ],
        //     //   ),
        //     //   pw.Row(
        //     //     crossAxisAlignment: pw.CrossAxisAlignment.start,
        //     //     children: [
        //     //       pw.Expanded(
        //     //         flex: 2,
        //     //         // child: pw.Container(
        //     //         child: pw.Padding(
        //     //           padding: pw.EdgeInsets.zero,
        //     //           child: pw.Column(
        //     //             crossAxisAlignment: pw.CrossAxisAlignment.start,
        //     //             children: [
        //     //               pw.Text(
        //     //                 "Rx",
        //     //                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
        //     //               ),
        //     //               pw.SizedBox(height: 20),
        //     //               ...List.generate(
        //     //                 widget.prescription.prescribedMedicines.length,
        //     //                 (index) {
        //     //                   final prefMedicine = widget.prescription.prescribedMedicines[index];
        //     //                   return pw.Column(
        //     //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
        //     //                     children: [
        //     //                       pw.Text(
        //     //                         "${index + 1}. ${AppFunctions.getDosageString(
        //     //                           medicineName: prefMedicine.medicine.brandName,
        //     //                           dosageString: prefMedicine.dosage?.text,
        //     //                           dosageUnit: prefMedicine.dosage?.dosageUnit,
        //     //                         )}",
        //     //                         style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        //     //                       ),
        //     //                       pw.SizedBox(height: 1),
        //     //                       pw.Text(
        //     //                         AppFunctions.getFrequencyAndDurationString(
        //     //                           frequencyUnit: prefMedicine.frequency?.frequencyUnit,
        //     //                           duration: prefMedicine.duration?.text,
        //     //                           durationUnit: prefMedicine.duration?.durationUnit,
        //     //                           isAfterFood: prefMedicine.isAfterFood,
        //     //                           isBeforeFood: prefMedicine.isBeforeFood,
        //     //                           isEmptyStomach: prefMedicine.isEmptyStomach,
        //     //                         ),
        //     //                       ),
        //     //                       pw.SizedBox(height: 1),
        //     //                       if (prefMedicine.frequency != null &&
        //     //                           prefMedicine.frequency?.frequencyUnit.icon != null &&
        //     //                           prefMedicine.dosage != null &&
        //     //                           prefMedicine.dosage?.text != null &&
        //     //                           prefMedicine.dosage!.text!.isNotEmpty)
        //     //                         pw.Text(
        //     //                           PrescriptionUtils.getFrequencyIcon(
        //     //                               prefMedicine.frequency!.frequencyUnit.icon!, prefMedicine.dosage!),
        //     //                         ),
        //     //                       // if (prefMedicine.notes != null && prefMedicine.notes!.isNotEmpty)
        //     //                       //   pw.Text(prefMedicine.notes!),
        //     //                       pw.SizedBox(height: 7),
        //     //                     ],
        //     //                   );
        //     //                 },
        //     //               ),
        //     //               if (widget.prescription.notes != null && widget.prescription.notes!.isNotEmpty) ...[
        //     //                 // pw.Spacer(),
        //     //                 pw.SizedBox(height: widget.prescription.prescribedMedicines.length >= 5 ? 20 : 40),
        //     //                 // pw.Spacer(),
        //     //                 pw.Text("--"),
        //     //                 pw.SizedBox(height: 5),
        //     //                 pw.Text(
        //     //                   "Special Notes",
        //     //                   style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //     //                 ),
        //     //                 pw.SizedBox(height: 3),
        //     //                 pw.Text(widget.prescription.notes!),
        //     //               ],
        //     //             ],
        //     //           ),
        //     //         ),
        //     //         // ),
        //     //       ),
        //     //       pw.Expanded(
        //     //         flex: 1,
        //     //         child: pw.DecoratedBox(
        //     //           decoration: pw.BoxDecoration(
        //     //             border: pw.Border(
        //     //               left: pw.BorderSide(width: 1),
        //     //             ),
        //     //           ),
        //     //           child: pw.Padding(
        //     //             padding: pw.EdgeInsets.symmetric(horizontal: 8),
        //     //             child: pw.Column(
        //     //               crossAxisAlignment: pw.CrossAxisAlignment.start,
        //     //               children: [
        //     //                 if (widget.prescription.chiefComplaints.isNotEmpty) ...[
        //     //                   pw.Padding(
        //     //                     padding: pw.EdgeInsets.only(bottom: 20),
        //     //                     child: pw.Column(
        //     //                       crossAxisAlignment: pw.CrossAxisAlignment.start,
        //     //                       children: [
        //     //                         pw.Text(
        //     //                           "Chief Complaints",
        //     //                           style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //     //                         ),
        //     //                         pw.SizedBox(height: 5),
        //     //                         ...List.generate(
        //     //                           widget.prescription.chiefComplaints.length,
        //     //                           (index) {
        //     //                             final chiefComplaint = widget.prescription.chiefComplaints[index];
        //     //                             return pw.Text(
        //     //                               "${index + 1}. ${chiefComplaint.name}",
        //     //                             );
        //     //                           },
        //     //                         ),
        //     //                       ],
        //     //                     ),
        //     //                   )
        //     //                 ],
        //     //                 if (widget.prescription.clinicalFindings.isNotEmpty) ...[
        //     //                   pw.Padding(
        //     //                     padding: pw.EdgeInsets.only(bottom: 20),
        //     //                     child: pw.Column(
        //     //                       crossAxisAlignment: pw.CrossAxisAlignment.start,
        //     //                       children: [
        //     //                         pw.Text(
        //     //                           "Clinical Findings",
        //     //                           style: pw.TextStyle(
        //     //                             fontWeight: pw.FontWeight.bold,
        //     //                             fontSize: 14,
        //     //                           ),
        //     //                         ),
        //     //                         pw.SizedBox(height: 5),
        //     //                         ...List.generate(
        //     //                           widget.prescription.clinicalFindings.length,
        //     //                           (index) {
        //     //                             final clinicalFinding = widget.prescription.clinicalFindings[index];
        //     //                             return
        //     //                                 //  pw.Column(
        //     //                                 //   crossAxisAlignment: pw.CrossAxisAlignment.start,
        //     //                                 //   children: [
        //     //                                 pw.Text(
        //     //                               "${index + 1}. ${clinicalFinding.name}",
        //     //                             );
        //     //                             //   ],
        //     //                             // );
        //     //                           },
        //     //                         ),
        //     //                       ],
        //     //                     ),
        //     //                   ),
        //     //                 ],
        //     //                 if ((widget.prescription.temperature != null &&
        //     //                         widget.prescription.temperature!.isNotEmpty) ||
        //     //                     (widget.prescription.bloodPressure != null &&
        //     //                         widget.prescription.bloodPressure!.isNotEmpty) ||
        //     //                     (widget.prescription.heartRate != null && widget.prescription.heartRate!.isNotEmpty) ||
        //     //                     (widget.prescription.spO2 != null && widget.prescription.spO2!.isNotEmpty))
        //     //                   pw.Padding(
        //     //                     padding: pw.EdgeInsets.only(bottom: 20),
        //     //                     child: pw.Column(
        //     //                       crossAxisAlignment: pw.CrossAxisAlignment.start,
        //     //                       children: [
        //     //                         pw.Text(
        //     //                           "Vitals",
        //     //                           style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //     //                         ),
        //     //                         pw.SizedBox(height: 5),
        //     //                         if (widget.prescription.bloodPressure != null &&
        //     //                             widget.prescription.bloodPressure!.isNotEmpty) ...[
        //     //                           // pw.SizedBox(height: 5),
        //     //                           pw.Text(
        //     //                             "BP: ${widget.prescription.bloodPressure ?? "-"} mmHg",
        //     //                             // style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //     //                           ),
        //     //                         ],
        //     //                         if (widget.prescription.heartRate != null &&
        //     //                             widget.prescription.heartRate!.isNotEmpty) ...[
        //     //                           // pw.SizedBox(height: 5),
        //     //                           pw.Text(
        //     //                             "Heart Rate: ${widget.prescription.heartRate ?? "-"} bpm",
        //     //                             // style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //     //                           ),
        //     //                         ],
        //     //                         if (widget.prescription.temperature != null &&
        //     //                             widget.prescription.temperature!.isNotEmpty) ...[
        //     //                           // pw.SizedBox(height: 5),
        //     //                           pw.Text(
        //     //                             "Temp: ${widget.prescription.temperature ?? "-"}°F",
        //     //                             // style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //     //                           ),
        //     //                         ],
        //     //                         if (widget.prescription.spO2 != null && widget.prescription.spO2!.isNotEmpty) ...[
        //     //                           // pw.SizedBox(height: 5),
        //     //                           pw.Text(
        //     //                             "SpO2: ${widget.prescription.spO2 ?? "-"}%",
        //     //                             // style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //     //                           ),
        //     //                         ],
        //     //                       ],
        //     //                     ),
        //     //                   ),
        //     //                 if (widget.prescription.investigations.isNotEmpty) ...[
        //     //                   pw.Text(
        //     //                     "Investigations",
        //     //                     style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        //     //                   ),
        //     //                   pw.SizedBox(height: 5),
        //     //                   ...List.generate(
        //     //                     widget.prescription.investigations.length,
        //     //                     (index) {
        //     //                       final investigation = widget.prescription.investigations[index];
        //     //                       return pw.Column(
        //     //                         crossAxisAlignment: pw.CrossAxisAlignment.start,
        //     //                         children: [
        //     //                           pw.Text(
        //     //                             "${index + 1}. ${investigation.name}",
        //     //                           ),
        //     //                         ],
        //     //                       );
        //     //                     },
        //     //                   ),
        //     //                   pw.SizedBox(height: 20),
        //     //                 ],
        //     //                 // pw.Spacer(),
        //     //               ],
        //     //             ),
        //     //           ),
        //     //         ),
        //     //       )
        //     //     ],
        //     //   )
        //     // ],
        //     footer: (context) => pw.Column(
        //       children: [
        //         pw.Divider(),
        //         pw.Row(
        //           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        //           crossAxisAlignment: pw.CrossAxisAlignment.end,
        //           children: [
        //             if (widget.prescription.qrData != null)
        //               pw.Container(
        //                 height: 60,
        //                 width: 60,
        //                 decoration: pw.BoxDecoration(
        //                   image: pw.DecorationImage(
        //                     image: pw.MemoryImage(widget.prescription.qrData!),
        //                     fit: pw.BoxFit.cover,
        //                   ),
        //                 ),
        //               ),
        //             pw.Container(
        //               // color: PdfColors.amber,
        //               padding: pw.EdgeInsets.only(right: 8),
        //               child: pw.Column(
        //                 crossAxisAlignment: pw.CrossAxisAlignment.end,
        //                 children: [
        //                   if (widget.prescription.doctor != null && widget.prescription.doctor!.email == drAcharyaEmail)
        //                     pw.Center(
        //                       child: pw.Container(
        //                         child: doctorAcharyaSignatureImage,
        //                         height: 30,
        //                       ),
        //                     ),
        //                   pw.SizedBox(height: 2),
        //                   pw.SizedBox(
        //                     child: pw.Text(
        //                       "Dr. ${widget.prescription.doctor?.name ?? ""}",
        //                       style: pw.TextStyle(
        //                         fontSize: 12,
        //                         fontWeight: pw.FontWeight.bold,
        //                         color: AppTheme.pdfSecondaryColor,
        //                       ),
        //                     ),
        //                   ),
        //                   pw.SizedBox(height: 3),
        //                   pw.SizedBox(
        //                     child: pw.Text(
        //                       "${widget.prescription.doctor?.degree ?? ""}${widget.prescription.doctor?.licenseNumber != null ? "." : ""} ${widget.prescription.doctor?.licenseNumber ?? ""}",
        //                       style: pw.TextStyle(
        //                         fontSize: 10,
        //                       ),
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ],
        //         ),
        //         pw.Divider(),
        //         pw.Row(
        //           mainAxisAlignment: pw.MainAxisAlignment.center,
        //           children: [
        //             pw.Text(
        //               "Prescription made by ",
        //               style: pw.TextStyle(fontSize: 9),
        //             ),
        //             pw.Text(
        //               "Primacura",
        //               style: pw.TextStyle(
        //                 fontSize: 9,
        //                 fontWeight: pw.FontWeight.bold,
        //                 color: AppTheme.pdfPrimaryColor,
        //               ),
        //             )
        //           ],
        //         ),
        //       ],
        //     ),
        //   ),
        // );

        // pdf.addPage(
        pw.Page(
          margin: pw.EdgeInsets.all(15),
          build: (context) {
            return pw.Container(
                padding: pw.EdgeInsets.only(top: 20, left: 15, right: 15),
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                  color: PdfColor(0, 0, 0),
                  width: 1,
                )),
                child: pw.Center(
                  child: pw.Expanded(
                    child: pw.Column(
                      children: [
                        _buildHeader(clinicLogoImage, rodOfAsclepiusImage),
                        pw.SizedBox(height: 15),
                        pw.Divider(),
                        pw.SizedBox(height: 15),
                        // pw.Align(
                        //   alignment: pw.Alignment.topCenter,
                        // child:
                        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                          pw.Expanded(
                            flex: 2,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  "Name: ${widget.prescription.patient.name ?? ""}",
                                ),
                                pw.SizedBox(height: 5),
                                pw.Text(
                                  "Age: ${widget.prescription.patient.age ?? ""}",
                                ),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  children: [
                                    pw.Text(
                                      "Gender: ",
                                    ),
                                    pw.Text(
                                      widget.prescription.patient.gender?.substring(0, 1).toUpperCase() ?? "",
                                    ),
                                    pw.Text(
                                      widget.prescription.patient.gender?.substring(1).toLowerCase() ?? "",
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          if (widget.prescription.dateTime != null)
                            pw.Expanded(
                              flex: 1,
                              child: pw.Padding(
                                padding: pw.EdgeInsets.symmetric(horizontal: 8),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                        "Date: ${DateFormat("dd MMMM yyyy").format(widget.prescription.dateTime!)}"),
                                    pw.Text("Time: ${DateFormat.jmz().format(widget.prescription.dateTime!)}")
                                  ],
                                ),
                              ),
                            ),
                        ]),
                        // ),
                        pw.SizedBox(height: 20),
                        _buildBody(doctorAcharyaSignatureImage),
                        pw.SizedBox(height: 20),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text(
                              "Prescription made by ",
                              style: pw.TextStyle(fontSize: 9),
                            ),
                            pw.Text(
                              "Primacura",
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: AppTheme.pdfPrimaryColor,
                              ),
                            )
                          ],
                        ),
                        pw.SizedBox(height: 10),
                      ],
                    ),
                  ),
                ));
          },
        ),
      );
      savedPdf = await pdf.save();
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      if (!mounted) return;
      Utils.showSnackBar(context, Text("Error: $e"));
      log(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    generatePdf();
    super.initState();
  }

  void onDone() async {
    final prescriptionCubit = context.read<PrescriptionCubit>();

    try {
      await prescriptionCubit.addPrescriptionToLocalStorage();
      if (mounted) {
        context.go(HomeScreen.routeName);
      }
      prescriptionCubit.clearPatientAndPrescriptionDetails();
    } catch (e) {
      if (mounted) {
        Utils.showSnackBar(
          context,
          Text("An error occurred while saving the prescription"),
        );
      }
    }
    prescriptionCubit.getPrescriptions();
  }

  void onEdit() {
    final prescriptionCubit = context.read<PrescriptionCubit>();
    final prescription = widget.prescription;
    prescriptionCubit.clearPatientAndPrescriptionDetails();
    prescriptionCubit.onSelectPatient(prescription.patient);
    for (var chiefComplaint in prescription.chiefComplaints) {
      prescriptionCubit.onCheifComplaintSelected(chiefComplaint);
    }
    for (var clinicalFinding in prescription.clinicalFindings) {
      prescriptionCubit.onClinicalFindingSelected(clinicalFinding);
    }
    for (var investigation in prescription.investigations) {
      prescriptionCubit.onInvestigationSelected(investigation);
    }
    if (prescription.notes != null) {
      prescriptionCubit.addSpecialNote(prescription.notes!);
    }
    for (var prescriptionMedicine in prescription.prescribedMedicines) {
      prescriptionCubit.onMedicineAddForPrescription(
        medicine: prescriptionMedicine.medicine,
        prescribedDosage: prescriptionMedicine.dosage,
        prescribedFrequency: prescriptionMedicine.frequency,
        prescribedDuration: prescriptionMedicine.duration,
        isAfterFood: prescriptionMedicine.isAfterFood,
        isBeforeFood: prescriptionMedicine.isBeforeFood,
        isEmptyStomach: prescriptionMedicine.isEmptyStomach,
        notes: prescriptionMedicine.notes,
      );
    }
    context.goNamed(SelectPatientScreen.routeName);
    context.goNamed(EnterVitalsScreen.routeName);
  }

  pw.Widget _buildBody(pw.Image doctorSignatureImage) {
    final drAcharyaEmail = "acharya.ps@gmail.com";
    return pw.Expanded(
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              // color: PdfColor(1, 0.5, 0.5),

              child: pw.Padding(
                padding: pw.EdgeInsets.zero,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Rx",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
                    ),
                    pw.SizedBox(height: 20),
                    ...List.generate(
                      widget.prescription.prescribedMedicines.length,
                      (index) {
                        final prefMedicine = widget.prescription.prescribedMedicines[index];
                        return pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "${index + 1}. ${AppFunctions.getDosageString(
                                medicineName: prefMedicine.medicine.brandName,
                                dosageString: prefMedicine.dosage?.text,
                                dosageUnit: prefMedicine.dosage?.dosageUnit,
                              )}",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(height: 1),
                            pw.Text(
                              AppFunctions.getFrequencyAndDurationString(
                                frequencyUnit: prefMedicine.frequency?.frequencyUnit,
                                duration: prefMedicine.duration?.text,
                                durationUnit: prefMedicine.duration?.durationUnit,
                                isAfterFood: prefMedicine.isAfterFood,
                                isBeforeFood: prefMedicine.isBeforeFood,
                                isEmptyStomach: prefMedicine.isEmptyStomach,
                              ),
                            ),
                            pw.SizedBox(height: 1),
                            if (prefMedicine.frequency != null &&
                                prefMedicine.frequency?.frequencyUnit.icon != null &&
                                prefMedicine.dosage != null &&
                                prefMedicine.dosage?.text != null &&
                                prefMedicine.dosage!.text!.isNotEmpty)
                              pw.Text(
                                PrescriptionUtils.getFrequencyIcon(
                                    prefMedicine.frequency!.frequencyUnit.icon!, prefMedicine.dosage!),
                              ),
                            // if (prefMedicine.notes != null && prefMedicine.notes!.isNotEmpty)
                            //   pw.Text(prefMedicine.notes!),
                            pw.SizedBox(height: 7),
                          ],
                        );
                      },
                    ),
                    if (widget.prescription.notes != null && widget.prescription.notes!.isNotEmpty) ...[
                      // pw.Spacer(),
                      pw.SizedBox(height: widget.prescription.prescribedMedicines.length >= 5 ? 20 : 40),
                      // pw.Spacer(),
                      pw.Text("--"),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        "Special Notes",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(widget.prescription.notes!),
                    ],
                    pw.Spacer(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        if (widget.prescription.qrData != null)
                          pw.Container(
                            height: 60,
                            width: 60,
                            decoration: pw.BoxDecoration(
                              image: pw.DecorationImage(
                                image: pw.MemoryImage(widget.prescription.qrData!),
                                fit: pw.BoxFit.cover,
                              ),
                            ),
                          ),
                        pw.Container(
                          // color: PdfColors.amber,
                          padding: pw.EdgeInsets.only(right: 8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              if (widget.prescription.doctor != null &&
                                  widget.prescription.doctor!.email == drAcharyaEmail)
                                pw.Center(
                                  child: pw.Container(
                                    child: doctorSignatureImage,
                                    height: 30,
                                  ),
                                ),
                              pw.SizedBox(height: 2),
                              pw.SizedBox(
                                child: pw.Text(
                                  "Dr. ${widget.prescription.doctor?.name ?? ""}",
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: AppTheme.pdfSecondaryColor,
                                  ),
                                ),
                              ),
                              pw.SizedBox(height: 3),
                              pw.SizedBox(
                                child: pw.Text(
                                  "${widget.prescription.doctor?.degree ?? ""}${widget.prescription.doctor?.licenseNumber != null ? "." : ""} ${widget.prescription.doctor?.licenseNumber ?? ""}",
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.DecoratedBox(
              decoration: pw.BoxDecoration(
                // color: PdfColor(1, 1, 0.5),
                border: pw.Border(
                  left: pw.BorderSide(width: 1),
                ),
              ),
              child: pw.Padding(
                padding: pw.EdgeInsets.symmetric(horizontal: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (widget.prescription.chiefComplaints.isNotEmpty) ...[
                      pw.Padding(
                        padding: pw.EdgeInsets.only(bottom: 20),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Chief Complaints",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                            ),
                            pw.SizedBox(height: 5),
                            ...List.generate(
                              widget.prescription.chiefComplaints.length,
                              (index) {
                                final chiefComplaint = widget.prescription.chiefComplaints[index];
                                return
                                    // pw.Column(
                                    //   crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    //   children: [
                                    pw.Text(
                                  "${index + 1}. ${chiefComplaint.name}",
                                );
                                // ],
                                // );
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                    if (widget.prescription.clinicalFindings.isNotEmpty) ...[
                      pw.Padding(
                        padding: pw.EdgeInsets.only(bottom: 20),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Clinical Findings",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            ...List.generate(
                              widget.prescription.clinicalFindings.length,
                              (index) {
                                final clinicalFinding = widget.prescription.clinicalFindings[index];
                                return
                                    //  pw.Column(
                                    //   crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    //   children: [
                                    pw.Text(
                                  "${index + 1}. ${clinicalFinding.name}",
                                );
                                //   ],
                                // );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    if ((widget.prescription.temperature != null && widget.prescription.temperature!.isNotEmpty) ||
                        (widget.prescription.bloodPressure != null && widget.prescription.bloodPressure!.isNotEmpty) ||
                        (widget.prescription.heartRate != null && widget.prescription.heartRate!.isNotEmpty) ||
                        (widget.prescription.spO2 != null && widget.prescription.spO2!.isNotEmpty))
                      pw.Padding(
                        padding: pw.EdgeInsets.only(bottom: 20),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Vitals",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                            ),
                            pw.SizedBox(height: 5),
                            if (widget.prescription.bloodPressure != null &&
                                widget.prescription.bloodPressure!.isNotEmpty) ...[
                              // pw.SizedBox(height: 5),
                              pw.Text(
                                "BP: ${widget.prescription.bloodPressure ?? "-"} mmHg",
                                // style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                              ),
                            ],
                            if (widget.prescription.heartRate != null && widget.prescription.heartRate!.isNotEmpty) ...[
                              // pw.SizedBox(height: 5),
                              pw.Text(
                                "Heart Rate: ${widget.prescription.heartRate ?? "-"} bpm",
                                // style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                              ),
                            ],
                            if (widget.prescription.temperature != null &&
                                widget.prescription.temperature!.isNotEmpty) ...[
                              // pw.SizedBox(height: 5),
                              pw.Text(
                                "Temp: ${widget.prescription.temperature ?? "-"}°F",
                                // style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                              ),
                            ],
                            if (widget.prescription.spO2 != null && widget.prescription.spO2!.isNotEmpty) ...[
                              // pw.SizedBox(height: 5),
                              pw.Text(
                                "SpO2: ${widget.prescription.spO2 ?? "-"}%",
                                // style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                    if (widget.prescription.investigations.isNotEmpty) ...[
                      pw.Text(
                        "Investigations",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                      ),
                      pw.SizedBox(height: 5),
                      ...List.generate(
                        widget.prescription.investigations.length,
                        (index) {
                          final investigation = widget.prescription.investigations[index];
                          return pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                "${index + 1}. ${investigation.name}",
                              ),
                            ],
                          );
                        },
                      ),
                      pw.SizedBox(height: 20),
                    ],
                    pw.Spacer(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  pw.Widget _buildDoctorInfo() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.SizedBox(
          width: 180,
          child: pw.Text(
            "Dr. ${widget.prescription.doctor?.name ?? ""}",
            style: pw.TextStyle(
              fontSize: 17,
              fontWeight: pw.FontWeight.bold,
              color: AppTheme.pdfSecondaryColor,
            ),
          ),
        ),
        pw.SizedBox(height: 3),
        pw.SizedBox(
          width: 180,
          child: pw.Text(
            widget.prescription.doctor?.degree ?? "",
            style: pw.TextStyle(
              fontSize: null,
            ),
          ),
        ),
        pw.SizedBox(height: 3),
        if (widget.prescription.doctor?.specializations != null)
          ...List.generate(
            widget.prescription.doctor!.specializations.length,
            (index) => pw.SizedBox(
              width: 180,
              child: pw.Text(
                widget.prescription.doctor!.specializations[index].name,
                style: pw.TextStyle(
                  fontSize: null,
                ),
              ),
            ),
          ),
        if (widget.prescription.doctor?.licenseNumber != null) ...[
          pw.SizedBox(height: 3),
          pw.SizedBox(
            width: 180,
            child: pw.Text(
              "Reg No: ${widget.prescription.doctor?.licenseNumber ?? ""}",
              style: pw.TextStyle(
                fontSize: null,
              ),
            ),
          ),
        ]
      ],
    );
  }

  pw.Widget _buildHeader(pw.Image drAcharyaClinicLogo, pw.Image rodOfAsclepius) {
    final drAcharyaEmail = "acharya.ps@gmail.com";
    return pw.Column(children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: _buildDoctorInfo(),
          ),
          pw.SizedBox(width: 10),
          // pw.Spacer(),
          pw.Container(
            child: widget.prescription.doctor != null && widget.prescription.doctor!.email == drAcharyaEmail
                ? drAcharyaClinicLogo
                : rodOfAsclepius,
            height: widget.prescription.doctor != null && widget.prescription.doctor!.email == drAcharyaEmail ? 60 : 85,
          ),
          // pw.Spacer(),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.SizedBox(
                  width: 180,
                  child: pw.Text(
                    widget.prescription.doctor?.clinicName ?? "",
                    style: pw.TextStyle(fontSize: 20),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.SizedBox(
                  width: 180,
                  child: pw.Text(
                    widget.prescription.doctor?.clinicAddress ?? "",
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.SizedBox(
                  width: 180,
                  child: pw.Text(
                    widget.prescription.doctor?.clinicTimings ?? "",
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.SizedBox(
                  width: 180,
                  child: pw.Text(
                    widget.prescription.doctor?.phoneNumber ?? "",
                  ),
                ),
                // pw.SizedBox(height: 3),
                // pw.SizedBox(
                //   width: 180,
                //   child: pw.Text(widget.prescription.doctor?.email ?? ""),
                // ),
              ],
            ),
          ),
        ],
      ),
      // pw.Divider(),
    ]);
  }
}
