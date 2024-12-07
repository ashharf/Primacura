import 'package:opd_management/features/home/data/models/patient.dart';
import 'package:opd_management/features/home/data/models/units.dart';

class PrescriptionUtils {
  PrescriptionUtils._();
  static String getFrequencyIcon(String frequencyIconInString, PrescriptionDosage dosage) {
    if (dosage.text == null || dosage.text!.isEmpty) {
      return "";
    }
    String dosageString = "${dosage.text ?? ""} ${dosage.dosageUnit?.name ?? ""}";
    if (dosage.dosageUnit?.name == "Tablets") {
      dosageString = "${dosage.text ?? ""} Tab";
    }
    if (dosage.dosageUnit?.name == "Capsules") {
      dosageString = "${dosage.text ?? ""} Cap";
    }
    if (frequencyIconInString.isNotEmpty) {
      // Split the frequency string by the separator '-'
      final parts = frequencyIconInString.split('-');

      // Replace '1' with the dosage symbol and keep '0' as it is
      final updatedParts = parts
          .map(
            (part) => part.trim() == '1' ? dosageString : part.trim(),
          )
          .toList();

      // Join the parts back with the separator '-'
      return updatedParts.join(' - ');
    }
    return '';
  }

  static String getGenderString(Gender gender) {
    return "${gender.name.substring(0, 1).toUpperCase()}${gender.name.substring(1).toLowerCase()}";
  }

  static Gender getGenderFromString(String genderString) {
    // Normalize the input string to lowercase to ensure case insensitivity
    final normalized = genderString.toLowerCase();

    // Match the normalized string to the Gender enum
    if (normalized == Gender.male.name) {
      return Gender.male;
    } else if (normalized == Gender.female.name) {
      return Gender.female;
    } else if (normalized == Gender.other.name) {
      return Gender.other;
    } else {
      throw ArgumentError("Invalid gender string: $genderString");
    }
  }
}
