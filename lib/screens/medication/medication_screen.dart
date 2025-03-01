import 'package:flutter/material.dart';

class MedicationScreen extends StatelessWidget {
  const MedicationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // If you don’t want an extra AppBar here, remove it
      appBar: AppBar(
        title: const Text('Medication Management'),
      ),
      body: const Center(
        child: Text('Medication Screen'),
      ),
    );
  }
}
