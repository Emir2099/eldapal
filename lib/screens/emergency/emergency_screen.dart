import 'package:flutter/material.dart';
import '../../widgets/custom_dialog.dart';
import '../emergency/emergency_button.dart';
import '../../themes/app_theme.dart';
import '../../themes/elder_theme.dart';

class EmergencyScreen extends StatelessWidget {
  final bool elderMode;
  
  const EmergencyScreen({
    super.key,
    required this.elderMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = elderMode ? elderTheme : appTheme;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EmergencyButton(
                icon: Icons.emergency,
                label: 'SOS Emergency',
                onPressed: () => _triggerEmergency(context),
                // elderMode: elderMode,
              ),
              const SizedBox(height: 30),
              EmergencyButton(
                icon: Icons.location_on,
                label: 'Share Location',
                onPressed: () => _shareLocation(context),
                // elderMode: elderMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerEmergency(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Emergency Alert',
        content: Text(
          'Are you sure you want to send emergency alerts?',
          style: TextStyle(fontSize: elderMode ? 18 : 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emergency alerts sent!')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _shareLocation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location shared with emergency contacts'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}