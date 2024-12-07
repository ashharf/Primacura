import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;

class GoogleDriveService {
  Future<String> _getAccessToken() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['https://www.googleapis.com/auth/drive.file'],
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('User not signed in');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    return googleAuth.accessToken!;
  }

  Future<http.Client> _createAuthenticatedClient(String accessToken) async {
    final http.Client baseClient = http.Client();

    final auth.AccessCredentials credentials = auth.AccessCredentials(
      auth.AccessToken('Bearer', accessToken, DateTime.now().toUtc().add(Duration(hours: 1))),
      null,
      ['https://www.googleapis.com/auth/drive.file'],
    );

    return auth.authenticatedClient(baseClient, credentials);
  }

  Future<drive.DriveApi> _createDriveApi() async {
    final String accessToken = await _getAccessToken();
    final http.Client client = await _createAuthenticatedClient(accessToken);
    final drive.DriveApi driveApi = drive.DriveApi(client);
    return driveApi;
  }

  Future<drive.File> uploadFile(String fileName, String fileContent) async {
    try {
      final drive.DriveApi driveApi = await _createDriveApi();

      final drive.File file = drive.File();
      file.name = fileName;

      final Stream<List<int>> mediaStream = Stream.fromIterable([
        fileContent.codeUnits,
      ]);

      final drive.Media media = drive.Media(mediaStream, fileContent.length);

      final uploadedFile = await driveApi.files.create(file, uploadMedia: media);
      return uploadedFile;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkIfFileExists(String fileName) async {
    try {
      final drive.DriveApi driveApi = await _createDriveApi();
      final response = await driveApi.files.list(
        q: "name = '$fileName'",
      );
      if (response.files!.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Object> downloadFile(String fileId) async {
    final drive.DriveApi driveApi = await _createDriveApi();
    final media = await driveApi.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    );

    return media;
  }
}
