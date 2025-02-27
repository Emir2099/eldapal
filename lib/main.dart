import 'package:eldapal/screens/home_screen.dart';
import 'package:eldapal/themes/app_theme.dart';
import 'package:eldapal/themes/elder_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/medications.dart';
import './screens/medication/medication_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MedicationsProvider(),
      child: const ElderCareApp(),
    ),
  );
}

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