import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> initialize() async {
    await _speech.initialize();
    await _tts.setLanguage('en-US');
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<String?> listen() async {
    if (!await _speech.hasPermission) {
      return null;
    }
    
    String result = '';
    await _speech.listen(
      onResult: (value) => result = value.recognizedWords,
      listenFor: const Duration(seconds: 5),
    );
    
    await Future.delayed(const Duration(seconds: 5));
    return result.trim();
  }

  Future<void> playSound(String assetPath) async {
    await _audioPlayer.setAsset(assetPath);
    await _audioPlayer.play();
  }

  void dispose() {
    _tts.stop();
    _speech.cancel();
    _audioPlayer.dispose();
  }
}