import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:opd_management/features/user/data/models/user.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/utils.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../theme/provider/theme_provider.dart';
import '../../data/models/specialization.dart';
import '../cubit/user_cubit.dart';

class EnterUserDetailsScreen extends StatefulWidget {
  const EnterUserDetailsScreen({super.key});

  static const routeName = '/enter-user-details';

  @override
  State<EnterUserDetailsScreen> createState() => _EnterUserDetailsScreenState();
}

class _EnterUserDetailsScreenState extends State<EnterUserDetailsScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController specializationController;
  late final TextEditingController licenseNumberController;
  late final TextEditingController clinicNameController;
  late final TextEditingController clinicAddressController;
  late final TextEditingController clinicTimeController;
  late final TextEditingController phoneNumberController;
  late final TextEditingController degreeController;

  @override
  void initState() {
    final userCubit = context.read<UserCubit>();
    // final prescriptionCubit = context.read<PrescriptionCubit>();
    userCubit.getSpecializations();
    userCubit.addUserSpecializationToSelectedAtCompleteYourProfile();
    // prescriptionCubit.syncUnitsFromRemote();
    final User user = (userCubit.state as UserProfileNotCompleted).user;
    nameController = TextEditingController(text: user.name);
    specializationController = TextEditingController();
    licenseNumberController = TextEditingController(text: user.licenseNumber);
    clinicNameController = TextEditingController(text: user.clinicName);
    clinicAddressController = TextEditingController(text: user.clinicAddress);
    clinicTimeController = TextEditingController(text: user.clinicTimings);
    phoneNumberController = TextEditingController(text: user.phoneNumber);
    degreeController = TextEditingController(text: user.degree);

    super.initState();
  }

  @override
  void dispose() {
    formKey.currentState?.dispose();

    nameController.dispose();
    specializationController.dispose();
    licenseNumberController.dispose();
    clinicNameController.dispose();
    clinicAddressController.dispose();
    clinicTimeController.dispose();
    phoneNumberController.dispose();
    degreeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete your Profile'),
      ),
      body: Form(
        key: formKey,
        child: BlocConsumer<UserCubit, UserState>(
          listener: (context, state) {
            if (state is UserError) {
              Utils.showSnackBar(context, Text((state).error));
            }
          },
          builder: (context, state) {
            final userCubit = context.read<UserCubit>();

            return ListView(
              padding: AppConstants.defaultPading,
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(
                      FontAwesomeIcons.stethoscope,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Name. It will appear on Prescriptions';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Autocomplete<Specialization>(
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    // specializationController = textEditingController;
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                          labelText: 'Specialization',
                          prefixIcon: Icon(
                            FontAwesomeIcons.userDoctor,
                            size: 20,
                          )
                          // border: OutlineInputBorder(),
                          ),
                      validator: (value) {
                        final userCubit = context.read<UserCubit>();
                        if (userCubit.selectedSpecializations.isEmpty) {
                          return 'Please enter a specialization';
                        }
                        return null;
                      },
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: context.read<ThemeProvider>().getCurrentThemeBrightness == Brightness.light
                            ? AppTheme.lightBackgroundColor
                            : AppTheme.darkBackgroundColor,
                        elevation: 4,
                        child: SizedBox(
                          height: 200,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                title: Text(option.name),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Specialization>.empty();
                    }

                    final specializations = context.read<UserCubit>().specializations;
                    // specializations.removeWhere(
                    //   (item) => userCubit.selectedSpecializations.contains(item),
                    // );

                    return specializations.where(
                      (specialization) => specialization.name.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          ),
                    );
                  },
                  displayStringForOption: (Specialization specialization) => "",
                  onSelected: (value) {
                    context.read<UserCubit>().selectSpecialization(value);
                    // specializationController.clear();
                  },
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: List.generate(
                    userCubit.selectedSpecializations.length,
                    (index) => Chip(
                      backgroundColor: AppTheme.specializationChipColor,
                      label: Text(
                        userCubit.selectedSpecializations[index].name,
                        style: TextStyle(color: Colors.white),
                      ),
                      onDeleted: () => context
                          .read<UserCubit>()
                          .deletedSelecteddSpecialization(userCubit.selectedSpecializations[index]),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: degreeController,
                  decoration: const InputDecoration(
                    labelText: 'Degree',
                    prefixIcon: Icon(
                      FontAwesomeIcons.graduationCap,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your degree. It will appear on Prescriptions';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: licenseNumberController,
                  decoration: const InputDecoration(
                    labelText: 'License Number',
                    prefixIcon: Icon(
                      FontAwesomeIcons.idCard,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your license number. It will appear on Prescriptions';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: clinicNameController,
                  decoration: const InputDecoration(
                    labelText: 'Clinic Name',
                    prefixIcon: Icon(
                      Icons.local_hospital,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: clinicAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Clinic Address',
                    prefixIcon: Icon(
                      FontAwesomeIcons.houseChimneyMedical,
                      size: 20,
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: clinicTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Clinic Timings',
                    prefixIcon: Icon(
                      FontAwesomeIcons.solidClock,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                BlocConsumer<UserCubit, UserState>(
                  listener: (context, state) {
                    if (state is UserAuthenticated) {
                      context.go(HomeScreen.routeName);
                    }
                  },
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is UserLoading
                          ? null
                          : () {
                              if (formKey.currentState!.validate()) {
                                final licenseNumber = licenseNumberController.text.trim();
                                final clinicName = clinicNameController.text.trim();
                                final clinicAddress = clinicAddressController.text.trim();
                                final clinicTime = clinicTimeController.text.trim();
                                final phoneNumber = phoneNumberController.text.trim();
                                final degree = degreeController.text.trim();
                                final updatedUser = (userCubit.state as UserProfileNotCompleted).user.copyWith(
                                      licenseNumber: licenseNumber,
                                      clinicName: clinicName,
                                      clinicAddress: clinicAddress,
                                      clinicTimings: clinicTime,
                                      phoneNumber: phoneNumber,
                                      specializations: userCubit.selectedSpecializations,
                                      degree: degree,
                                    );
                                context.read<UserCubit>().updateUser(updatedUser);
                              }
                            },
                      child: state is UserLoading ? CircularProgressIndicator() : const Text('Save'),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
