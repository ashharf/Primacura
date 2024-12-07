import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {
  static void removeSnackBar(BuildContext context) {
    return ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(BuildContext context, Widget content,
      {Color? backgroundColor, SnackBarAction? action, Duration? duration}) {
    removeSnackBar(context);
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration ?? const Duration(seconds: 4),
        margin: const EdgeInsets.all(8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: backgroundColor ?? Colors.grey.shade500,

        content: Align(alignment: Alignment.center, child: content),
        action: action,
        // backgroundColor: kTextFieldColor,
      ),
    );
  }

  static ScaffoldFeatureController<MaterialBanner, MaterialBannerClosedReason> showMaterialBanner(
      BuildContext context, Widget content,
      {Color? backgroundColor, List<Widget>? actions, Duration? duration}) {
    hideCurrentMaterialBanner(context);
    return ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: backgroundColor,
        content: content,
        actions: actions ?? [],
      ),
    );
  }

  static void hideCurrentMaterialBanner(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  }

  static Size screenDimensions(BuildContext context) {
    return MediaQuery.sizeOf(context);
  }

  static TextTheme textTheme(BuildContext context) {
    return Theme.of(context).textTheme;
  }

  static TextStyle? largeTitle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge;
  }

  static TextStyle? mediumTitle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium;
  }

  static TextStyle? smallTitle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall;
  }

  // static bool isPadScreen(context) {
  //   return screenDimensions(context).width >= kTabBreakPoint;
  // }

  // static bool isSmallScreen(context) {
  //   return screenDimensions(context).width <= kMobileBreakPoint;
  // }

  // static bool isMediumScreen(context) {
  //   return screenDimensions(context).width >= kPadBreakPoint && screenDimensions(context).width < kDesktopBreakPoint;
  // }

  // static bool isLargeScreen(context) {
  //   return screenDimensions(context).width >= kDesktopBreakPoint;
  // }

  static String dateFormat(String time) {
    DateTime dateTime = DateTime.parse(time);

    // Get the current DateTime
    DateTime now = DateTime.now();

    // Calculate the time difference
    Duration diff = now.difference(dateTime);

    // Calculate the number of days and hours

    int hoursDiff = diff.inHours;

    // Check if it's within the last 24 hours
    if (hoursDiff < 24) {
      // Check if the message was sent before midnight

      DateTime nextMidnight = DateTime(now.year, now.month, now.day);

      if (dateTime.isAfter(nextMidnight)) {
        // return 'Today';
        DateFormat('hh:mm a').format(dateTime);
      } else {
        String dayName = DateFormat('EE').format(dateTime);
        String date = DateFormat('MMMM d').format(dateTime);
        return '$dayName, $date';
      }
    }

    // Otherwise, return the day name and date

    String dayName = DateFormat('EE').format(dateTime);
    String date = DateFormat('MMMM d').format(dateTime);
    return '$dayName, $date';
  }
}
