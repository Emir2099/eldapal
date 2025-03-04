import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';

class SleepTrackerDetailScreen extends StatefulWidget {
  const SleepTrackerDetailScreen({Key? key}) : super(key: key);

  @override
  State<SleepTrackerDetailScreen> createState() => _SleepTrackerDetailScreenState();
}

class _SleepTrackerDetailScreenState extends State<SleepTrackerDetailScreen> {
  // Dynamic sleep stage data (0 = Awake, 1 = REM, 2 = 1 ST, 3 = 2 ST, 4 = Deep)
  List<int> sleepStages = List.filled(20, 0);
  final HealthFactory _health = HealthFactory();

  // These values will be computed dynamically.
  String sleepDurationText = "0h 0m";
  String dateRangeText = "";

  // For time selection below (if needed)
  String? selectedTime;
  String? selectedDay;

  @override
  void initState() {
    super.initState();
    fetchSleepData();
  }

  /// Fetch sleep data from Health API and update sleep duration and stage data.
  Future<void> fetchSleepData() async {
    final now = DateTime.now();
    // Query for sleep data from yesterday to now.
    final startTime = DateTime(now.year, now.month, now.day - 1);
    final endTime = now;
    
    // Set date range dynamically (e.g. "3 Mar – 4 Mar" if today is 4 Mar)
    setState(() {
      dateRangeText = "${DateFormat('d MMM').format(startTime)} – ${DateFormat('d MMM').format(endTime)}";
    });

    final types = [HealthDataType.SLEEP_ASLEEP];
    bool requested = await _health.requestAuthorization(types);
    if (requested) {
      try {
        List<HealthDataPoint> sleepData = await _health.getHealthDataFromTypes(
          startTime,
          endTime,
          types,
        );
        // Sum the total sleep duration (in minutes) from the data points.
        int totalMinutes = 0;
        for (var point in sleepData) {
          totalMinutes += point.dateTo.difference(point.dateFrom).inMinutes;
        }
        // Convert total minutes to hours and minutes.
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;
        // Process sleep data into a stage distribution (placeholder logic).
        List<int> stages = processSleepData(sleepData);

        setState(() {
          sleepDurationText = "${hours}h ${minutes}m";
          sleepStages = stages;
        });
      } catch (e) {
        print("Error fetching sleep data: $e");
      }
    } else {
      print("Authorization not granted");
    }
  }

  /// Process HealthDataPoint sleep data into discrete stage values.
  /// (Replace this placeholder logic with your actual conversion.)
  List<int> processSleepData(List<HealthDataPoint> data) {
    if (data.isEmpty) return List.filled(20, 0); // Default to Awake if no data.
    // For demonstration, we simply distribute fixed stages.
    List<int> stages = List.filled(20, 0);
    for (int i = 0; i < 20; i++) {
      if (i < 5) {
        stages[i] = 0; // Awake
      } else if (i < 10) {
        stages[i] = 1; // REM
      } else if (i < 15) {
        stages[i] = 3; // Stage 2
      } else {
        stages[i] = 4; // Deep
      }
    }
    return stages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // The UI remains exactly as before.
      body: SafeArea(
        child: Stack(
          children: [
            // Gradient background: white → pastel pink → light purple.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Color(0xFFFFE3F3), Color(0xFFE5D6FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Subtle wave in top-right corner.
            Positioned(
              top: 0,
              right: 0,
              child: CustomPaint(
                painter: _WavePainter(),
                size: const Size(150, 150),
              ),
            ),
            // Main content column.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopRow(context),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildMainHeader(),
                ),
                const SizedBox(height: 24),
                Expanded(child: _buildChartArea()),
                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Custom top row with a back arrow and a settings icon.
  Widget _buildTopRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings, size: 26),
            onPressed: () {
              // Optionally open a settings dialog.
            },
          ),
        ],
      ),
    );
  }

  /// Header displaying dynamic sleep duration and date range.
  Widget _buildMainHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sleepDurationText,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black54),
            const SizedBox(width: 6),
            Text(
              dateRangeText.isNotEmpty ? dateRangeText : "Loading...",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }

  /// Chart area: left axis with sleep stage labels and dynamic stepping line chart.
  Widget _buildChartArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left axis with sleep stage labels.
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    _StageLabel("AWAKE"),
                    _StageLabel("REM"),
                    _StageLabel("1 ST"),
                    _StageLabel("2 ST"),
                    _StageLabel("DEEP"),
                  ],
                ),
                const SizedBox(width: 12),
                // Right: dynamic sleep chart drawn from sleepStages.
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CustomPaint(
                      painter: SleepDataPainter(sleepStages),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Time axis labels.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("11:43 PM", style: TextStyle(color: Colors.black54)),
                Text("3:43 AM", style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single label for the left axis.
class _StageLabel extends StatelessWidget {
  final String text;
  const _StageLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
      textAlign: TextAlign.right,
    );
  }
}

/// Custom painter that draws a sleep tracking line chart based on real sleep data.
class SleepDataPainter extends CustomPainter {
  final List<int> sleepStages;
  SleepDataPainter(this.sleepStages);

  // Mapping sleep stage to a relative Y position.
  final Map<int, double> stageToY = {
    0: 0.15, // Awake
    1: 0.3,  // REM
    2: 0.45, // 1 ST
    3: 0.65, // 2 ST
    4: 0.85, // Deep
  };

  @override
  void paint(Canvas canvas, Size size) {
    if (sleepStages.isEmpty) return;
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..color = Colors.deepPurple;
    final dx = size.width / (sleepStages.length - 1);
    final path = Path();
    double y = stageToY[sleepStages[0]]! * size.height;
    path.moveTo(0, y);
    for (int i = 1; i < sleepStages.length; i++) {
      y = stageToY[sleepStages[i]]! * size.height;
      final x = i * dx;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SleepDataPainter oldDelegate) {
    return oldDelegate.sleepStages != sleepStages;
  }
}

/// Subtle wave painter for the top-right corner.
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.4,
      size.width,
      size.height,
    );
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}
