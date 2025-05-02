import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/medications.dart';
import 'screens/home_screen.dart';
import 'themes/app_theme.dart';
import 'themes/elder_theme.dart';
import 'themes/high_contrast_theme.dart'; 

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
  bool _elderMode = false;
  bool _highContrastMode = false;
  double _fontSize = 16.0; // Default font size

  void _toggleElderMode(bool value) {
    setState(() => _elderMode = value);
  }

  void _toggleHighContrastMode(bool value) {
    setState(() => _highContrastMode = value);
  }

  void _updateFontSize(double value) {
    setState(() => _fontSize = value);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme;
    if (_highContrastMode) {
      currentTheme = highContrastTheme.copyWith(
        textTheme: highContrastTheme.textTheme.apply(fontSizeFactor: _fontSize / 16.0),
      );
    } else if (_elderMode) {
      currentTheme = elderTheme.copyWith(
        textTheme: elderTheme.textTheme.apply(fontSizeFactor: _fontSize / 16.0),
      );
    } else {
      currentTheme = appTheme.copyWith(
        textTheme: appTheme.textTheme.apply(fontSizeFactor: _fontSize / 16.0),
      );
    }

    return MaterialApp(
      title: 'Elder Care Companion',
      theme: currentTheme,
      home: HomeScreen(
        elderMode: _elderMode,
        onThemeChanged: _toggleElderMode,
        onHighContrastChanged: _toggleHighContrastMode,
        onFontSizeChanged: _updateFontSize, // Pass font size callback
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
