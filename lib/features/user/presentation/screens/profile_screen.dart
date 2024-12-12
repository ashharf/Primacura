import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../home/presentation/screens/all_patients_screen.dart';
import '../../../../core/constants/constants.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubit/user_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    context.read<UserCubit>().getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        actions: [
          IconButton(
            onPressed: () {
              context.goNamed(EditProfileScreen.routeName);
            },
            icon: const Icon(Icons.edit, size: 25),
          )
        ],
      ),
      body: BlocConsumer<UserCubit, UserState>(listener: (context, state) {
        if (state is UserUnauthenticated) {
          context.go(LoginScreen.routeName);
        }
      }, builder: (context, state) {
        if (state is UserAuthenticated) {
          final user = (context.read<UserCubit>().state as UserAuthenticated).user;
          return ListView(
            padding: AppConstants.defaultPading,
            children: [
              // const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  FontAwesomeIcons.stethoscope,
                  size: 20,
                ),
                title: Text("Name"),
                subtitle: Text(user.name ?? "-"),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  FontAwesomeIcons.graduationCap,
                  size: 20,
                ),
                title: Text("Degree"),
                subtitle: Text(user.degree ?? "-"),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  FontAwesomeIcons.idCard,
                  size: 20,
                ),
                title: Text("License Number"),
                subtitle: Text(user.licenseNumber ?? "-"),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.email),
                title: Text("Email"),
                subtitle: Text(user.email),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone),
                title: Text("Phone"),
                subtitle: Text(user.phoneNumber ?? "-"),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.local_hospital,
                ),
                title: Text("Clinic Name"),
                subtitle: Text(user.clinicName ?? "-"),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  FontAwesomeIcons.houseChimneyMedical,
                  size: 20,
                ),
                title: Text("Clinic Address"),
                subtitle: Text(user.clinicAddress ?? "-"),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  FontAwesomeIcons.solidClock,
                  size: 20,
                ),
                title: Text("Clinic Timings"),
                subtitle: Text(user.clinicTimings ?? "-"),
              ),
              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: const Icon(
              //     FontAwesomeIcons.image,
              //     size: 20,
              //   ),
              //   title: Text("Signature and Logo"),
              //   subtitle: user.logoUrl != null || user.signatureUrl != null
              //       ? Row(
              //           children: [
              //             if (user.logoUrl != null)
              //               ClipRRect(
              //                 borderRadius: BorderRadius.circular(8),
              //                 child: Image.network(
              //                   user.logoUrl!,
              //                   height: 30,
              //                 ),
              //               ),
              //             if (user.signatureUrl != null) ...[
              //               SizedBox(width: 10),
              //               ClipRRect(
              //                 borderRadius: BorderRadius.circular(8),
              //                 child: Image.network(
              //                   user.signatureUrl!,
              //                   height: 30,
              //                 ),
              //               ),
              //             ]
              //           ],
              //         )
              //       : null,
              // ),

              // SizedBox(height: 20),
              Text(
                user.specializations.length > 1 ? "Specializations" : "Specialization",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 5,
                children: user.specializations
                    .map(
                      (e) => Chip(
                        backgroundColor: AppTheme.specializationChipColor,
                        label: Text(
                          e.name,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppTheme.primaryColor),
                ),
                leading: Icon(FontAwesomeIcons.bedPulse, size: 20),
                title: Text("My Patients"),
                subtitle: Text("Manage all Patients"),
                trailing: Icon(Icons.arrow_forward_rounded),
                onTap: () => context.goNamed(AllPatientsScreen.routeName),
              ),
              SizedBox(height: 20.h),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Are you sure you want to sign out?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                context.read<UserCubit>().signOut();
                              },
                              child: Text("Sign Out"),
                            ),
                          ],
                        );
                      });
                },
                child: Text("Sign Out"),
              ),
              SizedBox(height: 20),
            ],
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      }),
    );
  }
}
