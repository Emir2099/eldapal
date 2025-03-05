import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '/models/medication_model.dart';

class ElderMedicationCard extends StatefulWidget {
  final Medication medication;

  const ElderMedicationCard({super.key, required this.medication});

  @override
  State<ElderMedicationCard> createState() => _ElderMedicationCardState();
}

class _ElderMedicationCardState extends State<ElderMedicationCard> {
  bool _isVibrating = false;
  late DateTime _scheduledTime;

  @override
  void initState() {
    super.initState();
    _scheduledTime = DateTime(
      widget.medication.date.year,
      widget.medication.date.month,
      widget.medication.date.day,
      widget.medication.time.hour,
      widget.medication.time.minute,
    );
    _checkTime();
  }

  void _checkTime() async {
    final now = DateTime.now();
    if (_scheduledTime.isBefore(now) && !widget.medication.isTaken) {
      _startVibration();
    }
  }

  void _startVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      setState(() => _isVibrating = true);
      Vibration.vibrate(
        pattern: [500, 1000], // Vibrate 500ms, pause 1000ms
        repeat: -1 // Infinite loop
      );
    }
  }

  void _stopVibration() {
    Vibration.cancel();
    setState(() => _isVibrating = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isVibrating) _stopVibration();
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _isVibrating ? Colors.red.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(
            color: _isVibrating ? Colors.red : Colors.grey.shade300,
            width: 3
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.medical_services,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
                if(_isVibrating)
                const Icon(
                  Icons.notification_important,
                  size: 40,
                  color: Colors.red,
                )
              ],
            ),
            const SizedBox(height: 20),
            _buildLargeText("Medicine:", widget.medication.name),
            const SizedBox(height: 15),
            _buildLargeText("Dosage:", widget.medication.dosage),
            const SizedBox(height: 15),
            _buildTimeRow(),
            const SizedBox(height: 20),
            if(_isVibrating)
            const Text(
              "TAP TO STOP REMINDER",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLargeText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 22,
            color: Colors.grey,
            fontWeight: FontWeight.w500
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Scheduled Time:",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            Text(
              widget.medication.formattedTime,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue
              ),
            ),
          ],
        ),
        Icon(
          Icons.access_time_filled,
          size: 40,
          color: _isVibrating ? Colors.red : Colors.grey,
        )
      ],
    );
  }
}