import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class LogoAndSignatureProvider extends ChangeNotifier {
  File? pickedlogo;
  File? pickedSignature;
  Future<void> pickLogo() async {
    pickedlogo = await pickImage();
    notifyListeners();
  }

  Future<void> pickSignature() async {
    pickedSignature = await pickImage();
    notifyListeners();
  }

  Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    return File(image.path);
  }
}
