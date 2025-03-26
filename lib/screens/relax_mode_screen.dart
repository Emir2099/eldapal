import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart'; // Add this import at the top

class RelaxModeScreen extends StatefulWidget {
  const RelaxModeScreen({Key? key}) : super(key: key);

  @override
  State<RelaxModeScreen> createState() => _RelaxModeScreenState();
}

class _RelaxModeScreenState extends State<RelaxModeScreen> {
  final List<ASMRTile> asmrTiles = [
    ASMRTile(
      title: "Rain Sounds",
      subtitle: "Gentle rainfall",
      assetPath: "assets/audio/rain.mp3",
      icon: Icons.water_drop,
      gradientColors: [Colors.blue.shade200, Colors.blue.shade400],
    ),
    ASMRTile(
      title: "Ocean Waves",
      subtitle: "Calming waves",
      assetPath: "assets/audio/waves.mp3",
      icon: Icons.waves,
      gradientColors: [Colors.cyan.shade200, Colors.cyan.shade400],
    ),
    ASMRTile(
      title: "Forest Birds",
      subtitle: "Nature sounds",
      assetPath: "assets/audio/forest.mp3",
      icon: Icons.forest,
      gradientColors: [Colors.green.shade200, Colors.green.shade400],
    ),
    ASMRTile(
      title: "White Noise",
      subtitle: "Peaceful ambience",
      assetPath: "assets/audio/white_noise.mp3",
      icon: Icons.air,
      gradientColors: [Colors.purple.shade200, Colors.purple.shade400],
    ),
  ];

  Map<String, AudioPlayer> audioPlayers = {};

  @override
  void initState() {
    super.initState();
    // Initialize audio players for each tile
    for (var tile in asmrTiles) {
      audioPlayers[tile.assetPath] = AudioPlayer();
    }
  }

  @override
  void dispose() {
    // Dispose all audio players
    for (var player in audioPlayers.values) {
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'ASMR Sounds',
          style: TextStyle(color: Colors.black87), // Changed to black
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87), // Back arrow to black
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE3F3), Color(0xFFE5D6FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: asmrTiles.length,
              itemBuilder: (context, index) {
                return _buildASMRCard(asmrTiles[index]);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildASMRCard(ASMRTile tile) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayers[tile.assetPath]!.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final isPlaying = playerState?.playing ?? false;

        return GestureDetector(
          onTap: () => _handleTileTap(tile),
          child: TweenAnimationBuilder(
            tween: ColorTween(
              begin: tile.gradientColors[0],
              end: isPlaying ? tile.gradientColors[1] : tile.gradientColors[0],
            ),
            duration: const Duration(milliseconds: 500),
            builder: (context, Color? color, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color!,
                      tile.gradientColors[1],
                    ],
                    begin: isPlaying ? Alignment.topLeft : Alignment.bottomRight,
                    end: isPlaying ? Alignment.bottomRight : Alignment.topLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: tile.gradientColors[1].withOpacity(0.3),
                      blurRadius: isPlaying ? 12 : 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    if (isPlaying)
                      Positioned.fill(
                        child: _buildRippleEffect(tile.gradientColors[1]),
                      ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedSlide(
                            duration: const Duration(milliseconds: 300),
                            offset: isPlaying ? const Offset(0, -0.1) : Offset.zero,
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 300),
                              scale: isPlaying ? 1.1 : 1.0,
                              child: Icon(
                                tile.icon,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tile.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tile.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0,
                              end: isPlaying ? 1.0 : 0.0,
                            ),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, value, child) {
                              return Transform.rotate(
                                angle: value * 2 * 3.14159,
                                child: Icon(
                                  isPlaying ? Icons.pause_circle : Icons.play_circle,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleTileTap(ASMRTile tile) async {
    // Add haptic feedback
    HapticFeedback.mediumImpact();
    
    final player = audioPlayers[tile.assetPath]!;
    
    try {
      if (player.playing) {
        await player.pause();
        // Light haptic when pausing
        HapticFeedback.lightImpact();
      } else {
        // Stop other players
        for (var otherPlayer in audioPlayers.values) {
          if (otherPlayer != player) {
            await otherPlayer.stop();
          }
        }
        
        // Play selected audio
        await player.setAsset(tile.assetPath);
        await player.setLoopMode(LoopMode.one);
        await player.play();
        
        // Heavy haptic when starting playback
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // Error haptic
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }
}

// Add this new widget for the ripple effect
Widget _buildRippleEffect(Color color) {
  return AnimatedOpacity(
    duration: const Duration(milliseconds: 200),
    opacity: 0.15,
    child: CustomPaint(
      painter: RipplePainter(color),
    ),
  );
}

// Add this new class for the ripple effect
class RipplePainter extends CustomPainter {
  final Color color;
  RipplePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    const numberOfRipples = 3;
    const maxRadius = 30.0;

    for (var i = 0; i < numberOfRipples; i++) {
      final radius = (i + 1) * (maxRadius / numberOfRipples);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) => false;
}

class ASMRTile {
  final String title;
  final String subtitle;
  final String assetPath;
  final IconData icon;
  final List<Color> gradientColors;

  ASMRTile({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.icon,
    required this.gradientColors,
  });
}