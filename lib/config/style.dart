import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle {
  static final TextStyle fontFamily = GoogleFonts.outfit();

  static const ColorScheme colorScheme = ColorScheme.light();

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    useMaterial3: true,

    colorScheme: colorScheme,

    // text field decoration
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.blueGrey.shade100, width: 1)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.blueGrey.shade100, width: 1)),
      filled: true,
      fillColor: Colors.blueGrey.shade50,
    ),

    textTheme: GoogleFonts.outfitTextTheme(),

    appBarTheme: AppBarTheme(
      titleTextStyle: fontFamily.copyWith(fontSize: 22, color: Colors.black),
    ),

    dividerTheme: DividerThemeData(
      color: Colors.blueGrey.shade200.withOpacity(.8),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
      side: BorderSide(width: .5, color: colorScheme.secondary),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
    )),

    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    )),
  );
}
