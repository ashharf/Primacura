import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../home/data/data_source/prescription_local_data_source.dart';
import '../../home/data/data_source/prescription_remote_data_source.dart';
import '../../home/data/models/prescription.dart';
import '../../home/data/repository/prescription_repository.dart';
import '../../home/presentation/providers/prescriptions_provider.dart';

class PrimacuraAdminPanel extends StatelessWidget {
  final Box prescriptionBox;
  final Box hiveMedicinesBox;
  final Box hiveDosageBox;
  final Box hiveFrequencyBox;
  final Box hiveDurationBox;
  final Box<String> hiveAccessTokenBox;

  const PrimacuraAdminPanel({
    super.key,
    required this.prescriptionBox,
    required this.hiveMedicinesBox,
    required this.hiveDosageBox,
    required this.hiveFrequencyBox,
    required this.hiveDurationBox,
    required this.hiveAccessTokenBox,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => PrescriptionsProvider(
              prescriptionRepository: PrescriptionRepositoryImpl(
                prescriptionRemoteDataSource: PrescriptionRemoteDataSource(
                  firebaseFirestore: FirebaseFirestore.instance,
                ),
                prescriptionLocalDataSource: PrescriptionLocalDataSource(
                  hivePrescriptionBox: prescriptionBox,
                  hiveMedicineBox: hiveMedicinesBox,
                  hiveDosageBox: hiveDosageBox,
                  hiveFrequencyBox: hiveFrequencyBox,
                  hiveDurationBox: hiveDurationBox,
                  hiveAccessTokenBox: hiveAccessTokenBox,
                ),
              ),
            ),
          ),
        ],
        child: const AdminPanel(),
      ),
    );
  }
}

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: StreamBuilder(
          stream: _firestore.collection('prescriptions').orderBy('dateTime', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs;
            if (docs == null) {
              return Center(
                child: Text('No data'),
              );
            }

            return Column(
              spacing: 10,
              children: [
                Text("Total Prescriptions: ${docs.length.toString()}"),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final prescription = Prescription.fromJson(doc.data());
                      return GestureDetector(
                        onLongPressStart: (details) async {
                          log(details.localPosition.dx.toString());
                          log(details.localPosition.dy.toString());
                          HapticFeedback.mediumImpact();
                          final response = await showMenu<String>(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              details.globalPosition.dx,
                              details.globalPosition.dy,
                              details.globalPosition.dx,
                              details.globalPosition.dy,
                            ),
                            items: [
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          );
                          if (!context.mounted) return;
                          if (response == 'delete') {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Delete Confirmation'),
                                  content: Text('Are you sure you want to delete this prescription?'),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Delete'),
                                      onPressed: () async {
                                        await _firestore
                                            .collection(AppConstants.prescriptionsCollection)
                                            .doc(doc.id)
                                            .delete();
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: Card(
                          child: ListTile(
                            leading: prescription.dateTime != null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        DateFormat.MMMEd().format(prescription.dateTime!),
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        "${DateFormat('hh:mm').format(prescription.dateTime!)} ${DateFormat('a').format(prescription.dateTime!)}",
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                            title: Text(
                              "${prescription.patient.gender ?? "-"}, ${prescription.patient.age ?? "-"}",
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                prescription.prescribedMedicines.length,
                                (index) => Text(
                                  prescription.prescribedMedicines[index].medicine.brandName,
                                ),
                              ),
                            ),
                            trailing: Text(
                              prescription.doctor?.name ?? "-",
                              style: TextStyle(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
    );
  }
}
