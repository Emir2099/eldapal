// lib/providers/medications.dart
import 'package:flutter/material.dart';
import '../models/medication_model.dart';

class MedicationsProvider with ChangeNotifier {
  List<Medication> _medications = [];

  List<Medication> get medications => _medications;

  void addMedication(Medication medication) {
    _medications.add(medication);
    notifyListeners();
  }

  void updateMedication(String id, Medication newMedication) {
    final index = _medications.indexWhere((m) => m.id == id);
    if (index >= 0) {
      _medications[index] = newMedication;
      notifyListeners();
    }
  }

  void toggleTakenStatus(String id) {
    final index = _medications.indexWhere((m) => m.id == id);
    if (index >= 0) {
      _medications[index].isTaken = !_medications[index].isTaken;
      notifyListeners();
    }
  }
}