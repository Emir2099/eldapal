import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_dialog.dart';
import '../medication/medication_card.dart';
import '../../themes/app_theme.dart';
import '../../themes/elder_theme.dart';
class MedicationScreen extends StatefulWidget {
  final bool elderMode;

  const MedicationScreen({
    super.key,
    required this.elderMode,
  });

  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  TimeOfDay? _selectedTime;


  Widget _buildSectionHeader(String title, ThemeData theme) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontSize: widget.elderMode ? 24 : 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

  // Add missing dialog method
  void _showAddMedicationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Add Medication',
        content: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Medication Name'),
              ),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dosage'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Save logic
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Update MedicationCard usage
@override
Widget build(BuildContext context) {
  final theme = widget.elderMode ? elderTheme : appTheme;
  
  return Scaffold(
    body: Padding(
      padding: EdgeInsets.all(widget.elderMode ? 16 : 24),
      child: Column(
        children: [
          _buildSectionHeader('Today\'s Medications', theme),
          Expanded(
            child: ListView(
              children: [
                MedicationCard(
                  name: 'Metformin',
                  dosage: '500mg',
                  time: '08:00 AM',
                  elderMode: widget.elderMode,
                  onTaken: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: theme.colorScheme.primary,
      child: Icon(Icons.add, size: widget.elderMode ? 32 : 24),
      onPressed: () => _showAddMedicationDialog(context),
    ),
  );
}
}