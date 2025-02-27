import 'package:eldapal/screens/history/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/widgets/date_selector.dart';
import './medication_card.dart';
import '/widgets/custom_dialog.dart';
import '/models/medication_model.dart';
import '/providers/medications.dart';
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
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _typeController = TextEditingController();
  TimeOfDay? _selectedTime;
  String _frequency = 'Daily';
  String? _typeError;
  String? _dosageError;
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  void _showAddMedicationDialog(BuildContext context) {
    _clearForm();
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Add Medication',
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTypeDropdown(),
                _buildNameField(),
                _buildDosageField(),
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
            onPressed: () => _validateAndSave(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _typeController.text.isEmpty ? null : _typeController.text,
      decoration: InputDecoration(
        labelText: 'Type',
        errorText: _typeError,
        border: const OutlineInputBorder(),
      ),
      items: ['Tablet', 'Syrup', 'Injection', 'Other']
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _typeController.text = value!;
          _typeError = null;
        });
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Medicine Name',
        errorText: _nameError,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value!.isEmpty) return 'Required field';
        return null;
      },
      onChanged: (_) => setState(() => _nameError = null),
    );
  }

  Widget _buildDosageField() {
    String unit = _getDosageUnit();
    return TextFormField(
      controller: _dosageController,
      decoration: InputDecoration(
        labelText: 'Dosage ($unit)',
        suffixText: unit,
        errorText: _dosageError,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) return 'Required field';
        if (double.tryParse(value) == null) return 'Invalid number';
        return null;
      },
      onChanged: (_) => setState(() => _dosageError = null),
    );
  }

  String _getDosageUnit() {
    if (_typeController.text == 'Syrup') return 'ml';
    if (_typeController.text == 'Injection') return 'units';
    return 'mg';
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
      decoration: const InputDecoration(
        labelText: 'Frequency',
        border: OutlineInputBorder(),
      ),
    );
  }

  void _validateAndSave(BuildContext context) {
    setState(() {
      _nameError = _nameController.text.isEmpty ? 'Enter name' : null;
      _typeError = _typeController.text.isEmpty ? 'Select type' : null;
      _dosageError = _dosageController.text.isEmpty ? 'Enter dosage' : null;
    });

    if (_formKey.currentState!.validate() && 
        _typeError == null && 
        _dosageError == null) {
      final provider = Provider.of<MedicationsProvider>(context, listen: false);
      provider.addMedication(Medication(
        id: DateTime.now().toString(),
        name: _nameController.text,
        dosage: '${_dosageController.text} ${_getDosageUnit()}',
        type: _typeController.text,
        time: _selectedTime ?? TimeOfDay.now(),
        date: _selectedDate,
        frequency: _frequency,
        createdAt: DateTime.now(),
      ));
      Navigator.pop(context);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _dosageController.clear();
    _typeController.clear();
    _selectedTime = null;
    _frequency = 'Daily';
    _typeError = null;
    _dosageError = null;
    _nameError = null;
  }

  void _editMedication(Medication medication) {
    _nameController.text = medication.name;
    _dosageController.text = medication.dosage.split(' ')[0];
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
                _buildTypeDropdown(),
                _buildNameField(),
                _buildDosageField(),
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
            onPressed: () => _validateEdit(context, medication),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _validateEdit(BuildContext context, Medication medication) {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<MedicationsProvider>(context, listen: false);
      provider.updateMedication(medication.id, Medication(
        id: medication.id,
        name: _nameController.text,
        dosage: '${_dosageController.text} ${_getDosageUnit()}',
        type: _typeController.text,
        time: _selectedTime ?? TimeOfDay.now(),
        date: _selectedDate,
        frequency: _frequency,
        isTaken: medication.isTaken,
        createdAt: medication.createdAt,
      ));
      _clearForm();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.elderMode ? elderTheme : appTheme;
    final medications = Provider.of<MedicationsProvider>(context).medications;
    final dailyMeds = medications.where((m) => 
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
        actions: [
          IconButton(
            icon: Icon(Icons.history, size: widget.elderMode ? 28 : 24),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HistoryScreen(
                  medications: medications,
                  elderMode: widget.elderMode,
                ),
              ),
            ),
          ),
        ],
      ),
      body: dailyMeds.isEmpty
          ? Center(child: Text('No medications for selected date'))
          : ListView.builder(
              itemCount: dailyMeds.length,
              itemBuilder: (ctx, i) => MedicationCard(
                medication: dailyMeds[i],
                onEdit: () => _editMedication(dailyMeds[i]),
                onLongPress: () => Provider.of<MedicationsProvider>(context, listen: false)
                  .toggleTakenStatus(dailyMeds[i].id),
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