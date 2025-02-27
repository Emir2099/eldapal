// lib/screens/medication_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/widgets/date_selector.dart';
import './medication_card.dart';
import '/widgets/custom_dialog.dart';
import '/models/medication_model.dart';
import '/themes/app_theme.dart';
import '/themes/elder_theme.dart';

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
  final List<Medication> _medications = [];
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _typeController = TextEditingController();
  TimeOfDay? _selectedTime;
  String _frequency = 'Daily';

  void _showAddMedicationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Add Medication',
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_nameController, 'Medication Name'),
                _buildTextField(_dosageController, 'Dosage'),
                _buildTextField(_typeController, 'Type'),
                _buildFrequencyDropdown(),
                _buildDatePicker(context),
                _buildTimePicker(context),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveMedication,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return ListTile(
      title: const Text('Select Date'),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return ListTile(
      title: const Text('Select Time'),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          setState(() => _selectedTime = time);
        }
      },
      subtitle: Text(_selectedTime?.format(context) ?? 'No time selected'),
    );
  }

  Widget _buildFrequencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _frequency,
      items: ['Daily', 'Weekly', 'Monthly']
          .map((f) => DropdownMenuItem(value: f, child: Text(f)))
          .toList(),
      onChanged: (value) => setState(() => _frequency = value!),
      decoration: const InputDecoration(labelText: 'Frequency'),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value!.isEmpty ? 'Required field' : null,
    );
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _medications.add(Medication(
          id: DateTime.now().toString(),
          name: _nameController.text,
          dosage: _dosageController.text,
          type: _typeController.text,
          time: _selectedTime ?? TimeOfDay.now(),
          date: _selectedDate,
          frequency: _frequency,
          createdAt: DateTime.now(),
        ));
        _clearForm();
      });
      Navigator.pop(context);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _dosageController.clear();
    _typeController.clear();
    _selectedTime = null;
    _frequency = 'Daily';
  }

void _editMedication(Medication medication) {
  _nameController.text = medication.name;
  _dosageController.text = medication.dosage;
  _typeController.text = medication.type;
  _selectedTime = medication.time;
  _selectedDate = medication.date;
  _frequency = medication.frequency;

  showDialog(
    context: context,
    builder: (context) => CustomDialog(
      title: 'Edit Medication',
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_nameController, 'Medication Name'),
              _buildTextField(_dosageController, 'Dosage'),
              _buildTextField(_typeController, 'Type'),
              _buildFrequencyDropdown(),
              _buildDatePicker(context),
              _buildTimePicker(context),
            ],
          ),
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
              setState(() {
                final index = _medications.indexWhere((m) => m.id == medication.id);
                if (index != -1) {
                  _medications[index] = Medication(
                    id: medication.id,
                    name: _nameController.text,
                    dosage: _dosageController.text,
                    type: _typeController.text,
                    time: _selectedTime ?? TimeOfDay.now(),
                    date: _selectedDate,
                    frequency: _frequency,
                    isTaken: medication.isTaken,
                    createdAt: medication.createdAt,
                  );
                }
              });
              _clearForm();
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

  void _toggleMedicationStatus(Medication medication) {
    setState(() {
      medication.isTaken = !medication.isTaken;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.elderMode ? elderTheme : appTheme;
    final dailyMeds = _medications.where((m) => 
      m.date.year == _selectedDate.year &&
      m.date.month == _selectedDate.month &&
      m.date.day == _selectedDate.day
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: DateSelector(
          selectedDate: _selectedDate,
          onDateChanged: (date) => setState(() => _selectedDate = date),
          elderMode: widget.elderMode,
        ),
      ),
      body: dailyMeds.isEmpty
          ? Center(child: Text('No medications for selected date'))
          : ListView.builder(
              itemCount: dailyMeds.length,
              itemBuilder: (ctx, i) => MedicationCard(
                medication: dailyMeds[i],
                onEdit: () => _editMedication(dailyMeds[i]),
                onLongPress: () => _toggleMedicationStatus(dailyMeds[i]),
                elderMode: widget.elderMode,
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