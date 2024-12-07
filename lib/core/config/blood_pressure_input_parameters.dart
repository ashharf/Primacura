import 'package:flutter/services.dart';

class BloodPressureInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // If text is empty, just return as is
    if (newValue.text.isEmpty) return newValue;

    // Check if the last character was backspace and the new value is empty
    if (oldValue.text.length > newValue.text.length && newValue.text.isEmpty) {
      return TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }

    final text = newValue.text;

    // Split upper and lower values based on `/` if already present
    final parts = text.split('/');
    String upper = parts[0];
    String lower = parts.length > 1 ? parts[1] : '';

    // Upper value handling
    if (upper.isNotEmpty) {
      if (upper.length == 1) {
        // Start of the upper value, do nothing
      } else if (upper.length == 2) {
        // Check if it starts with 5-9 for a 2-digit upper value
        if (int.tryParse(upper[0])! >= 5 && !text.contains('/')) {
          upper += '/';
        }
      } else if (upper.length == 3) {
        // Check if it starts with 1 or 2 for a 3-digit upper value
        if ((upper.startsWith('1') || upper.startsWith('2')) && !text.contains('/')) {
          upper += '/';
        }
      } else {
        // Restrict to maximum 3 digits for upper value
        upper = upper.substring(0, 3);
      }
    }

    // Lower value handling
    if (lower.isNotEmpty) {
      if (lower.length == 1) {
        // Start of the lower value, do nothing
      } else if (lower.length == 2) {
        // Check if it starts with 3-9 for a 2-digit lower value
        if (int.tryParse(lower[0])! >= 3) {
          lower = lower.substring(0, 2);
        }
      } else if (lower.length == 3) {
        // Check if it starts with 1 or 2 for a 3-digit lower value
        if (lower.startsWith('1') || lower.startsWith('2')) {
          lower = lower.substring(0, 3);
        } else {
          lower = lower.substring(0, 2); // Restrict to 2 digits otherwise
        }
      } else {
        // Restrict to maximum 3 digits for lower value
        lower = lower.substring(0, 3);
      }
    }

    // Concatenate the parts
    final formattedText = lower.isNotEmpty ? '$upper/$lower' : upper;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
