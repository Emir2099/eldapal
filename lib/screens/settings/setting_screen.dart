import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<bool> onHighContrastChanged; // Callback to notify theme change
  final ValueChanged<double> onFontSizeChanged; 
  const SettingsScreen({
    Key? key,
    required this.onHighContrastChanged,
    required this.onFontSizeChanged,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  bool _highContrastMode = false;
  double _fontSize = 16.0; // Default font size
  double _volumeLevel = 0.8; // Default volume level
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeVolume();
    FlutterVolumeController.addListener(_onVolumeChanged);
  }

  @override
  void dispose() {
    FlutterVolumeController.removeListener();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
      _highContrastMode = prefs.getBool('highContrastMode') ?? false;
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
      _volumeLevel = prefs.getDouble('volumeLevel') ?? 0.8;
      _selectedLanguage = prefs.getString('language') ?? 'English';
    });

    // Notify the app of the initial theme and font size
    widget.onHighContrastChanged(_highContrastMode);
    widget.onFontSizeChanged(_fontSize);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('highContrastMode', _highContrastMode);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setDouble('volumeLevel', _volumeLevel);
    await prefs.setString('language', _selectedLanguage);
  }

  Future<void> _initializeVolume() async {
    final currentVolume = await FlutterVolumeController.getVolume();
    setState(() {
      _volumeLevel = currentVolume ?? 0.0;
    });
  }

  void _onVolumeChanged(double volume) {
    setState(() {
      _volumeLevel = volume;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccessibilitySection(),
                    const SizedBox(height: 24),
                    _buildNotificationSection(),
                    const SizedBox(height: 24),
                    _buildSoundSection(),
                    const SizedBox(height: 24),
                    _buildLanguageSection(),
                    const SizedBox(height: 24),
                    _buildSupportSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black87),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFE3F3), Color(0xFFE5D6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessibilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Accessibility'),
        SwitchListTile(
          title: const Text('High Contrast Mode'),
          subtitle: const Text('Increase text and UI contrast'),
          value: _highContrastMode,
          onChanged: (value) {
            setState(() => _highContrastMode = value);
            _saveSettings();
            widget.onHighContrastChanged(value); // Notify the app of the theme change
            HapticFeedback.lightImpact();
          },
        ),
// Commented out the Text Size slider
        /*
        ListTile(
          title: const Text('Text Size'),
          subtitle: Slider(
            value: _fontSize,
            min: 14.0,
            max: 24.0,
            divisions: 5,
            label: '${_fontSize.round()}',
            onChanged: (value) {
              setState(() => _fontSize = value);
              widget.onFontSizeChanged(value); // Notify the app of the font size change
              _saveSettings();
            },
          ),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              'Sample Text',
              style: TextStyle(fontSize: _fontSize), // Dynamically adjust text size
            ),
          ),
        ),
        */
      ],
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Notifications'),
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Medication and appointment reminders'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            _saveSettings();
            HapticFeedback.lightImpact();
          },
        ),
      ],
    );
  }

  Widget _buildSoundSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _buildSectionHeader('Sound'),
        // Commented out the Volume slider
        /*
        ListTile(
          title: const Text('Volume'),
          subtitle: Slider(
            value: _volumeLevel,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: (_volumeLevel * 100).round().toString(),
            onChanged: (value) async {
              setState(() {
                _volumeLevel = value;
              });
              await FlutterVolumeController.setVolume(value); // Adjust the system volume
              _saveSettings();
            },
          ),
        ),
        */
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Language'),
        ListTile(
          // title: Text('Preface      $_selectedLanguage'),
          title: Text('Preface                               English'),

        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Support'),
        // ListTile(
        //   leading: const Icon(Icons.help_outline),
        //   title: const Text('Help & Support'),
        //   onTap: () {
        //     // Navigate to help screen
        //   },
        // ),
       ListTile(
  leading: const Icon(Icons.info_outline),
  title: const Text('About'),
  onTap: () {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About Eldapal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                'Eldapal is a Flutter-based mobile application designed to assist elderly users in managing their daily activities, health, and well-being. The app provides a user-friendly interface with features like medication reminders, health tracking, emergency assistance, and more. It also includes an Elder Mode for simplified navigation and accessibility.',
              ),
              SizedBox(height: 16),
              Text(
                'APP VERSION 1.0.0',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  },
),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}