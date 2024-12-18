import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CustomProgressIndicator extends StatelessWidget {
  final int currentStep; // The current screen number (1-based index)
  final int totalSteps; // Total number of screens
  final double width; // Width of the entire progress indicator

  const CustomProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.width = 300, // Default width
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // Constrain the width of the progress indicator
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Space between dots and lines
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index % 2 == 0) {
            // Dots
            final stepIndex = index ~/ 2;
            final isActive = stepIndex < currentStep; // Highlight dots up to the current step
            return Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryColor : Colors.grey,
                shape: BoxShape.circle,
              ),
            );
          } else {
            // Lines between dots
            final lineIndex = (index - 1) ~/ 2;
            final isActive = lineIndex < currentStep - 1; // Highlight lines up to the current step
            return Container(
              height: 2,
              width: (width - (20 * totalSteps)) / (totalSteps - 1), // Dynamically calculate line width
              color: isActive ? AppTheme.primaryColor : Colors.grey,
            );
          }
        }),
      ),
    );
  }
}
