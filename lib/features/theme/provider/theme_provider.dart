import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  Brightness get currentThemeBrightness {
    final currentThemeBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return currentThemeBrightness;
  }
}
