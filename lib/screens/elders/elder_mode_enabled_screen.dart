import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '/providers/medications.dart';
import '/models/medication_model.dart';

class ElderModeEnabledScreen extends StatefulWidget {
  const ElderModeEnabledScreen({Key? key}) : super(key: key);

  @override
  State<ElderModeEnabledScreen> createState() => _ElderModeEnabledScreenState();
}

class _ElderModeEnabledScreenState extends State<ElderModeEnabledScreen> {
  late Timer _vibrationTimer;
  bool _hasVibrator = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingBeep = false;

  @override
  void initState() {
    super.initState();
    _checkVibrator();
    _loadBeepSound();
    _vibrationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
        _checkMedicationAndAlert();
      }
    });
  }

  Future<void> _loadBeepSound() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // For continuous beeping
      await _audioPlayer.setSource(AssetSource('sounds/alert_beep.mp3'));
      await _audioPlayer.setVolume(0.5); // Adjust volume as needed
    } catch (e) {
      debugPrint('Error loading beep sound: $e');
    }
  }

  void _checkMedicationAndAlert() {
    final medProvider = Provider.of<MedicationsProvider>(context, listen: false);
    final upcomingMed = _getUpcomingMedication(medProvider.medications);
    
    if (upcomingMed != null && _canMarkTaken(upcomingMed) && !upcomingMed.isTaken) {
      _startAlerts();
    } else {
      _stopAlerts();
    }
  }

  void _startAlerts() async {
    // Start vibration if not already vibrating
    if (_hasVibrator) {
      try {
        Vibration.vibrate(pattern: [500, 1000], repeat: -1);
      } catch (e) {
        debugPrint('Vibration error: $e');
      }
    }

    // Start beep if not already beeping
    if (!_isPlayingBeep) {
      try {
        await _audioPlayer.resume();
        _isPlayingBeep = true;
      } catch (e) {
        debugPrint('Audio error: $e');
      }
    }
  }

  void _stopAlerts() async {
    // Stop vibration
    if (_hasVibrator) {
      try {
        Vibration.cancel();
      } catch (e) {
        debugPrint('Vibration cancel error: $e');
      }
    }

    // Stop beep
    if (_isPlayingBeep) {
      try {
        await _audioPlayer.pause();
        _isPlayingBeep = false;
      } catch (e) {
        debugPrint('Audio stop error: $e');
      }
    }
  }

  Future<void> _checkVibrator() async {
    try {
      _hasVibrator = await Vibration.hasVibrator() ?? false;
    } catch (e) {
      _hasVibrator = false;
    }
  }

  @override
  void dispose() {
    _vibrationTimer.cancel();
    _stopAlerts();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<MedicationsProvider>(
                  builder: (context, medProvider, child) {
                    final upcoming = _getUpcomingMedication(medProvider.medications);
                    if (upcoming != null) {
                      return _buildMedicationAlertCard(
                        medication: upcoming,
                        onTap: _canMarkTaken(upcoming)
                            ? () => _handleMedicationTap(context, upcoming)
                            : null,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 30),
                _buildFeatureSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _canMarkTaken(Medication med) {
    final now = DateTime.now();
    final medTime = DateTime(
      med.date.year,
      med.date.month,
      med.date.day,
      med.time.hour,
      med.time.minute,
    );
    return now.isAfter(medTime) || now.isAtSameMomentAs(medTime);
  }

  void _handleMedicationTap(BuildContext context, Medication med) {
    if (!_canMarkTaken(med)) return;

    final provider = Provider.of<MedicationsProvider>(context, listen: false);
    
    showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (context, anim, __, child) {
        return ScaleTransition(
          scale: anim,
          child: AlertDialog(
            content: const Text('Medication marked as taken'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  provider.toggleTakenStatus(med.id);
                  _stopAlerts(); // Stop all alerts when medication is taken
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  Widget _buildMedicationAlertCard({
    required Medication medication,
    VoidCallback? onTap,
  }) {
    final canMark = _canMarkTaken(medication);
    final isActive = canMark && !medication.isTaken;
    
    // Only vibrate if device has vibrator and medication is active
    if (isActive && _hasVibrator) {
      try {
        Vibration.vibrate(
          pattern: [500, 1000],
          repeat: -1,
        );
      } catch (e) {
        // Handle vibration error silently
        print(e);
      }
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: medication.isTaken ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isActive ? Colors.red.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? Colors.red : Colors.transparent,
              width: 3,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.medical_services,
                size: 50,
                color: isActive ? Colors.red : Colors.grey,
              ),
              const SizedBox(height: 20),
              Text(
                medication.name,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Dosage: ${medication.dosage}',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              Text(
                medication.formattedTime,
                style: TextStyle(
                  fontSize: 32,
                  color: isActive ? Colors.blue : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    medication.isTaken ? Icons.check_circle : Icons.warning,
                    color: medication.isTaken ? Colors.green : Colors.orange,
                    size: 40,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    medication.isTaken ? 'TAKEN' : 'PENDING',
                    style: TextStyle(
                      fontSize: 28,
                      color: medication.isTaken ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (isActive) ...[
                const SizedBox(height: 20),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: const Text(
                        'TAP TO MARK AS TAKEN',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Elder Mode Features',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        _buildFeatureCard(
          icon: Icons.accessibility_new,
          title: 'Simplified Interface',
          description: 'Large text and clear buttons',
        ),
        _buildFeatureCard(
          icon: Icons.notifications_active,
          title: 'Vibration Alerts',
          description: 'Strong physical reminders for medications',
        ),
        _buildFeatureCard(
          icon: Icons.emergency_share,
          title: 'Emergency Access',
          description: 'Quick contact buttons',
        ),
      ],
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
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20)),
                  Text(description, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Medication? _getUpcomingMedication(List<Medication> meds) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Medication? closest;
    
    for (final med in meds) {
      final medDate = DateTime(med.date.year, med.date.month, med.date.day);
      if (medDate.isAtSameMomentAs(today)) {
        final medDateTime = DateTime(
          med.date.year,
          med.date.month,
          med.date.day,
          med.time.hour,
          med.time.minute,
        );
        
        if (!med.isTaken && (closest == null || 
            medDateTime.isBefore(DateTime(
              closest.date.year,
              closest.date.month,
              closest.date.day,
              closest.time.hour,
              closest.time.minute,
            )))) {
          closest = med;
        }
      }
    }
    return closest;
  }
}