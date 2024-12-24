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
  FetchDataException([String? message]) : super(message, "Error During Communication: Please try again");
}

class BadRequestException extends AppException {
  BadRequestException([String? message]) : super(message, "Bad Request: Please try again");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([String? message]) : super(message, "Unauthorised request Please try again");
}

class TimeoutException extends AppException {
  TimeoutException([String? message]) : super(message, "Timeout: Please check your internet connection");
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message]) : super(message ?? "Invalid input");
}

class LocalDatabaseException extends AppException {
  LocalDatabaseException([String? message]) : super(message ?? "An error occurred while accessing the local database");
}

class UnknownErrorException extends AppException {
  UnknownErrorException([String? message]) : super(message ?? "An unknown error occurred");
}
