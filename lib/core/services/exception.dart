class AppException implements Exception {
  final String? _message;
  final String? _prefix;

  AppException([this._message, this._prefix]);

  @override
  String toString() {
    return "${_prefix ?? ""}${_message ?? ""}";
  }
}

class FetchDataException extends AppException {
  FetchDataException([super.message]);
}

class BadRequestException extends AppException {
  BadRequestException([super.smessage]);
}

class UnauthorisedException extends AppException {
  UnauthorisedException([super.smessage]);
}

class TimeoutException extends AppException {
  TimeoutException([super.smessage]);
}

class InvalidInputException extends AppException {
  InvalidInputException([super.message]);
}

class LocalDatabaseError extends AppException {
  LocalDatabaseError([super.message]);
}
