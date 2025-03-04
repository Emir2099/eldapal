// ----------------- ElderModeEnabledScreen -----------------

/// Once elder mode is enabled, this screen is shown.
/// The user cannot exit this screen using the default back button.
/// Instead, a custom back arrow is provided. Tapping it opens an OTP prompt (similar to ElderModeAuthScreen)
/// and if the correct password is entered, elder mode is exited (navigates back to the HomeScreen).
import 'package:flutter/material.dart';

class ElderModeEnabledScreen extends StatelessWidget {
  const ElderModeEnabledScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Elder Mode Active',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildFeatureCard(
              icon: Icons.accessibility_new,
              title: 'Easy Access Features',
              description: 'Larger text and buttons for better visibility',
            ),
            _buildFeatureCard(
              icon: Icons.notification_important,
              title: 'Important Reminders',
              description: 'Medication and appointment alerts',
            ),
            _buildFeatureCard(
              icon: Icons.emergency,
              title: 'Emergency Contact',
              description: 'Quick access to emergency contacts',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 32),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}