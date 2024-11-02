import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class MyThemes{
  static final darkTheme= ThemeData(
    scaffoldBackgroundColor: Colors.black,
    colorScheme:  const ColorScheme.dark(),
    textTheme: GoogleFonts.openSansTextTheme(
      ThemeData.dark().textTheme,
    ),

  );
   static final lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.transparent,
  colorScheme: const ColorScheme.light(),
     textTheme: GoogleFonts.openSansTextTheme(
       ThemeData.light().textTheme,
     ),
   );
}

