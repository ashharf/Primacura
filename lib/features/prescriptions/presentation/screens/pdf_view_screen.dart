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
import '../../../theme/provider/theme_provider.dart';
import '../../data/models/prescription.dart';
import '../providers/prescriptions_provider.dart';
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
  final _pdf = pw.Document(title: "Prescription");
  Uint8List? _savedPdf;
  bool _isLoading = false;

  @override
  void initState() {
    generatePdf();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prescription.patient.name ?? ""),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _savedPdf == null
              ? Center(
                  child: Text("No Prescription Found"),
                )
              : InteractiveViewer(
                  maxScale: 5,
                  child: PdfPreview(
                    scrollViewDecoration: BoxDecoration(
                      color: context.read<ThemeProvider>().currentThemeBrightness == Brightness.light
                          ? AppTheme.lightBackgroundColor
                          : AppTheme.darkBackgroundColor,
                    ),
                    build: (format) => _savedPdf!,
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
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> generatePdf() async {
    setState(() {
      _isLoading = true;
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
      _pdf.addPage(
        pw.MultiPage(
          theme: pw.ThemeData(
            defaultTextStyle: pw.TextStyle(fontSize: 10),
          ),
          margin: pw.EdgeInsets.all(30),
          header: (context) => _buildHeader(clinicLogoImage, rodOfAsclepiusImage),
          build: (context) => _buildBody(),
          footer: (context) => _buildFooter(doctorAcharyaSignatureImage, drAcharyaEmail),
        ),
      );

      _savedPdf = await _pdf.save();
    } on PlatformException catch (e) {
      throw e.message ?? "Something went wrong";
    } catch (e) {
      if (!mounted) return;
      Utils.showSnackBar(context, Text("Error: $e"));
      log(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<pw.Widget> _buildBody() {
    return [
      pw.DecoratedBox(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 1, color: PdfColors.black),
        ),
        child: pw.Padding(
          padding: pw.EdgeInsets.all(6),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Name: ${widget.prescription.patient.name ?? ""}, ${widget.prescription.patient.age ?? ""}",
                    ),
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
                        pw.Text("Date: ${DateFormat("dd MMMM yyyy").format(widget.prescription.dateTime!)}"),
                        pw.Text("Time: ${DateFormat.jmz().format(widget.prescription.dateTime!)}")
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      pw.SizedBox(height: 10),
      if (widget.prescription.chiefComplaints.isNotEmpty) ...[
        pw.Padding(
          padding: pw.EdgeInsets.only(bottom: 5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Chief Complaints",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.SizedBox(
                width: double.maxFinite,
                child: pw.Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  children: List.generate(
                    widget.prescription.chiefComplaints.length,
                    (index) {
                      final chiefComplaint = widget.prescription.chiefComplaints[index];
                      return pw.Text(
                        "${index + 1}. ${chiefComplaint.name}",
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        )
      ],
      if (widget.prescription.clinicalFindings.isNotEmpty) ...[
        pw.Padding(
          padding: pw.EdgeInsets.only(bottom: 5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Clinical Findings",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Wrap(
                spacing: 8,
                runSpacing: 2,
                children: List.generate(
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
          padding: pw.EdgeInsets.only(bottom: 5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Vitals",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Wrap(
                runSpacing: 2,
                spacing: 8,
                children: [
                  if (widget.prescription.bloodPressure != null && widget.prescription.bloodPressure!.isNotEmpty) ...[
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
                  if (widget.prescription.temperature != null && widget.prescription.temperature!.isNotEmpty) ...[
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
              )
            ],
          ),
        ),
      if (widget.prescription.investigations.isNotEmpty) ...[
        pw.Padding(
          padding: pw.EdgeInsets.only(bottom: 0),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(
              "Investigations",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            pw.Wrap(
              spacing: 8,
              runSpacing: 2,
              children: List.generate(
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
            ),
          ]),
        )

        // pw.SizedBox(height: 20),
      ],
      pw.Divider(),
      pw.Text(
        "Rx",
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 5),
      pw.Table(
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        border: pw.TableBorder.all(),
        columnWidths: {
          0: pw.FlexColumnWidth(0.23),
          1: pw.FlexColumnWidth(1.3),
          2: pw.FlexColumnWidth(1.5),
          3: pw.FlexColumnWidth(0.6),
          4: pw.FlexColumnWidth(0.8),
        },
        children: [
          // Header Row
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(4),
                child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                  pw.Text(
                    'No.',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ]),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Medicine',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Dosage',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.Padding(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Duration',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  )),
              pw.Padding(
                padding: pw.EdgeInsets.all(4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Notes',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),

          ...List.generate(widget.prescription.prescribedMedicines.length, (index) {
            final prefMedicine = widget.prescription.prescribedMedicines[index];
            final bool isFrequencyEmpty =
                prefMedicine.frequency != null && prefMedicine.frequency?.frequencyUnit.icon != null;
            final bool isDosageEmpty = prefMedicine.dosage != null &&
                prefMedicine.dosage?.text != null &&
                prefMedicine.dosage!.text!.isNotEmpty;
            return pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Text("${index + 1}"),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Text(
                    AppFunctions.getDosageString(
                      medicineName: prefMedicine.medicine.brandName,
                      dosageString: prefMedicine.dosage?.text,
                      dosageUnit: prefMedicine.dosage?.dosageUnit,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (prefMedicine.frequency != null)
                        pw.Text(
                          AppFunctions.getFrequencyString(frequencyUnit: prefMedicine.frequency!.frequencyUnit),
                          style: pw.TextStyle(fontSize: 9),
                        ),
                      isFrequencyEmpty && isDosageEmpty
                          ? pw.Text(
                              "${PrescriptionUtils.getFrequencyIcon(prefMedicine.frequency!.frequencyUnit.icon!, prefMedicine.dosage!)} ${AppFunctions.getFoodState(
                                isAfterFood: prefMedicine.isAfterFood,
                                isBeforeFood: prefMedicine.isBeforeFood,
                                isEmptyStomach: prefMedicine.isEmptyStomach,
                              )}",
                              style: pw.TextStyle(fontSize: 9),
                            )
                          : pw.Text(
                              AppFunctions.getFoodState(
                                isAfterFood: prefMedicine.isAfterFood,
                                isBeforeFood: prefMedicine.isBeforeFood,
                                isEmptyStomach: prefMedicine.isEmptyStomach,
                              ),
                            )
                    ],
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Text(
                    AppFunctions.getDurationString(
                        duration: prefMedicine.duration?.text, durationUnit: prefMedicine.duration?.durationUnit),
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Text(
                    prefMedicine.notes != null && prefMedicine.notes!.isNotEmpty ? prefMedicine.notes! : '',
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      if (widget.prescription.notes != null && widget.prescription.notes!.isNotEmpty) ...[
        // pw.Spacer(),
        pw.SizedBox(height: 10),
        // pw.Spacer(),

        pw.Text(
          "Special Notes",
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 3),
        pw.Text(widget.prescription.notes!),
      ],
    ];
  }

  void onDone() async {
    final prescriptionProvider = context.read<PrescriptionsProvider>();

    try {
      await prescriptionProvider.addPrescriptionToLocalStorage();
      if (mounted) {
        context.go(HomeScreen.routeName);
      }

      prescriptionProvider.clearPatientAndPrescriptionDetails();
    } catch (e) {
      if (mounted) {
        Utils.showSnackBar(
          context,
          Text("An error occurred while saving the prescription"),
        );
      }
    }
    prescriptionProvider.getPrescriptions();
  }

  void onEdit() {
    final prescriptionProvider = context.read<PrescriptionsProvider>();
    final prescription = widget.prescription;
    prescriptionProvider.clearPatientAndPrescriptionDetails();
    prescriptionProvider.onSelectPatient(prescription.patient);
    for (var chiefComplaint in prescription.chiefComplaints) {
      prescriptionProvider.onCheifComplaintSelected(chiefComplaint);
    }
    for (var clinicalFinding in prescription.clinicalFindings) {
      prescriptionProvider.onClinicalFindingSelected(clinicalFinding);
    }
    for (var investigation in prescription.investigations) {
      prescriptionProvider.onInvestigationSelected(investigation);
    }
    if (prescription.notes != null) {
      prescriptionProvider.addSpecialNote(prescription.notes!);
    }
    for (var prescriptionMedicine in prescription.prescribedMedicines) {
      prescriptionProvider.onMedicineAddForPrescription(
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
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: AppTheme.pdfSecondaryColor,
            ),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.SizedBox(
          width: 180,
          child: pw.Text(
            widget.prescription.doctor?.degree ?? "",
            style: pw.TextStyle(
              fontSize: 12,
            ),
          ),
        ),
        pw.SizedBox(height: 2),
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
          pw.SizedBox(height: 2),
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
                    style: pw.TextStyle(fontSize: 15),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.SizedBox(
                  width: 180,
                  child: pw.Text(
                    widget.prescription.doctor?.clinicAddress ?? "",
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.SizedBox(
                  width: 180,
                  child: pw.Text(
                    widget.prescription.doctor?.clinicTimings ?? "",
                  ),
                ),
                pw.SizedBox(height: 2),
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
      pw.Divider(),
    ]);
  }

  pw.Widget _buildFooter(pw.Widget doctorAcharyaSignatureImage, String drAcharyaEmail) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            if (widget.prescription.qrData != null)
              pw.Container(
                height: 50,
                width: 50,
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
                  if (widget.prescription.doctor != null && widget.prescription.doctor!.email == drAcharyaEmail)
                    pw.Center(
                      child: pw.Container(
                        child: doctorAcharyaSignatureImage,
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
        ),
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              "Prescription made by ",
              style: pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              "Primacura",
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: AppTheme.pdfPrimaryColor,
              ),
            )
          ],
        ),
      ],
    );
  }
}
