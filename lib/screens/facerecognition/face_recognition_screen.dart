import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'face_recognition_service.dart';

class FaceRecognitionScreen extends StatefulWidget {
  const FaceRecognitionScreen({Key? key}) : super(key: key);

  @override
  FaceRecognitionScreenState createState() => FaceRecognitionScreenState();
}

class FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  final FaceRecognitionService _service = FaceRecognitionService();
  final Map<String, String> _relationships = {
    'son': 'Son',
    'daughter': 'Daughter',
    'caretaker': 'Caretaker',
    'doctor': 'Doctor',
  };
  late final Future<void> _initialization;
  
  // Voice and quiz features
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isQuizActive = false;
  Map<String, dynamic>? _quizFace;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  int _totalQuestionsTarget = 0;
  bool _isVoiceInputEnabled = false;  // Voice input disabled by default

  @override
  void initState() {
    super.initState();
    _initialization = _service.initialize();
    _initVoiceServices();
  }

  Future<void> _initVoiceServices() async {
    await _speech.initialize();
    await _tts.setLanguage('en-US');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.speak('Welcome to Family Recognition. ${_service.registeredFaces.length} family members loaded');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Recognition'),
        actions: [
          IconButton(
            icon: Icon(_isVoiceInputEnabled ? Icons.mic : Icons.mic_off),
            onPressed: () {
              setState(() {
                _isVoiceInputEnabled = !_isVoiceInputEnabled;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isVoiceInputEnabled 
                      ? 'Voice input enabled' 
                      : 'Voice input disabled'
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Toggle Voice Input',
          ),
          IconButton(
            icon: Icon(_isQuizActive ? Icons.stop : Icons.quiz),
            onPressed: _isQuizActive ? _stopQuiz : _startMemoryQuiz,
            tooltip: _isQuizActive ? 'Stop Quiz' : 'Start Memory Quiz',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isQuizActive) {
      return _buildQuizInterface();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildRegisterButton(),
          const SizedBox(height: 20),
          Expanded(child: _buildFaceGrid()),
        ],
      ),
    );
  }

  // Existing methods remain the same until _buildFaceCard

  Widget _buildFaceCardDuplicate(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () => _tts.speak('This is your ${data['relationship']} ${data['name']}'),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.file(
                  File(data['imagePath']),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['relationship'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New quiz functionality
  Widget _buildQuizInterface() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_quizFace != null) ...[
            CircleAvatar(
              radius: 80,
              backgroundImage: FileImage(File(_quizFace!['imagePath'])),
            ),
            const SizedBox(height: 20),
            Text(
              'Who is this person?',
              style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Type Answer'),
                  onPressed: () async {
                    final answer = await showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Enter Name'),
                        content: TextField(
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (value) => Navigator.pop(context, value),
                        ),
                      ),
                    );
                    if (answer != null) {
                      _checkQuizAnswer(answer);
                    }
                  },
                ),
                const SizedBox(width: 16),
                if (_isVoiceInputEnabled)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.mic),
                    label: const Text('Speak Answer'),
                    onPressed: () async {
                      final answer = await _listenForAnswer();
                      if (answer != null) {
                        _checkQuizAnswer(answer);
                      }
                    },
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'Score: $_correctAnswers/$_totalQuestions',
            style: const TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  void _startMemoryQuiz() async {
    if (_service.registeredFaces.isEmpty) {
      _tts.speak('No family members registered yet');
      return;
    }

    if (_service.registeredFaces.length == 1) {
      _tts.speak('You need at least two family members registered to start the quiz');
      return;
    }

    setState(() {
      _isQuizActive = true;
      _correctAnswers = 0;
      _totalQuestions = 0;
    });
    
    // Start quiz with total questions equal to number of faces
    _totalQuestionsTarget = _service.registeredFaces.length;
    await _nextQuizQuestion();
  }

  Future<void> _nextQuizQuestion() async {
    if (_totalQuestions >= _totalQuestionsTarget || !_isQuizActive) {
      _stopQuiz();
      return;
    }

    final faces = _service.registeredFaces;
    final randomFace = faces[Random().nextInt(faces.length)];
    
    setState(() => _quizFace = randomFace);
    
    await _tts.speak('Who is this person?');
    
    if (!_isVoiceInputEnabled) {
      // If voice input is disabled, wait for manual input
      return;
    }

    await Future.delayed(const Duration(seconds: 2));
    final answer = await _listenForAnswer();
    if (answer != null && _isQuizActive) {  // Check if still active
      _checkQuizAnswer(answer);
    }
  }

  Future<String?> _listenForAnswer() async {
    if (!await _speech.hasPermission) return null;
    
    String result = '';
    await _speech.listen(
      onResult: (value) => result = value.recognizedWords,
      listenFor: const Duration(seconds: 5),
    );
    await Future.delayed(const Duration(seconds: 5));
    return result.trim();
  }

  Future<void> _playSound(String assetPath) async {
    await _audioPlayer.setAsset(assetPath);
    await _audioPlayer.play();
  }

  void _stopQuiz() {
    // Stop all audio immediately
    _tts.stop();
    _audioPlayer.stop();
    _speech.cancel();
    
    setState(() {
      _isQuizActive = false;
      _quizFace = null;
    });

    // Add a small delay before final score to ensure previous sounds are stopped
    if (_totalQuestions > 0) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {  // Check if widget is still mounted
          _tts.speak(
            'Quiz ended. You got $_correctAnswers out of $_totalQuestions correct'
          );
        }
      });
    }
  }

  void _checkQuizAnswer(String answer) {
    if (answer.toLowerCase() == _quizFace!['name'].toString().toLowerCase()) {
      _correctAnswers++;
      _playSound('assets/sounds/correct.mp3');
    } else {
      _playSound('assets/sounds/wrong.mp3');
    }
    _totalQuestions++;
    _nextQuizQuestion();
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Stop everything when navigating away
    _tts.stop();
    _speech.cancel();
    _audioPlayer.stop();
    setState(() {
      _isQuizActive = false;
      _quizFace = null;
    });
  }

  Future<void> _refreshData() async {
    await _service.initialize();
    setState(() {});
  }

  Widget _buildRegisterButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add_a_photo),
      label: const Text('Add Family Member'),
      onPressed: () => _showRegistrationDialog(),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        textStyle: const TextStyle(fontSize: 20),
      ),
    );
  }

  void _showRegistrationDialog() {
    String name = '';
    String relationship = 'son';
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Register New Family Member'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => name = value,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: relationship,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Relationship'
                  ),
                  items: _relationships.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: (value) => relationship = value ?? 'son',
                ),
                if (isProcessing)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isProcessing ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isProcessing 
                    ? null 
                    : () async {
                        setState(() => isProcessing = true);
                        try {
                          if (name.isEmpty) {
                            throw Exception('Please enter a name');
                          }
                          await _service.registerFace(name, relationship, context); // Pass context here
                          if (mounted) {
                            Navigator.pop(context);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Registration successful!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            final error = e.toString();
                            if (error.contains('permissions')) {
                              // Show permission dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Permissions Required'),
                                  content: const Text(
                                    'Camera and storage permissions are required for face recognition. '
                                    'Would you like to open settings to enable them?'
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _service.openAppSettings();
                                      },
                                      child: const Text('Open Settings'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${error.replaceAll('Exception:', '')}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } finally {
                          if (mounted) setState(() => isProcessing = false);
                        }
                      },
                child: const Text('Register'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFaceGrid() {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
          ),
          itemCount: _service.registeredFaces.length,
          itemBuilder: (context, index) {
            final data = _service.registeredFaces[index];
            return _buildFaceCard(data);
          },
        );
      },
    );
  }

  Widget _buildFaceCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () async {
        await _tts.stop(); // Stop any previous speech
        await _tts.speak('This is your ${data['relationship']} ${data['name']}');
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.file(
                  File(data['imagePath']),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['relationship'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}