import 'package:auto_route/auto_route.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:opd_management/core/theme/app_theme.dart';
import 'package:opd_management/gen/assets.gen.dart';
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
  Trace? _loadingTrace;

  Future<void> initializeFirebasePerformance() async {
    if (kReleaseMode) {
      // Enable Performance Monitoring for production
      await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

      // Start tracking app loading time
      _loadingTrace = FirebasePerformance.instance.newTrace("after_splash_screen_app_loading_time");
      await _loadingTrace?.start();
    }
  }

  Future<void> stopFirebasePerformanceTrace() async {
    if (kReleaseMode && _loadingTrace != null) {
      await _loadingTrace?.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    initializeFirebasePerformance();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final authCubit = context.read<UserCubit>();
      await authCubit.checkAuthState();

      final state = authCubit.state;

      if (mounted) {
        if (state is UserAuthenticated) {
          context.go(HomeScreen.routeName);
        } else if (state is UserProfileNotCompleted) {
          context.go(EnterUserDetailsScreen.routeName);
        } else {
          context.go(LoginScreen.routeName);
        }
      }

      // Stop the trace after navigation is complete
      stopFirebasePerformanceTrace();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Expanded(
                flex: 1,
                child: Text(
                  "Primacura",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.secondaryColor),
                ),
              ),
              Expanded(
                flex: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Assets.icons.lazyMan,
                      height: 180,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Getting things ready...",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
