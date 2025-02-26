import 'package:flutter/material.dart';
import '/themes/app_theme.dart';
import '/themes/elder_theme.dart';

class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String time;
  final bool elderMode;
  final VoidCallback onTaken;

  const MedicationCard({
    required this.name,
    required this.dosage,
    required this.time,
    required this.elderMode,
    required this.onTaken,
  });

  @override
  Widget build(BuildContext context) {
    final theme = elderMode ? elderTheme : appTheme;
    
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: elderMode ? 8 : 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(elderMode ? 20 : 16),
        leading: Icon(Icons.medication, size: elderMode ? 40 : 32),
        title: Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: elderMode ? 22 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dosage: $dosage'),
            Text('Time: $time'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.check_circle,
            size: elderMode ? 32 : 24,
            color: theme.colorScheme.primary,
          ),
          onPressed: onTaken,
        ),
      ),
    );
  }
}