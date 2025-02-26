import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../themes/elder_theme.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final bool elderMode;

  const CustomDialog({
    required this.title,
    required this.content,
    required this.actions,
    this.elderMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = elderMode ? elderTheme : appTheme;
    
    return AlertDialog(
      titlePadding: const EdgeInsets.all(24),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.all(24),
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(elderMode ? 16 : 24),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: elderMode ? 24 : 20,
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: SingleChildScrollView(child: content),
      actions: actions.map((action) {
        if (action is TextButton) {
          return TextButton(
            onPressed: action.onPressed,
            child: Text(
              (action.child as Text).data!,
              style: TextStyle(
                fontSize: elderMode ? 18 : 16,
                color: theme.colorScheme.primary,
              ),
            ),
          );
        }
        return action;
      }).toList(),
    );
  }
}