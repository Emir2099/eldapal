import 'package:flutter/material.dart';
import '/models/medication_model.dart';
import '/themes/app_theme.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onEdit;
  final VoidCallback onLongPress;

  const MedicationCard({
    Key? key,
    required this.medication,
    required this.onEdit,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTaken = medication.isTaken;
    final Gradient cardGradient = isTaken
        ? LinearGradient(
            colors: [Colors.green.shade200, Colors.green.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return GestureDetector(
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'medication_icon_${medication.id}',
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 30,
                child: Icon(
                  Icons.medication,
                  size: 30,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Dosage: ${medication.dosage}',
                      style: Theme.of(context).textTheme.bodyText2),
                  const SizedBox(height: 4),
                  Text('Time: ${medication.formattedTime}',
                      style: Theme.of(context).textTheme.bodyText2),
                  const SizedBox(height: 4),
                  Text('Type: ${medication.type}',
                      style: Theme.of(context).textTheme.bodyText2),
                  const SizedBox(height: 4),
                  Text('Frequency: ${medication.frequency}',
                      style: Theme.of(context).textTheme.bodyText2),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.check_circle,
                    size: 28,
                    color: isTaken ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 24),
                  onPressed: onEdit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
