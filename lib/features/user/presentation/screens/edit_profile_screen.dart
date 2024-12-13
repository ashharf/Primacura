import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/utils.dart';
import '../../../home/presentation/widget/custom_autocomplete.dart';
import '../../data/models/specialization.dart';
import '../cubit/user_cubit.dart';
import '../provider/logo_and_signature_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static const String routeName = 'edit-profile';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController specializationController;
  late final TextEditingController licenseNumberController;
  late final TextEditingController clinicNameController;
  late final TextEditingController clinicAddressController;
  late final TextEditingController clinincTimingController;
  late final TextEditingController phoneNumberController;
  late final TextEditingController degreeController;

  @override
  void initState() {
    context.read<UserCubit>().getSpecializations();
    context.read<UserCubit>().addUserSpecializationToSelected();
    final userCubit = context.read<UserCubit>();
    final user = (userCubit.state as UserAuthenticated).user;
    nameController = TextEditingController(text: user.name);
    specializationController = TextEditingController();
    licenseNumberController = TextEditingController(text: user.licenseNumber);
    clinicNameController = TextEditingController(text: user.clinicName);
    clinicAddressController = TextEditingController(text: user.clinicAddress);
    clinincTimingController = TextEditingController(text: user.clinicTimings);
    phoneNumberController = TextEditingController(text: user.phoneNumber);
    degreeController = TextEditingController(text: user.degree);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LogoAndSignatureProvider>(
      create: (context) => LogoAndSignatureProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: ListView(
          padding: AppConstants.defaultPading,
          children: [
            Form(
              key: formKey,
              child: BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  final userCubit = context.read<UserCubit>();
                  return Column(
                    children: [
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
                            return 'Please enter your Name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
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
                      SizedBox(height: 20),
                      TextFormField(
                        controller: licenseNumberController,
                        decoration: const InputDecoration(
                          label: Text('License Number'),
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
                      SizedBox(height: 20),
                      TextFormField(
                        controller: clinicNameController,
                        decoration: const InputDecoration(
                          label: Text('Clinic Name'),
                          prefixIcon: Icon(
                            Icons.local_hospital,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: clinicAddressController,
                        keyboardType: TextInputType.streetAddress,
                        decoration: const InputDecoration(
                          label: Text('Clinic Address'),
                          prefixIcon: Icon(
                            FontAwesomeIcons.houseChimneyMedical,
                            size: 20,
                          ),
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: clinincTimingController,
                        decoration: const InputDecoration(
                          label: Text('Clinic Timings'),
                          prefixIcon: Icon(
                            FontAwesomeIcons.solidClock,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: phoneNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          label: Text('Phone Number'),
                          prefixIcon: Icon(
                            Icons.phone,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      CustomSearchableDropdown<Specialization>(
                        prefixIcon: Icon(
                          FontAwesomeIcons.userDoctor,
                          size: 20,
                        ),
                        hintText: "Search Specialization",
                        searchLogic: (searchQuery, items) {
                          final normalizedQuery = searchQuery.trim().toLowerCase();

                          // Separate exact matches and partial matches
                          final exactMatches = items.where((element) {
                            final normalizedBrandName = (element.name).trim().toLowerCase();
                            return normalizedBrandName == normalizedQuery;
                          }).toList();

                          final partialMatches = items.where((element) {
                            final normalizedBrandName = (element.name).trim().toLowerCase();
                            return normalizedBrandName.contains(normalizedQuery) &&
                                normalizedBrandName != normalizedQuery;
                          }).toList();

                          // Combine exact matches at the top, followed by partial matches
                          return [...exactMatches, ...partialMatches];
                        },
                        displayText: (item) => item.name,
                        textEditingController: specializationController,
                        textCapitalization: TextCapitalization.words,
                        items: context.read<UserCubit>().specializations,
                        onItemSelected: (item) {
                          // setState(() {
                          context.read<UserCubit>().selectSpecialization(item, isProfileEditing: true);
                          Future.delayed(Duration(milliseconds: 100), () {
                            specializationController.clear();
                          });
                          // });
                        },
                        onAddSelected: (searchText) {
                          final Specialization specialization = Specialization(
                            id: Uuid().v4(),
                            name: searchText,
                          );

                          context.read<UserCubit>().addSpecialization(specialization);
                          context.read<UserCubit>().selectSpecialization(specialization, isProfileEditing: true);
                          Future.delayed(Duration(milliseconds: 100), () {
                            specializationController.clear();
                          });
                          // setState(() {});
                        },
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 10,
                          children: List.generate(
                            userCubit.selectedSpecializations.length,
                            (index) => Chip(
                              backgroundColor: AppTheme.specializationChipColor,
                              label: Text(
                                userCubit.selectedSpecializations[index].name,
                                style: TextStyle(color: Colors.white),
                              ),
                              onDeleted: () => context.read<UserCubit>().deletedSelecteddSpecialization(
                                    userCubit.selectedSpecializations[index],
                                    isEditingProfile: true,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // LogoAndSignature(),
            // SizedBox(height: 100),
            BlocConsumer<UserCubit, UserState>(
              listener: (context, state) {
                // if (state is UserAuthenticated) {
                //   Navigator.of(context).pop();
                // }

                if (state is UserActionSuccess) {
                  Utils.showSnackBar(context, Text("Profile Updated Successfully"));
                  context.pop();
                }

                if (state is UserError) {
                  Utils.showSnackBar(context, Text(state.error));
                }
              },
              builder: (context, state) => ElevatedButton(
                // style: ElevatedButton.styleFrom(minimumSize: Size(300, 40)),
                onPressed: state is UserLoading
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          final userCubit = context.read<UserCubit>();
                          final user = (userCubit.state as UserAuthenticated).user;
                          final logoAndSignatureProvider = context.read<LogoAndSignatureProvider>();

                          String? logoUrl;
                          String? signatureUrl;
                          if (logoAndSignatureProvider.pickedlogo != null) {
                            try {
                              logoUrl = await userCubit.uploadImageAndGetUrl(logoAndSignatureProvider.pickedlogo!);
                            } catch (e) {
                              return;
                            }
                          }
                          if (logoAndSignatureProvider.pickedSignature != null) {
                            try {
                              signatureUrl =
                                  await userCubit.uploadImageAndGetUrl(logoAndSignatureProvider.pickedSignature!);
                            } catch (e) {
                              return;
                            }
                          }
                          final updatedUser = user.copyWith(
                            specializations: userCubit.selectedSpecializations,
                            licenseNumber: licenseNumberController.text.trim(),
                            clinicName: clinicNameController.text.trim(),
                            clinicAddress: clinicAddressController.text.trim(),
                            clinicTimings: clinincTimingController.text.trim(),
                            phoneNumber: phoneNumberController.text.trim(),
                            degree: degreeController.text.trim(),
                            name: nameController.text.trim(),
                            logoUrl: logoUrl,
                            signatureUrl: signatureUrl,
                          );

                          if (context.mounted) {
                            context.read<UserCubit>().updateUser(updatedUser);
                          }
                        }
                      },
                child: state is UserLoading ? CircularProgressIndicator() : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogoAndSignature extends StatelessWidget {
  const LogoAndSignature({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return Consumer<LogoAndSignatureProvider>(builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Logo",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: provider.pickedlogo != null
                        ? Image.file(
                            provider.pickedlogo!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                        : (state).user?.logoUrl != null
                            ? Image.network(
                                state.user!.logoUrl!,
                                height: 150,
                              )
                            : Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                height: 150,
                                width: 150,
                                child: Text("No Logo"),
                              ),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: provider.pickLogo,
                    child: Text("Change"),
                  )
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Signature",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: provider.pickedSignature != null
                        ? Image.file(
                            provider.pickedSignature!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                        : state.user?.signatureUrl != null
                            ? Image.network(
                                state.user!.signatureUrl!,
                                height: 150,
                              )
                            : Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                height: 150,
                                width: 150,
                                child: Text("No Signature"),
                              ),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: provider.pickSignature,
                    child: Text("Change"),
                  )
                ],
              ),
            ],
          );
        });
      },
    );
  }
}
