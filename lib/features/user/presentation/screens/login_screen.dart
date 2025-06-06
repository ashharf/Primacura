import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/utils.dart';
import '../../../../gen/assets.gen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../cubit/user_cubit.dart';
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
      body: BlocListener<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserError) {
            Utils.showSnackBar(context, Text(state.error));
          }
          if (state is UserAuthenticated) {
            context.go(HomeScreen.routeName);
          }
          if (state is UserProfileNotCompleted) {
            context.go(EnterUserDetailsScreen.routeName);
          }
          if (state is UserAuthError) {
            log('Error: ${state.error}');
            Utils.showSnackBar(context, Text(state.error));
          }
        },
        child: Padding(
          padding: AppConstants.defaultPadding,
          child: Center(
            child: Column(
              // padding: AppConstants.defaultPadding,
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
                BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) {
                    return state is UserLoading
                        ? const CircularProgressIndicator()
                        : OutlinedButton.icon(
                            onPressed: () {
                              context.read<UserCubit>().signInWithGoogle();
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
      ),
    );
  }
}
