// lib/models/medication_model.dart
import 'package:flutter/material.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String type;
  final TimeOfDay time;
  final DateTime date;
  final String frequency;
  bool isTaken;
  final DateTime createdAt;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.type,
    required this.time,
    required this.date,
    required this.frequency,
    this.isTaken = false,
    required this.createdAt,
  });

  String get formattedTime {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}