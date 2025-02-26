import 'package:flutter/material.dart';

final ThemeData elderTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    primary: Colors.blue,
    secondary: Colors.green,
    tertiary: Colors.orange,
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 24),
    bodyMedium: TextStyle(fontSize: 20),
  ),
  iconTheme: IconThemeData(size: 32),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    iconSize: 56,
    backgroundColor: Colors.blue[800],
  ),
  buttonTheme: ButtonThemeData(
    minWidth: 120,
    height: 60,
  ),
);