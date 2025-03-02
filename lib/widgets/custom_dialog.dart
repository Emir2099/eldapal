import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = appTheme; // Using your default app theme
    return AlertDialog(
      titlePadding: const EdgeInsets.all(24),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.all(24),
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: 20,
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
                fontSize: 16,
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
