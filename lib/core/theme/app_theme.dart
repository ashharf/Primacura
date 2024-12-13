import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

class AppTheme {
  static const int _primaryColorInt = 0XFF5A81FA;
  static const int _secondaryColorInt = 0XFF2C3D8F;
  static const int _tertiaryColorInt = 0XFFd6dffe;

  static const Color primaryColor = Color(_primaryColorInt);
  static const Color secondaryColor = Color(_secondaryColorInt);
  static const Color tertiaryColor = Color(_tertiaryColorInt);

  static const PdfColor pdfPrimaryColor = PdfColor.fromInt(_primaryColorInt);
  static const PdfColor pdfSecondaryColor = PdfColor.fromInt(_secondaryColorInt);

  static Color specializationChipColor = AppTheme.primaryColor.withOpacity(0.8);

  static const Size elevatedButtonSize = Size(double.infinity, 50);

  static Color darkBackgroundColor = Colors.grey.shade900;
  static Color lightBackgroundColor = Colors.white;

  static final ThemeData lightThemeData = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: AppTheme.primaryColor,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: lightBackgroundColor,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(lightBackgroundColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: elevatedButtonSize,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
        side: const BorderSide(
          color: AppTheme.primaryColor,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
    ),
    dialogBackgroundColor: tertiaryColor,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData darkThemeData = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackgroundColor,
    primaryColor: AppTheme.primaryColor,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.grey.shade900,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(darkBackgroundColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: elevatedButtonSize,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
        side: const BorderSide(
          color: AppTheme.primaryColor,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
    ),
  );
}
