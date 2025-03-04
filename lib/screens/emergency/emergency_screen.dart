import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'emergency_button.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Create a pulse animation for the SOS button.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Trigger three consecutive heavy haptic pulses
  Future<void> _triggerTripleVibration() async {
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 120));
    }
  }

  void _onEmergencyPressed() async {
    await _triggerTripleVibration();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency SOS activated!'),
        backgroundColor: Colors.deepOrange,
      ),
    );
    // TODO: Implement real emergency functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A custom AppBar with a back arrow and a gradient.
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Emergency Assistance'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Container(
        // Soft gradient background inspired by your home screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFE3F3), Color(0xFFE5D6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: EmergencyButton(
              onPressed: _onEmergencyPressed,
            ),
          ),
        ),
      ),
    );
  }
}
