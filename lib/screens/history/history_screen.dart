import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '/models/medication_model.dart';

class HistoryScreen extends StatelessWidget {
  final List<Medication> medications;

  const HistoryScreen({
    Key? key,
    required this.medications,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groupedMeds = groupBy(medications, (m) =>
        DateFormat('yyyy-MM-dd').format(m.date));

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade200,
                child: Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ...meds.map((m) => _MedicationHistoryItem(
                    medication: m,
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

  const _MedicationHistoryItem({
    Key? key,
    required this.medication,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMissed = !medication.isTaken && medication.date.isBefore(DateTime.now());

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: medication.isTaken
            ? Colors.green[50]
            : isMissed ? Colors.red[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          medication.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
