import 'package:flutter/material.dart';
import '/widgets/custom_dialog.dart';
import '/themes/app_theme.dart';
import '/themes/elder_theme.dart';

class HealthMonitorScreen extends StatefulWidget {
  final bool elderMode;

  const HealthMonitorScreen({this.elderMode = false});

  @override
  _HealthMonitorScreenState createState() => _HealthMonitorScreenState();
}

class _HealthMonitorScreenState extends State<HealthMonitorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bpController = TextEditingController();
  final _bsController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = widget.elderMode ? elderTheme : appTheme;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.elderMode ? 16 : 24),
      child: Column(
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(widget.elderMode ? 20 : 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Record Vital Signs',
                      style: theme.textTheme.titleLarge,
                    ),
                    SizedBox(height: widget.elderMode ? 20 : 16),
                    _buildVitalInputField(
                      controller: _bpController,
                      label: 'Blood Pressure (mmHg)',
                      validator: (value) => _validateBP(value),
                    ),
                    _buildVitalInputField(
                      controller: _bsController,
                      label: 'Blood Sugar (mg/dL)',
                      validator: (value) => _validateBS(value),
                    ),
                    _buildVitalInputField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      validator: (value) => _validateWeight(value),
                    ),
                    SizedBox(height: widget.elderMode ? 20 : 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: widget.elderMode ? 16 : 12,
                          horizontal: 24,
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Save logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Vitals recorded successfully')),
                          );
                        }
                      },
                      child: Text(
                        'Save Record',
                        style: TextStyle(fontSize: widget.elderMode ? 18 : 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          // Vital chart implementation
        ],
      ),
    );
  }

  String? _validateBP(String? value) {
    if (value == null || value.isEmpty) return 'Required field';
    final regex = RegExp(r'^\d{1,3}/\d{1,3}$');
    if (!regex.hasMatch(value)) return 'Invalid format (e.g., 120/80)';
    return null;
  }

  String? _validateBS(String? value) {
    if (value == null || value.isEmpty) return 'Required field';
    final numValue = int.tryParse(value);
    if (numValue == null) return 'Must be a number';
    if (numValue < 20 || numValue > 500) return 'Invalid range (20-500)';
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) return 'Required field';
    final numValue = double.tryParse(value);
    if (numValue == null) return 'Must be a number';
    if (numValue < 20 || numValue > 300) return 'Invalid range (20-300)';
    return null;
  }

  Widget _buildVitalInputField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.elderMode ? 12 : 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(widget.elderMode ? 16 : 12),
        ),
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: widget.elderMode ? 18 : 16),
        validator: validator,
      ),
    );
  }
}