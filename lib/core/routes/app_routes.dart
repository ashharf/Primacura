import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/data/models/prescription.dart';
import '../../features/home/presentation/screens/pdf_view_screen.dart';
import '../../features/home/presentation/screens/prescription_review_screen.dart';
import '../../features/home/presentation/screens/add_medicines_screen.dart';

import '../../features/home/presentation/screens/add_patient_screen.dart';
import '../../features/home/presentation/screens/all_patients_screen.dart';
import '../../features/home/presentation/screens/edit_patient_screen.dart';
import '../../features/home/presentation/screens/enter_vitals_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/qr_scanner_screen.dart';
import '../../features/home/presentation/screens/select_patient_screen.dart';
import '../../features/user/presentation/screens/edit_profile_screen.dart';
import '../../features/user/presentation/screens/enter_user_details_screen.dart';
import '../../features/user/presentation/screens/login_screen.dart';
import '../../features/user/presentation/screens/profile_screen.dart';
import '../screens/splash_screen.dart';

class AppRoutes {
  static GoRouter getRouter() {
    return GoRouter(
      // debugLogDiagnostics: true,
      initialLocation: SplashScreen.routeName,
      routes: <RouteBase>[
        GoRoute(
          path: SplashScreen.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return const SplashScreen();
          },
        ),
        GoRoute(
            path: HomeScreen.routeName,
            builder: (BuildContext context, GoRouterState state) {
              return const HomeScreen();
            },
            routes: [
              GoRoute(
                  // path: "${EnterPatientDetailsScreen.routeName}/:phoneNumber",
                  path: SelectPatientScreen.routeName,
                  name: SelectPatientScreen.routeName,
                  builder: (BuildContext context, GoRouterState state) {
                    // return EnterPatientDetailsScreen(phoneNumber: state.pathParameters['phoneNumber']!);
                    return const SelectPatientScreen();
                  },
                  routes: [
                    GoRoute(
                        path: EnterVitalsScreen.routeName,
                        name: EnterVitalsScreen.routeName,
                        builder: (BuildContext context, GoRouterState state) {
                          return const EnterVitalsScreen();
                        },
                        routes: [
                          GoRoute(
                              path: AddMedicinesScreen.routeName,
                              name: AddMedicinesScreen.routeName,
                              builder: (BuildContext context, GoRouterState state) {
                                return const AddMedicinesScreen();
                              },
                              routes: [
                                GoRoute(
                                    path: PrescriptionReviewScreen.routeName,
                                    name: PrescriptionReviewScreen.routeName,
                                    builder: (BuildContext context, GoRouterState state) {
                                      return const PrescriptionReviewScreen();
                                    })
                              ])
                        ]),
                  ]),
              GoRoute(
                  path: ProfileScreen.routeName,
                  name: ProfileScreen.routeName,
                  builder: (BuildContext context, GoRouterState state) {
                    return const ProfileScreen();
                  },
                  routes: [
                    GoRoute(
                        path: EditProfileScreen.routeName,
                        name: EditProfileScreen.routeName,
                        builder: (BuildContext context, GoRouterState state) {
                          return const EditProfileScreen();
                        }),
                    GoRoute(
                        path: AllPatientsScreen.routeName,
                        name: AllPatientsScreen.routeName,
                        builder: (BuildContext context, GoRouterState state) {
                          return const AllPatientsScreen();
                        },
                        routes: [
                          GoRoute(
                              path: AddPatientScreen.routeName,
                              name: AddPatientScreen.routeName,
                              builder: (BuildContext context, GoRouterState state) {
                                return const AddPatientScreen();
                              }),
                          GoRoute(
                            path: "${EditPatientScreen.routeName}/:patientId",
                            name: EditPatientScreen.routeName,
                            builder: (BuildContext context, GoRouterState state) {
                              return EditPatientScreen(patientId: state.pathParameters['patientId']!);
                            },
                          ),
                        ]),
                  ]),
              GoRoute(
                  path:
                      //  PdfViewScreen.routeName,
                      PdfViewScreen.routeName,
                  name: PdfViewScreen.routeName,
                  builder: (BuildContext context, GoRouterState state) {
                    final extra = state.extra as List;
                    final Prescription prescription = extra[0] as Prescription;
                    final bool showDoneButton = extra[1] as bool;
                    return PdfViewScreen(
                      prescription: prescription,
                      showDoneButton: showDoneButton,
                    );
                  }),
              GoRoute(
                  path: QrScannerScreen.routeName,
                  name: QrScannerScreen.routeName,
                  builder: (BuildContext context, GoRouterState state) {
                    return const QrScannerScreen();
                  }),
            ]),
        GoRoute(
          path: LoginScreen.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return const LoginScreen();
          },
        ),
        GoRoute(
            path: EnterUserDetailsScreen.routeName,
            name: EnterUserDetailsScreen.routeName,
            builder: (BuildContext context, GoRouterState state) {
              return const EnterUserDetailsScreen();
            })
      ],
    );
  }
}

// class AppRoutes extends RootStackRouter {
//   @override
//   List<AutoRoute> get routes => [
//         AutoRoute(
//           path: SplashScreen.routeName,
//           page: SplashScreen.page,
//           initial: true,
//         ),
//         AutoRoute(
//           path: HomeScreen.routeName,
//           page: HomeScreen,
//           children: [
//             AutoRoute(
//               path: SelectPatientScreen.routeName,
//               page: SelectPatientScreen,
//             ),
//           ],
//         ),
//         AutoRoute(
//           path: LoginScreen.routeName,
//           page: LoginScreen,
//         ),
//       ];
// }
