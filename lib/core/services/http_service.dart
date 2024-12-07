import 'dart:convert';

import 'package:http/http.dart' as http;

import 'exception.dart';

class HttpService {
  static const Duration _timeOutDuration = Duration(hours: 1);
  static Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    final response = await http.get(Uri.parse(url), headers: headers).timeout(_timeOutDuration);
    return _returnResponse(response);
  }

  static Future<dynamic> post(String url, {Map<String, String>? headers, dynamic body}) async {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    return _returnResponse(response);
  }

  static Future<dynamic> put(String url, {Map<String, String>? headers, dynamic body}) async {
    final response = await http.put(Uri.parse(url), headers: headers, body: body).timeout(_timeOutDuration);
    return _returnResponse(response);
  }

  static dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final responseJson = jsonDecode(response.body);
        return responseJson;
      case 201:
        final responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        // final error = jsonDecode(response.body)["error"];
        throw BadRequestException(
          jsonDecode(response.body)['error'] == null
              ? response.body.toString()
              : jsonDecode(response.body)['error'].toString(),
        );
      case 403:
        throw UnauthorisedException(
          jsonDecode(response.body)['error'] == null
              ? response.body.toString()
              : jsonDecode(response.body)['error'].toString(),
        );
      case 404:
        throw UnauthorisedException(
          jsonDecode(response.body)['error'] == null
              ? response.body.toString()
              : jsonDecode(response.body)['error'].toString(),
        );
      case 408:
        throw TimeoutException(
          jsonDecode(response.body)['error'] == null
              ? response.body.toString()
              : jsonDecode(response.body)['error'].toString(),
        );
      // case 500:
      default:
        throw FetchDataException('Error occured while communication with server'
            ' with status code : ${response.statusCode}');
    }
  }
}
