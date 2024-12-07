import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class UploadFileService {
  final FirebaseStorage firebaseStorage;

  UploadFileService({required this.firebaseStorage});
  Future<String> uploadImageToFirebaseStorage(File file, String userId) async {
    try {
      final storageRef = firebaseStorage.ref().child('images/$userId/${file.path}');
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw e.message ?? "Can't upload image to Firebase Storage";
    } catch (e) {
      rethrow;
    }
  }
}
