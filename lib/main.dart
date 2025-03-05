import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/medications.dart';
import 'screens/home_screen.dart';
import 'themes/app_theme.dart';
import 'themes/elder_theme.dart';

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
