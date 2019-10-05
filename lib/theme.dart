import 'package:flutter/material.dart';

// Light colors
final Color lightPrimary = Color(0xfffcfcff);
final Color lightAccent = Colors.blueGrey[900];
final Color lightBackground = Color(0xfffcfcff);

// Dark colors
final Color darkPrimary = Colors.black;
final Color darkAccent = Colors.white;
final Color darkBackground = Colors.black;

final Color badgeColor = Colors.red;

// Light application theme
final ThemeData light = ThemeData(
  backgroundColor: lightBackground,
  primaryColor: lightPrimary,
  accentColor: lightAccent,
  cursorColor: const Color(0x1F000000),
  scaffoldBackgroundColor: lightBackground,
  buttonColor: dark.buttonColor,
  fontFamily: 'SF Pro Display',
  appBarTheme: AppBarTheme(
    elevation: 0,
    textTheme: TextTheme(
      title: TextStyle(
        color: darkBackground,
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
    ),
  ),
);

// Dark application theme
final ThemeData dark = ThemeData(
  brightness: Brightness.dark,
  backgroundColor: darkBackground,
  primaryColor: darkPrimary,
  accentColor: darkAccent,
  scaffoldBackgroundColor: darkBackground,
  cursorColor: Colors.white10,
  fontFamily: 'SF Pro Display',
  appBarTheme: AppBarTheme(
    elevation: 0,
    textTheme: TextTheme(
      title: TextStyle(
        color: lightBackground,
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
    ),
  ),
);
