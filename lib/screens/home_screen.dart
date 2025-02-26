import 'package:flutter/material.dart';
import '../widgets/elder_app_bar.dart';
import '../widgets/elder_bottom_nav.dart';
import '../screens/medication/medication_screen.dart';
import '../screens/health/health_screen.dart';
import '../screens/emergency/emergency_screen.dart';
import '../screens/appointments/appointment_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../themes/app_theme.dart';
import '../themes/elder_theme.dart';

class HomeScreen extends StatefulWidget {
  final bool elderMode;
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.elderMode,
    required this.onThemeChanged,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    MedicationScreen(elderMode: widget.elderMode),
    HealthMonitorScreen(elderMode: widget.elderMode),
    EmergencyScreen(elderMode: widget.elderMode),
    AppointmentScreen(elderMode: widget.elderMode),
    ProfileScreen(elderMode: widget.elderMode),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ElderAppBar(
        title: 'Elder Care Companion',
        elderMode: widget.elderMode,
        onThemeChanged: widget.onThemeChanged,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: ElderBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elderMode: widget.elderMode,
      ),
    );
  }
}