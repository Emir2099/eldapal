import 'package:flutter/material.dart';
import '/themes/app_theme.dart';
import '/themes/elder_theme.dart';

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool elderMode;

  const ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.elderMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = elderMode ? elderTheme : appTheme;
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: elderMode ? 8 : 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(elderMode ? 20 : 16),
        leading: Icon(icon, size: elderMode ? 32 : 24),
        title: Text(
          label,
          style: TextStyle(
            fontSize: elderMode ? 20 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: elderMode ? 18 : 14),
        ),
      ),
    );
  }
}