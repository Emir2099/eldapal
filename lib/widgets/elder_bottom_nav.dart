import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../themes/elder_theme.dart';

class ElderBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool elderMode;

  const ElderBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.elderMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = elderMode ? elderTheme : appTheme;
    
    return BottomNavigationBar(
      items: _navItems(elderMode),
      currentIndex: currentIndex,
      onTap: (index) {
        if (index >= 0 && index < _navItems(elderMode).length) {
          onTap(index);
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
      selectedLabelStyle: TextStyle(
        fontSize: elderMode ? 16 : 14,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: elderMode ? 14 : 12,
      ),
    );
  }

  List<BottomNavigationBarItem> _navItems(bool elderMode) {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.medication),
        label: 'Meds',
        tooltip: 'Medication Management',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.favorite),
        label: 'Health',
        tooltip: 'Health Monitoring',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.emergency),
        label: 'Emergency',
        tooltip: 'Emergency Assistance',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        label: 'Appointments',
        tooltip: 'Appointment Management',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
        tooltip: 'User Profile',
      ),
    ];
  }
}