import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appointment_model.dart';
import 'appointment_detail_screen.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({Key? key}) : super(key: key);

  @override
  _AppointmentsListScreenState createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  final List<Appointment> _appointments = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
      ),
      body: _appointments.isEmpty
          ? const Center(child: Text('No appointments yet.'))
          : ListView.builder(
              itemCount: _appointments.length,
              itemBuilder: (ctx, i) {
                final appt = _appointments[i];
                return _buildAppointmentCard(appt);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAppointmentDialog(context),
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appt) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        onTap: () {
          // Navigate to detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AppointmentDetailScreen(appointment: appt),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundImage: AssetImage(appt.doctorImageUrl), // or NetworkImage
          radius: 24,
        ),
        title: Text(appt.doctorName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${appt.specialty} • ${DateFormat('dd MMM, HH:mm').format(appt.dateTime)}',
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  void _showAddAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _AddAppointmentDialog(
        onAdd: (newAppt) {
          setState(() => _appointments.add(newAppt));
        },
      ),
    );
  }
}

/// A simple dialog form to add a new appointment.
class _AddAppointmentDialog extends StatefulWidget {
  final Function(Appointment) onAdd;
  const _AddAppointmentDialog({Key? key, required this.onAdd}) : super(key: key);

  @override
  State<_AddAppointmentDialog> createState() => _AddAppointmentDialogState();
}

class _AddAppointmentDialogState extends State<_AddAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _doctorNameCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Appointment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _doctorNameCtrl,
                decoration: const InputDecoration(labelText: 'Doctor Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter doctor name' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _specialtyCtrl,
                decoration: const InputDecoration(labelText: 'Specialty'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter specialty' : null,
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Select Date'),
                subtitle: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() => _selectedDate = pickedDate);
                  }
                },
              ),
              ListTile(
                title: const Text('Select Time'),
                subtitle: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (pickedTime != null) {
                    setState(() => _selectedTime = pickedTime);
                  }
                },
              ),
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
              final dt = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                _selectedTime.hour,
                _selectedTime.minute,
              );
              final newAppt = Appointment(
                id: DateTime.now().toString(),
                doctorName: _doctorNameCtrl.text,
                specialty: _specialtyCtrl.text,
                dateTime: dt,
                doctorImageUrl: 'assets/images/doctor1.png', // placeholder
              );
              widget.onAdd(newAppt);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
