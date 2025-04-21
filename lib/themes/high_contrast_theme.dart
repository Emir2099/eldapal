import 'package:flutter/material.dart';

final ThemeData highContrastTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(
    bodyText1: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    bodyText2: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    headline6: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  ),
  cardColor: Colors.black87,
  iconTheme: const IconThemeData(color: Colors.white),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.black,
    textTheme: ButtonTextTheme.primary,
  ),
);