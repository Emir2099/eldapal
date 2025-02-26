import 'package:flutter/material.dart';

class ElderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool elderMode;
  final ValueChanged<bool> onThemeChanged;

  const ElderAppBar({
    required this.title,
    required this.elderMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: TextStyle(
        fontSize: elderMode ? 28 : 24,
        fontWeight: FontWeight.bold,
      )),
      actions: [
        Switch(
          value: elderMode,
          onChanged: onThemeChanged,
          activeColor: Colors.blue[800],
          inactiveThumbColor: Colors.deepPurple,
        ),
        SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}