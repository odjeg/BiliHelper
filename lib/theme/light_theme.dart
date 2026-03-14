import 'package:flutter/material.dart';

class LightTheme {
  static final ThemeData theme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Noto Sans SC',

    colorScheme: ColorScheme.light(primary: Colors.white),

    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.all(Colors.grey),
    ),
  );
}
