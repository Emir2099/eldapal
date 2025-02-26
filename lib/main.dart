import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'themes/app_theme.dart';
import 'themes/elder_theme.dart';

void main() => runApp(const ElderCareApp());

class ElderCareApp extends StatefulWidget {
  const ElderCareApp({super.key});

  @override
  _ElderCareAppState createState() => _ElderCareAppState();
}

class _ElderCareAppState extends State<ElderCareApp> {
  bool _elderMode = false;

  void _toggleElderMode(bool value) {
    setState(() => _elderMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elder Care Companion',
      theme: _elderMode ? elderTheme : appTheme,
      home: HomeScreen(
        elderMode: _elderMode,
        onThemeChanged: _toggleElderMode,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}