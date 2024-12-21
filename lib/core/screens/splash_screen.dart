import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          return;
        }
        if (state is UserProfileNotCompleted) {
          context.go(EnterUserDetailsScreen.routeName);
          return;
        }
        context.go(LoginScreen.routeName);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Text("Getting things ready..."),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
