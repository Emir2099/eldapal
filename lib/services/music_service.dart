import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class MusicService {
  final AudioPlayer audioPlayer = AudioPlayer();

  // Replace with your actual Jamendo API client ID.
  final String clientId = '';

  /// Retrieve a recommended track from Jamendo based on the time of day.
  Future<Map<String, String>> getRecommendedSong() async {
    final hour = DateTime.now().hour;
    String mood;
    String searchQuery;

    if (hour >= 6 && hour < 12) {
      mood = 'CALMING';
      searchQuery = 'soothing'; // Adjust query as needed.
    } else if (hour >= 12 && hour < 18) {
      mood = 'SOOTHING';
      searchQuery = 'soothing';
    } else {
      mood = 'RELAXING';
      searchQuery = 'soothing';
    }

    final url = Uri.parse(
        'https://api.jamendo.com/v3.0/tracks/?client_id=$clientId&format=json&limit=1&include=musicinfo&search=$searchQuery');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].length > 0) {
        final track = data['results'][0];
        final title = track['name'];
        final previewUrl = track['audio'];
        if (previewUrl != null) {
          return {'title': title, 'mood': mood, 'url': previewUrl};
        } else {
          throw Exception('No preview URL available for this track.');
        }
      } else {
        throw Exception('No tracks found for the search query.');
      }
    } else {
      throw Exception('Failed to fetch recommendation: ${response.statusCode}');
    }
  }

  /// Play the recommended song using just_audio.
  Future<void> playRecommendedSong() async {
    final song = await getRecommendedSong();
    // Set the URL of the audio (returns a Future).
    await audioPlayer.setUrl(song['url']!);
    // Start playing.
    audioPlayer.play();
  }
}
