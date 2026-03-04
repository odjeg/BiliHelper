import 'package:flutter/foundation.dart';

class LotteryController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _title = '';
  String get title => _title;
  set title(String value) {
    _title = value;
    notifyListeners();
  }

  int _total = 0;
  int get total => _total;
  set total(int value) {
    _total = value;
    notifyListeners();
  }
}
