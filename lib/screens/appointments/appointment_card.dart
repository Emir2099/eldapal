import 'package:flutter/material.dart';
import '/themes/app_theme.dart';
import '/themes/elder_theme.dart';

class AppointmentCard extends StatelessWidget {
  final String doctor;
  final String specialty;
  final String date;
  final String time;
  final bool elderMode;
  final VoidCallback onEdit;

  const AppointmentCard({
    required this.doctor,
    required this.specialty,
    required this.date,
    required this.time,
    required this.elderMode,
    required this.onEdit,
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
        leading: Icon(Icons.calendar_today, size: elderMode ? 40 : 32),
        title: Text(
          doctor,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: elderMode ? 22 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(specialty),
            SizedBox(height: 4),
            Text('Date: $date', style: TextStyle(fontSize: elderMode ? 18 : 16)),
            Text('Time: $time', style: TextStyle(fontSize: elderMode ? 18 : 16)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, size: elderMode ? 32 : 24),
          onPressed: onEdit,
        ),
      ),
    );
  }
}