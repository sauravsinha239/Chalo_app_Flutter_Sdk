import 'package:flutter/material.dart';
class MyThemes{
  static final darkTheme= ThemeData(
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(),
  );
   static final lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.transparent,
  colorScheme: const ColorScheme.light(),
   );
}

