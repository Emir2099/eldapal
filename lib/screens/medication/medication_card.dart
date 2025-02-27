// lib/widgets/medication_card.dart
import 'package:flutter/material.dart';
import '/models/medication_model.dart';
import '/themes/app_theme.dart';
import '/themes/elder_theme.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onEdit;
  final VoidCallback onLongPress;
  final bool elderMode;

  const MedicationCard({
    required this.medication,
    required this.onEdit,
    required this.onLongPress,
    required this.elderMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = elderMode ? elderTheme : appTheme;
    
    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: elderMode ? 8 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: medication.isTaken ? Colors.green[50] : Colors.white,
        child: ListTile(
          contentPadding: EdgeInsets.all(elderMode ? 20 : 16),
          leading: Icon(Icons.medication, size: elderMode ? 40 : 32),
          title: Text(
            medication.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: elderMode ? 22 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dosage: ${medication.dosage}'),
              Text('Time: ${medication.formattedTime}'),
              Text('Type: ${medication.type}'),
              Text('Frequency: ${medication.frequency}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.check_circle,
                  size: elderMode ? 32 : 24,
                  color: medication.isTaken ? Colors.green : Colors.grey,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.edit, size: elderMode ? 28 : 20),
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}