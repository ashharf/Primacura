import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/utils.dart';
import '../../../../gen/assets.gen.dart';
import '../../../theme/provider/theme_provider.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/screens/profile_screen.dart';
import '../cubit/patient_cubit.dart';
import '../cubit/prescription_cubit.dart';
import '../widget/prescription_card.dart';
import 'qr_scanner_screen.dart';
import 'select_patient_screen.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateRangePickerController _controller = DateRangePickerController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prescriptionCubit = context.read<PrescriptionCubit>();
      final patientCubit = context.read<PatientCubit>();

      patientCubit.getPatients();
      prescriptionCubit.getMedicinesFromRemoteDataSource();
      prescriptionCubit.getUnits();
      prescriptionCubit.getPrescriptions();
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            return Column(
              children: [
                Text("Dashboard", style: Theme.of(context).textTheme.titleMedium),
                if (state is UserAuthenticated)
                  Text(
                    (context.read<UserCubit>().state as UserAuthenticated).user.clinicName ?? "",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            );
          },
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            child: Image.asset(Assets.icons.appLogo.path),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.goNamed(QrScannerScreen.routeName);
            },
            icon: Icon(
              Icons.qr_code_scanner_rounded,
              size: 30,
            ),
          ),
          IconButton(
            onPressed: () {
              context.goNamed(ProfileScreen.routeName);
            },
            icon: BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                return state is UserAuthenticated
                    ? (state).user.name != null && (state).user.name!.isNotEmpty
                        ? CircleAvatar(
                            backgroundColor: AppTheme.tertiaryColor,
                            child: Text(
                              (state).user.name?.substring(0, 1).toUpperCase() ?? "",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: context.read<ThemeProvider>().currentThemeBrightness == Brightness.dark
                                        ? Colors.black
                                        : null,
                                  ),
                            ),
                          )
                        : Icon(
                            Icons.account_circle,
                            size: 35,
                          )
                    : Icon(
                        Icons.account_circle,
                        size: 35,
                      );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: AppConstants.defaultPadding,
              height: 300,
              child: SfDateRangePicker(
                headerStyle: DateRangePickerHeaderStyle(
                  backgroundColor: context.read<ThemeProvider>().currentThemeBrightness == Brightness.light
                      ? Colors.white
                      : Colors.grey.shade900,
                ),
                showNavigationArrow: true,
                controller: _controller,
                view: DateRangePickerView.month,
                monthViewSettings: DateRangePickerMonthViewSettings(
                  showTrailingAndLeadingDates: true,
                  firstDayOfWeek: 1,
                ),
                initialSelectedDate: DateTime.now(),
                selectionColor: AppTheme.primaryColor,
                todayHighlightColor: AppTheme.tertiaryColor,
                backgroundColor: context.read<ThemeProvider>().currentThemeBrightness == Brightness.light
                    ? AppTheme.lightBackgroundColor
                    : AppTheme.darkBackgroundColor,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs dateRangePickerSelectionChangedArgs) {
                  context.read<PrescriptionCubit>().selectedDateToShowPrescriptions =
                      dateRangePickerSelectionChangedArgs.value;
                  context.read<PrescriptionCubit>().getPrescriptions();
                },
              ),
            ),
            SizedBox(height: 10.h),
            Text("Your Appointments", style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 5.h),
            Padding(
              padding: AppConstants.defaultPadding,
              child: BlocConsumer<PrescriptionCubit, PrescriptionState>(
                listener: (context, state) {
                  if (state.message != null) {
                    Utils.showSnackBar(context, Text(state.message ?? "Something went wrong"));
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: List.generate(
                      state.filteredPrescriptions.length,
                      (index) {
                        final prescription = state.filteredPrescriptions[index];
                        return PrescriptionCard(prescription: prescription);
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: AppConstants.defaultPadding.copyWith(bottom: 20, top: 10),
          child: ElevatedButton(
            onPressed: () {
              context.goNamed(SelectPatientScreen.routeName);
            },
            child: Text(
              "+ Add Patient",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
