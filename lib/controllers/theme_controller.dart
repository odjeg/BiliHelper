import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode currThemeMode = ThemeMode.system;
  get themeMode => currThemeMode;
  set themeMode(ThemeMode mode) {
    currThemeMode = mode;
    notifyListeners();
  }
}
