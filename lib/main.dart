import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/config/scroll_pyhsics.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/home/data/data_source/patient_local_data_source.dart';
import 'features/home/data/data_source/prescription_local_data_source.dart';
import 'features/home/data/data_source/prescription_remote_data_source.dart';
import 'features/home/data/repository/patients_repository.dart';
import 'features/home/data/repository/prescription_repository.dart';
import 'features/home/presentation/providers/patients_provider.dart';
import 'features/home/presentation/providers/prescriptions_provider.dart';
import 'features/theme/provider/theme_provider.dart';
import 'features/user/data/data_source/user_local_data_source.dart';
import 'features/user/data/data_source/user_remote_data_source.dart';
import 'features/user/data/repository/user_repository.dart';
import 'features/user/presentation/providers/user_provider.dart';
import 'firebase_options.dart';

void main() async {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kReleaseMode) {
    // Track app startup time
    // Enable Performance Monitoring for production
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    final trace = FirebasePerformance.instance.newTrace("app_startup_time");
    await trace.start();

    await Hive.initFlutter();
    final hivePatientBox = await Hive.openBox('patients');
    final hiveMedicinesBox = await Hive.openBox('medicines');
    final hivePrescriptionsBox = await Hive.openBox('prescriptions');
    final hiveDosageBox = await Hive.openBox('dosages');
    final hiveFrequencyBox = await Hive.openBox('frequency');
    final hiveDurationBox = await Hive.openBox('duration');
    final hiveAccessTokenBox = await Hive.openBox<String>('accessToken');
    // Enable Crashlytics for production
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    FlutterNativeSplash.remove();

    runApp(
      Primacura(
        hivePatientBox: hivePatientBox,
        hiveMedicinesBox: hiveMedicinesBox,
        hivePrescriptionsBox: hivePrescriptionsBox,
        hiveDosageBox: hiveDosageBox,
        hiveFrequencyBox: hiveFrequencyBox,
        hiveDurationBox: hiveDurationBox,
        hiveAccessTokenBox: hiveAccessTokenBox,
      ),
    );
    await trace.stop();
  } else {
    // Disable in non-production modes
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    FirebasePerformance.instance.setPerformanceCollectionEnabled(false);

    await Hive.initFlutter();
    final hivePatientBox = await Hive.openBox('patients');
    final hiveMedicinesBox = await Hive.openBox('medicines');
    final hivePrescriptionsBox = await Hive.openBox('prescriptions');
    final hiveDosageBox = await Hive.openBox('dosages');
    final hiveFrequencyBox = await Hive.openBox('frequency');
    final hiveDurationBox = await Hive.openBox('duration');
    final hiveAccessTokenBox = await Hive.openBox<String>('accessToken');

    FlutterNativeSplash.remove();
    runApp(
      Primacura(
        hivePatientBox: hivePatientBox,
        hiveMedicinesBox: hiveMedicinesBox,
        hivePrescriptionsBox: hivePrescriptionsBox,
        hiveDosageBox: hiveDosageBox,
        hiveFrequencyBox: hiveFrequencyBox,
        hiveDurationBox: hiveDurationBox,
        hiveAccessTokenBox: hiveAccessTokenBox,
      ),
    );
  }
}

class Primacura extends StatelessWidget {
  static final router = AppRoutes.getRouter();
  final Box hivePatientBox;
  final Box hiveMedicinesBox;
  final Box hivePrescriptionsBox;
  final Box hiveDosageBox;
  final Box hiveFrequencyBox;
  final Box hiveDurationBox;
  final Box<String> hiveAccessTokenBox;

  const Primacura({
    super.key,
    required this.hivePatientBox,
    required this.hiveMedicinesBox,
    required this.hivePrescriptionsBox,
    required this.hiveDosageBox,
    required this.hiveFrequencyBox,
    required this.hiveDurationBox,
    required this.hiveAccessTokenBox,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(1024, 720),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => ThemeProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => UserProvider(
              userRepository: UserRepositoryImpl(
                userRemoteDataSource: UserRemoteDataSource(
                  googleSignIn: GoogleSignIn(),
                  firebaseAuth: FirebaseAuth.instance,
                  firebaseFirestore: FirebaseFirestore.instance,
                ),
                userLocalDataSource: UserLocalDataSource(
                  hiveMedicinesBox: hiveMedicinesBox,
                  hiveAccessTokenBox: hiveAccessTokenBox,
                ),
              ),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => PatientsProvider(
              patientRepository: PatientRepositoryWithLocalDatabaseImpl(
                patientLocalDataSource: PatientLocalDataSource(
                  hivePatientBox: hivePatientBox,
                ),
              ),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => PrescriptionsProvider(
              prescriptionRepository: PrescriptionRepositoryImpl(
                prescriptionRemoteDataSource: PrescriptionRemoteDataSource(
                  firebaseFirestore: FirebaseFirestore.instance,
                ),
                prescriptionLocalDataSource: PrescriptionLocalDataSource(
                  hivePrescriptionBox: hivePrescriptionsBox,
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
        child: Builder(builder: (context) {
          return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
            bool isLightTheme = themeProvider.currentThemeBrightness == Brightness.light;
            return MaterialApp.router(
              scrollBehavior: BouncyScrollBehavior(),
              title: 'Primacura',
              debugShowCheckedModeBanner: false,
              theme: isLightTheme ? AppTheme.lightThemeData : AppTheme.darkThemeData,
              routerConfig: router,
            );
          });
        }),
      ),
    );
  }
}
