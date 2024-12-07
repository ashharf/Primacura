import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import '../../features/user/presentation/screens/enter_user_details_screen.dart';
import '../../features/user/presentation/cubit/user_cubit.dart';
import '../../features/home/presentation/screens/home_screen.dart';

import '../../features/user/presentation/screens/login_screen.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  static const routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((time) async {
      final authCubit = context.read<UserCubit>();
      await authCubit.checkAuthState();

      final state = authCubit.state;

      if (mounted) {
        if (state is UserAuthenticated) {
          context.go(HomeScreen.routeName);
          FlutterNativeSplash.remove();
          return;
        }
        if (state is UserProfileNotCompleted) {
          context.go(EnterUserDetailsScreen.routeName);
          FlutterNativeSplash.remove();
          return;
        }
        context.go(LoginScreen.routeName);
        FlutterNativeSplash.remove();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
