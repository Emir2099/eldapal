// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '/models/medication_model.dart';

class HistoryScreen extends StatelessWidget {
  final List<Medication> medications;
  final bool elderMode;

  const HistoryScreen({
    required this.medications,
    required this.elderMode,
  });

  @override
  Widget build(BuildContext context) {
    final groupedMeds = groupBy(medications, (m) => 
      DateFormat('yyyy-MM-dd').format(m.date)
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Medication History')),
      body: ListView.separated(
        itemCount: groupedMeds.keys.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final dateKey = groupedMeds.keys.elementAt(i);
          final meds = groupedMeds[dateKey]!;
          final date = DateTime.parse(dateKey);

          return Column(
            children: [
              ListTile(
                title: Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...meds.map((m) => _MedicationHistoryItem(
                    medication: m,
                    elderMode: elderMode,
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _MedicationHistoryItem extends StatelessWidget {
  final Medication medication;
  final bool elderMode;

  const _MedicationHistoryItem({
    required this.medication,
    required this.elderMode,
  });

  @override
  Widget build(BuildContext context) {
    final isMissed = !medication.isTaken && 
      medication.date.isBefore(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: medication.isTaken 
          ? Colors.green[50] 
          : isMissed ? Colors.red[50] : Colors.white,
      ),
      child: ListTile(
        title: Text(medication.name),
        subtitle: Text('${medication.dosage} - ${medication.formattedTime}'),
        trailing: Text(
          medication.isTaken ? 'Taken' : 'Missed',
          style: TextStyle(
            color: medication.isTaken ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}