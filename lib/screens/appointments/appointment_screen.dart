import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/widgets/custom_dialog.dart';
import 'appointment_card.dart';
import '/themes/app_theme.dart';
import '/themes/elder_theme.dart';

class AppointmentScreen extends StatefulWidget {
  final bool elderMode;

  const AppointmentScreen({required this.elderMode});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final List<Map<String, String>> _appointments = [];
  final _formKey = GlobalKey<FormState>();
  final _doctorController = TextEditingController();
  final _specialtyController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final theme = widget.elderMode ? elderTheme : appTheme;
    
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(widget.elderMode ? 16 : 24),
        child: Column(
          children: [
            _buildSectionHeader('Upcoming Appointments', theme),
            Expanded(
              child: ListView.builder(
                itemCount: _appointments.length,
                itemBuilder: (context, index) => AppointmentCard(
                  doctor: _appointments[index]['doctor']!,
                  specialty: _appointments[index]['specialty']!,
                  date: _appointments[index]['date']!,
                  time: _appointments[index]['time']!,
                  elderMode: widget.elderMode,
                  onEdit: () => _editAppointment(index),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, size: widget.elderMode ? 32 : 24),
        onPressed: () => _showAddAppointmentDialog(context),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: widget.elderMode ? 26 : 22,
        ),
      ),
    );
  }

  void _showAddAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'New Appointment',
        elderMode: widget.elderMode,
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_doctorController, 'Doctor Name'),
              _buildTextField(_specialtyController, 'Specialty'),
              _buildDatePicker(context),
              _buildTimePicker(context),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate() && 
                  _selectedDate != null && 
                  _selectedTime != null) {
                setState(() {
                  _appointments.add({
                    'doctor': _doctorController.text,
                    'specialty': _specialtyController.text,
                    'date': DateFormat('MMM dd, yyyy').format(_selectedDate!),
                    'time': _selectedTime!.format(context),
                  });
                });
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? 'Required field' : null,
        style: TextStyle(fontSize: widget.elderMode ? 18 : 16),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return ListTile(
      title: Text(
        'Select Date',
        style: TextStyle(fontSize: widget.elderMode ? 18 : 16),
      ),
      trailing: Icon(Icons.calendar_today),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 2),
          builder: (context, child) => Theme(
            data: widget.elderMode ? elderTheme : appTheme,
            child: child!,
          ),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      subtitle: Text(
        _selectedDate != null
            ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
            : 'No date selected',
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return ListTile(
      title: Text(
        'Select Time',
        style: TextStyle(fontSize: widget.elderMode ? 18 : 16),
      ),
      trailing: Icon(Icons.access_time),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) => Theme(
            data: widget.elderMode ? elderTheme : appTheme,
            child: child!,
          ),
        );
        if (time != null) {
          setState(() => _selectedTime = time);
        }
      },
      subtitle: Text(
        _selectedTime != null
            ? _selectedTime!.format(context)
            : 'No time selected',
      ),
    );
  }

  void _editAppointment(int index) {
    // Implement edit logic similar to add dialog
  }
}