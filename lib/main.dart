import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/medications.dart';
import 'screens/home_screen.dart';
import 'themes/app_theme.dart';
import 'themes/elder_theme.dart';
import 'themes/high_contrast_theme.dart'; // Import the high contrast theme

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(
    ChangeNotifierProvider(
      create: (context) => MedicationsProvider(),
      child: const ElderCareApp(),
    ),
  );
}

class ElderCareApp extends StatefulWidget {
  const ElderCareApp({Key? key}) : super(key: key);

  @override
  _ElderCareAppState createState() => _ElderCareAppState();
}

class _ElderCareAppState extends State<ElderCareApp> {
  bool _elderMode = false; // Tracks whether Elder Mode is enabled
  bool _highContrastMode = false; // Tracks whether High Contrast Mode is enabled

  void _toggleElderMode(bool value) {
    setState(() => _elderMode = value);
  }

  void _toggleHighContrastMode(bool value) {
    setState(() => _highContrastMode = value);
  }

  @override
  Widget build(BuildContext context) {
    // Determine the theme based on the current mode
    ThemeData currentTheme;
    if (_highContrastMode) {
      currentTheme = highContrastTheme; // Use High Contrast Theme
    } else if (_elderMode) {
      currentTheme = elderTheme; // Use Elder Theme
    } else {
      currentTheme = appTheme; // Use Default Theme
    }

    return MaterialApp(
      title: 'Elder Care Companion',
      theme: currentTheme,
      home: HomeScreen(
        elderMode: _elderMode,
        onThemeChanged: _toggleElderMode,
        onHighContrastChanged: _toggleHighContrastMode, // Pass the high contrast toggle
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
