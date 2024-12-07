import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  Brightness get getCurrentThemeBrightness {
    final currentThemeBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return currentThemeBrightness;
  }
}
