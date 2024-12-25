import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/utils.dart';
import '../../../../gen/assets.gen.dart';
import '../../../patients/presentation/screens/home_screen.dart';
import '../providers/user_provider.dart';
import 'enter_user_details_screen.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: AppConstants.defaultPading,
        child: Center(
          child: Column(
            // padding: AppConstatns.defaultPading,
            children: [
              const Spacer(flex: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                child: Image.asset(
                  Assets.icons.appLogo.path,
                  height: 200,
                ),
              ),
              const Spacer(flex: 1),
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return userProvider.isLoading
                      ? const CircularProgressIndicator()
                      : OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              await userProvider.signInWithGoogle();
                              if (context.mounted) {
                                if (userProvider.user == null) {
                                  return;
                                } else if (userProvider.user!.licenseNumber == null) {
                                  context.go(EnterUserDetailsScreen.routeName);
                                  return;
                                } else {
                                  context.go(HomeScreen.routeName);
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Utils.showSnackBar(context, Text(e.toString()));
                              }
                            }
                          },
                          label: const Text("Sign In with Google"),
                          icon: SvgPicture.asset(
                            height: 30,
                            Assets.icons.googleIcon,
                          ),
                        );
                },
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
