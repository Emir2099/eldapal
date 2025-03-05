import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  bool _highContrastMode = false;
  double _fontSize = 16.0;
  double _volumeLevel = 0.8;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _highContrastMode = prefs.getBool('highContrastMode') ?? false;
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
      _volumeLevel = prefs.getDouble('volumeLevel') ?? 0.8;
      _selectedLanguage = prefs.getString('language') ?? 'English';
    });
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
            HapticFeedback.lightImpact();
          },
        ),
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
              _saveSettings();
            },
          ),
        ),
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
        _buildSectionHeader('Sound'),
        SwitchListTile(
          title: const Text('Enable Sounds'),
          subtitle: const Text('App sounds and alerts'),
          value: _soundEnabled,
          onChanged: (value) {
            setState(() => _soundEnabled = value);
            _saveSettings();
            HapticFeedback.lightImpact();
          },
        ),
        ListTile(
          title: const Text('Volume'),
          subtitle: Slider(
            value: _volumeLevel,
            onChanged: (value) {
              setState(() => _volumeLevel = value);
              _saveSettings();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Language'),
        ListTile(
          title: const Text('Select Language'),
          subtitle: Text(_selectedLanguage),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguageDialog(),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Support'),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Help & Support'),
          onTap: () {
            // Navigate to help screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About'),
          onTap: () {
            // Show about dialog
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

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('Spanish'),
            _buildLanguageOption('French'),
            _buildLanguageOption('German'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(language),
      trailing: _selectedLanguage == language
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        setState(() => _selectedLanguage = language);
        _saveSettings();
        Navigator.pop(context);
        HapticFeedback.lightImpact();
      },
    );
  }
}