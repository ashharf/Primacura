import 'package:flutter/foundation.dart' show ChangeNotifier;

class LoadingProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  void setLoading(bool value, {bool notifyListeners = true}) {
    _isLoading = value;
    if (notifyListeners) this.notifyListeners();
  }

  void setUpdating(bool value, {bool notifyListeners = true}) {
    _isUpdating = value;
    if (notifyListeners) this.notifyListeners();
  }
}
