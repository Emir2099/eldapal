import 'package:eldapal/screens/appointments/appointment_screen.dart';
import 'package:eldapal/screens/emergency/emergency_screen.dart';
import 'package:eldapal/screens/facerecognition/face_recognition_screen.dart';
import 'package:eldapal/screens/health/health_screen.dart';
import 'package:eldapal/screens/medication/medication_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../widgets/elder_bottom_nav.dart';
import '../screens/elders/elder_tab_screen.dart';
import '../screens/settings/setting_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';
import '../services/music_service.dart'; 
import '../screens/relax_mode_screen.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomeScreen extends StatefulWidget {
  final bool elderMode;
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({
    Key? key,
    required this.elderMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  final SpeechToText _speechToText = SpeechToText();
  bool _isVoiceEnabled = false;

  @override
  void initState() {
    super.initState();
    // Three tabs: 0 = Home, 1 = Elder tab, 2 = Settings tab.
    _screens = [
      _FancyHomeContent(
        elderMode: widget.elderMode,
        onThemeChanged: widget.onThemeChanged,
      ),
      ElderTabScreen(
        onElderModeChanged: widget.onThemeChanged,
      ),
      const SettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Extend body so that the nav bar can float over content.
      extendBody: true,
      body: Stack(
        children: [
          // Main content via an IndexedStack.
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          // Our custom draggable & long-press nav bar.
          if (!widget.elderMode)
          ElderBottomNav(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            elderMode: widget.elderMode,
          ),
        ],
      ),
    );
  }
}

class _FancyHomeContent extends StatefulWidget { 
  final bool elderMode;
  final ValueChanged<bool> onThemeChanged;

  const _FancyHomeContent({
    Key? key,
    required this.elderMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _FancyHomeContentState createState() => _FancyHomeContentState();
}

class _FancyHomeContentState extends State<_FancyHomeContent> {
  final SpeechToText _speechToText = SpeechToText();
  final PageController _pageController = PageController(); // Define _pageController
  bool _isVoiceEnabled = false;

  @override
  Widget build(BuildContext context) {
    // Scrollable content.
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAnimatedHeader(context),
          _CircularCarousel(elderMode: widget.elderMode),
        ],
      ),
    );
  }


String getMood() {
  final hour = DateTime.now().hour;
  if (hour >= 6 && hour < 12) {
    return "CALMING";
  } else if (hour >= 12 && hour < 18) {
    return "SOOTHING";
  } else {
    return "RELAXING";
  }
}

Widget _buildAnimatedHeader(BuildContext context) {
  // Get the current mood.
  final mood = getMood();
  // Format current time in 24-hr format.
  final currentTime = DateFormat('HH:mm').format(DateTime.now());

  return SizedBox(
    height: 400,
    child: Stack(
      children: [
        // Animated wave background.
        const Positioned.fill(
          child: _AnimatedWave(height: 500),
        ),
        // Update the menu icon to question mark with ChatBot functionality
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.question_mark_rounded, color: Colors.white),
            onPressed: () => _showNavigationAssistant(context), 
            tooltip: 'Navigation Assistant',
          ),
        ),
        // Centered header content.
        Positioned(
          top: 70,
          left: 0,
          right: 0,
          child: Column(
            children: [
              // Pill-shaped label.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Meditation for tonight",
                  style: Theme.of(context).textTheme.subtitle2?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              // Dynamic mood text.
              Text(
                mood,
                style: Theme.of(context).textTheme.subtitle1?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your Body's Wisdom",
                style: Theme.of(context).textTheme.headline4?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Show current time in 24-hr format.
              Text(
                currentTime,
                style: Theme.of(context).textTheme.subtitle1?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 40),
              // Updated play button that plays music.
              const _AnimatedPlayButton(),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildNavigationOptions(BuildContext context) {
  final navigationItems = [
    {
      'title': 'Medicine Reminder',
      'icon': Icons.medical_services,
      'screen': const MedicationScreen(),
      'color': Colors.blue,
      'description': 'Track and manage your medications',
      'background': const Color(0xFFE3F2FD),
    },
    {
      'title': 'Appointments',
      'icon': Icons.calendar_today,
      'screen': const AppointmentsListScreen(),
      'color': Colors.green,
      'description': 'Schedule and view appointments',
      'background': const Color(0xFFE8F5E9),
    },
    {
      'title': 'Emergency',
      'icon': Icons.emergency,
      'screen': const EmergencyScreen(),
      'color': Colors.red,
      'description': 'Quick access to emergency contacts',
      'background': const Color(0xFFFFEBEE),
    },
    {
      'title': 'Health Tracking',
      'icon': Icons.monitor_heart,
      'screen': const HealthScreen(),
      'color': Colors.orange,
      'description': 'Monitor your health vitals',
      'background': const Color(0xFFFFF3E0),
    },
    {
      'title': 'Memory Support',
      'icon': Icons.face,
      'screen': const FaceRecognitionScreen(),
      'color': Colors.purple,
      'description': 'Recognize family and friends',
      'background': const Color(0xFFF3E5F5),
    },
    {
      'title': 'Relax Mode',
      'icon': Icons.spa,
      'screen': const RelaxModeScreen(),
      'color': Colors.teal,
      'description': 'Listen to calming ASMR sounds',
      'background': const Color(0xFFE0F2F1),
    },
    {
      'title': 'Settings',
      'icon': Icons.settings,
      'screen': const SettingsScreen(),
      'color': Colors.grey,
      'description': 'Customize app preferences',
      'background': const Color(0xFFF5F5F5),
    },
  ];

  return ScrollConfiguration(
    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...navigationItems.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Container(
              decoration: BoxDecoration(
                color: item['background'] as Color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (item['color'] as Color).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => item['screen'] as Widget),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: item['color'] as Color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['description'] as String,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: item['color'] as Color,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )).toList(),
        ],
      ),
    ),
  );
}

void _showNavigationAssistant(BuildContext context) {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();
  bool _isListening = false;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(  // Use StatefulBuilder to update dialog state
      builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient Header with Search
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade100, Colors.purple.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Updated Row with proper constraints
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Navigation Assistant',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Transform.scale(
                              scale: 0.8, 
                              child: Switch(
                                value: _isVoiceEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _isVoiceEnabled = value;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        value ? 'Voice input enabled' : 'Voice input disabled'
                                      ),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Updated TextField with better constraints
                    SizedBox(
                      height: 48, 
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocus,
                        decoration: InputDecoration(
                          hintText: 'Type what you\'re looking for...',
                          hintStyle: const TextStyle(fontSize: 14),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.search, size: 20),
                          ),
                          suffixIcon: _isVoiceEnabled ? Container(
                            width: 40, // Fixed width for mic button
                            margin: const EdgeInsets.all(4),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: _isListening ? Colors.red : Colors.grey,
                                size: 20,
                              ),
                              onPressed: () async {
                                if (_isVoiceEnabled) {
                                  if (!_isListening) {
                                    var available = await _speechToText.initialize();
                                    if (available) {
                                      setState(() => _isListening = true);
                                      HapticFeedback.mediumImpact();
                                      
                                      await _speechToText.listen(
                                        onResult: (result) {
                                          if (result.finalResult) {
                                            searchController.text = result.recognizedWords;
                                            setState(() => _isListening = false);
                                            _handleNavigation(context, result.recognizedWords);
                                          }
                                        },
                                      );
                                    }
                                  } else {
                                    setState(() => _isListening = false);
                                    _speechToText.stop();
                                  }
                                }
                              },
                            ),
                          ) : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Quick Access Chips
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildSuggestionChip(context, 'Medicine', Colors.blue),
                    _buildSuggestionChip(context, 'Emergency', Colors.red),
                    _buildSuggestionChip(context, 'Relax', Colors.teal),
                    _buildSuggestionChip(context, 'Health', Colors.orange),
                  ],
                ),
              ),
              const Divider(),
              // Available Options List
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.medical_services, color: Colors.blue),
                        title: const Text('Medicine Reminder'),
                        subtitle: const Text('Manage your medications'),
                        onTap: () => _handleNavigation(context, 'medicine'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.emergency, color: Colors.red),
                        title: const Text('Emergency'),
                        subtitle: const Text('Quick access to emergency contacts'),
                        onTap: () => _handleNavigation(context, 'emergency'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.spa, color: Colors.teal),
                        title: const Text('Relax Mode'),
                        subtitle: const Text('Listen to calming sounds'),
                        onTap: () => _handleNavigation(context, 'relax'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.face, color: Colors.purple),
                        title: const Text('Memory Support'),
                        subtitle: const Text('Recognize family members'),
                        onTap: () => _handleNavigation(context, 'face'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_today, color: Colors.green),
                        title: const Text('Appointments'),
                        subtitle: const Text('Manage your schedules'),
                        onTap: () => _handleNavigation(context, 'appointment'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.monitor_heart, color: Colors.orange),
                        title: const Text('Health Tracking'),
                        subtitle: const Text('Monitor your vitals'),
                        onTap: () => _handleNavigation(context, 'health'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// helper method for suggestion chips
Widget _buildSuggestionChip(BuildContext context, String label, Color color) {
  return ActionChip(
    avatar: Icon(
      label == 'Medicine' ? Icons.medical_services :
      label == 'Emergency' ? Icons.emergency :
      Icons.spa,
      size: 16,
      color: color,
    ),
    label: Text(label),
    labelStyle: TextStyle(color: color),
    backgroundColor: color.withOpacity(0.1),
    side: BorderSide(color: color.withOpacity(0.3)),
    onPressed: () => _handleNavigation(context, label),
  );
}

void _handleNavigation(BuildContext context, String query) {
  query = query.toLowerCase();
  
  // Define navigation mappings with keywords
  final navigationMappings = {
    'medicine': {
      'keywords': ['medicine', 'medication', 'pills', 'drugs', 'reminder'],
      'screen': const MedicationScreen(),
      'message': 'Opening Medicine Reminder...',
    },
    'appointment': {
      'keywords': ['appointment', 'schedule', 'doctor', 'visit', 'meeting'],
      'screen': const AppointmentsListScreen(),
      'message': 'Opening Appointments...',
    },
    'emergency': {
      'keywords': ['emergency', 'sos', 'help', 'urgent', 'crisis'],
      'screen': const EmergencyScreen(),
      'message': 'Opening Emergency...',
    },
    'health': {
      'keywords': ['health', 'vitals', 'tracking', 'monitor', 'stats'],
      'screen': const HealthScreen(),
      'message': 'Opening Health Tracking...',
    },
    'face': {
      'keywords': ['face', 'memory', 'recognition', 'family', 'remember'],
      'screen': const FaceRecognitionScreen(),
      'message': 'Opening Memory Support...',
    },
    'relax': {
      'keywords': ['relax', 'meditation', 'calm', 'peace', 'asmr', 'music'],
      'screen': const RelaxModeScreen(),
      'message': 'Opening Relax Mode...',
    },
    'settings': {
      'keywords': ['settings', 'preferences', 'config', 'setup'],
      'screen': const SettingsScreen(),
      'message': 'Opening Settings...',
    },
  };

  // Find matching screen
  for (var entry in navigationMappings.entries) {
    if ((entry.value['keywords'] as List<String>).any((keyword) => query.contains(keyword))) {
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(entry.value['message'] as String)),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => entry.value['screen'] as Widget),
      );
      return;
    }
  }

  // No match found
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('I couldn\'t find what you\'re looking for. Please try different words.'),
      duration: Duration(seconds: 2),
    ),
  );
}

@override
void dispose() {
  _pageController.dispose();
  _speechToText.stop();
  super.dispose(); 
}

}
/// Animated wave widget.
class _AnimatedWave extends StatefulWidget {
  final double height;
  const _AnimatedWave({Key? key, required this.height}) : super(key: key);

  @override
  _AnimatedWaveState createState() => _AnimatedWaveState();
}

class _AnimatedWaveState extends State<_AnimatedWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (ctx, child) {
        return ClipPath(
          clipper: _AnimatedWaveClipper(_controller.value),
          child: Container(
            height: widget.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFE3F3),
                  Color(0xFFE5D6FF),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedWaveClipper extends CustomClipper<Path> {
  final double animationValue;
  _AnimatedWaveClipper(this.animationValue);
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.75);
    final waveHeight = 20.0;
    final waveLength = size.width / 2;
    final shift = animationValue * waveLength;
    for (double x = 0; x <= size.width + waveLength; x += waveLength) {
      final controlX = x + waveLength / 2 - shift;
      final controlY = size.height * 0.75 + waveHeight * ((x.toInt().isEven) ? 1 : -1);
      final endX = x + waveLength - shift;
      final endY = size.height * 0.75;
      path.quadraticBezierTo(controlX, controlY, endX, endY);
    }
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(_AnimatedWaveClipper oldClipper) => true;
}

/// Updated bobbing play button that integrates AI-based music playback.

class _AnimatedPlayButton extends StatefulWidget {
  const _AnimatedPlayButton({Key? key}) : super(key: key);
  @override
  _AnimatedPlayButtonState createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<_AnimatedPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;
  final MusicService _musicService = MusicService();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Bobbing animation controller.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _offsetAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (ctx, child) {
        return Transform.translate(
          offset: Offset(0, _offsetAnimation.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _isPlaying
                      ? Colors.blueAccent.withOpacity(0.8)
                      : Colors.black12,
                  blurRadius: _isPlaying ? 20 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () async {
                if (_isPlaying) {
                  await _musicService.audioPlayer.pause();
                  setState(() {
                    _isPlaying = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Music Paused')),
                  );
                } else {
                  try {
                    await _musicService.playRecommendedSong();
                    final song = await _musicService.getRecommendedSong();
                    setState(() {
                      _isPlaying = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Now playing: ${song['title']} (${song['mood']})',
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  key: ValueKey<bool>(_isPlaying),
                  size: 32,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
/// Carousel that shows 2 tiles per page.
class _CircularCarousel extends StatefulWidget {
  final bool elderMode;
  const _CircularCarousel({Key? key, required this.elderMode}) : super(key: key);
  @override
  State<_CircularCarousel> createState() => _CircularCarouselState();
}
class _CircularCarouselState extends State<_CircularCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<_CarouselTile> _tiles = [
    _CarouselTile(
      title: "Medicine Reminder",
      subtitle: "Timely notifications",
      icon: Icons.medication,
    ),
    _CarouselTile(
      title: "Appointments",
      subtitle: "Upcoming schedules",
      icon: Icons.calendar_today,
    ),
    _CarouselTile(
      title: "Emergency",
      subtitle: "Quick SOS",
      icon: Icons.emergency,
    ),
    _CarouselTile(
      title: "Health Tracking",
      subtitle: "Vitals, steps, etc.",
      icon: Icons.monitor_heart,
    ),
    _CarouselTile(
      title: "Memory Support",
      subtitle: "Family forever",
      icon: Icons.format_quote,
    ),
    _CarouselTile(
      title: "Relax Mode",
      subtitle: "Unwind & rest",
      icon: Icons.spa,
    ),
  ];
  late final List<List<_CarouselTile>> _pagedTiles;
  
  @override
  void initState() {
    super.initState();
    _pagedTiles = [];
    for (int i = 0; i < _tiles.length; i += 2) {
      _pagedTiles.add(_tiles.sublist(i, i + 2));
    }
    _pageController.addListener(() {
      final page = _pageController.page ?? 0;
      final rounded = page.round();
      if (rounded != _currentPage && rounded < _pagedTiles.length) {
        setState(() {
          _currentPage = rounded;
        });
        HapticFeedback.lightImpact();
      }
    });
  }
  @override
  
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dot indicator.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pagedTiles.length, (index) {
            final isActive = (index == _currentPage);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 12 : 8,
              height: isActive ? 12 : 8,
              decoration: BoxDecoration(
                color: isActive ? Colors.purpleAccent : Colors.grey,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
        const SizedBox(height: 7),
        // PageView for the tiles.
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _pagedTiles.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              HapticFeedback.lightImpact();
            },
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, pageIndex) {
              final pair = _pagedTiles[pageIndex];
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: pair.map((tile) {
                  return Expanded(
                    child: _buildTile(context, tile),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
Widget _buildTile(BuildContext context, _CarouselTile tile) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        // Minimal floral pattern
        image: const DecorationImage(
          image: AssetImage('assets/images/floral_pattern.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Routing logic based on tile title.
            if (tile.title == "Medicine Reminder") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MedicationScreen()),
              );
            } else if (tile.title == "Appointments") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppointmentsListScreen()),
              );
            } else if (tile.title == "Emergency") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmergencyScreen()),
              );
            } else if (tile.title == "Health Tracking") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HealthScreen()),
              );
            } else if (tile.title == "Memory Support") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FaceRecognitionScreen()),
              );
            } else if (tile.title == "Relax Mode") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RelaxModeScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Feature not implemented")),
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tile.icon, size: 40, color: Colors.black87),
              const SizedBox(height: 8),
              Text(
                tile.title,
                style: Theme.of(context).textTheme.subtitle1?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                tile.subtitle,
                style: Theme.of(context).textTheme.caption?.copyWith(
                      fontSize: widget.elderMode ? 14 : 12,
                      color: Colors.black54,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarouselTile {
  final String title;
  final String subtitle;
  final IconData icon;
  _CarouselTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}