import 'package:flutter/foundation.dart';
import 'package:bilibilihelper/controllers/load_status.dart';

class FollowingsController extends ChangeNotifier {
  LoadStatus _loadStatus = LoadStatus.none;
  LoadStatus get loadStatus => _loadStatus;
  set loadStatus(LoadStatus value) {
    _loadStatus = value;
    notifyListeners();
  }

  int _total = 0;
  int get total => _total;
  set total(int value) {
    _total = value;
    notifyListeners();
  }
}
