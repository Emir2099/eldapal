import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';

class StepTrackerDetailScreen extends StatefulWidget {
  const StepTrackerDetailScreen({Key? key}) : super(key: key);

  @override
  State<StepTrackerDetailScreen> createState() => _StepTrackerDetailScreenState();
}

class _StepTrackerDetailScreenState extends State<StepTrackerDetailScreen> {
  int _totalSteps = 0;
  List<int> _hourlySteps = List.filled(24, 0);
  final HealthFactory _health = HealthFactory();
  String _dateRangeText = "";

  @override
  void initState() {
    super.initState();
    fetchStepData();
  }

  Future<void> fetchStepData() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = now;

    setState(() {
      _dateRangeText =
          "${DateFormat('d MMM').format(startOfDay)} – ${DateFormat('d MMM').format(endOfDay)}";
    });

    final types = [HealthDataType.STEPS];
    bool requested = await _health.requestAuthorization(types);
    if (!requested) {
      setState(() => _totalSteps = 0);
      return;
    }

    try {
      List<HealthDataPoint> stepData = await _health.getHealthDataFromTypes(
        startOfDay,
        endOfDay,
        types,
      );
      
      int total = 0;
      List<int> hourly = List.filled(24, 0);
      for (var point in stepData) {
        int steps = int.tryParse(point.value.toString()) ?? 0;
        total += steps;
        int hour = point.dateFrom.hour;
        hourly[hour] += steps;
      }
      
      setState(() {
        _totalSteps = total;
        _hourlySteps = hourly;
      });
    } catch (e) {
      print("Error fetching step data: $e");
      setState(() => _totalSteps = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                  maxWidth: screenWidth,
                ),
                child: Stack(
                  children: [
                    // Background elements
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Color(0xFFDFFFD6), Color(0xFFB3E5FC)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: CustomPaint(
                        painter: _WavePainter(),
                        size: Size(screenWidth * 0.35, screenWidth * 0.35),
                      ),
                    ),

                    // Main content
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.02,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopBar(context, screenWidth),
                          SizedBox(height: screenHeight * 0.02),
                          _buildHeaderSection(screenWidth),
                          SizedBox(height: screenHeight * 0.03),
                          _buildChartSection(screenHeight),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, 
            size: screenWidth * 0.07,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        IconButton(
          icon: Icon(Icons.refresh,
            size: screenWidth * 0.06,
            color: Colors.black87,
          ),
          onPressed: fetchStepData,
        ),
      ],
    );
  }

  Widget _buildHeaderSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Step Tracker",
            style: TextStyle(
              fontSize: screenWidth * 0.09,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: screenWidth * 0.04),
        Row(
          children: [
            Icon(Icons.directions_walk, 
              size: screenWidth * 0.06,
              color: Colors.black54,
            ),
            SizedBox(width: screenWidth * 0.03),
            Text(
              "$_totalSteps steps",
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.02),
        Text(
          _dateRangeText.isNotEmpty ? _dateRangeText : "Loading...",
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

Widget _buildChartSection(double screenHeight) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Container(
        height: screenHeight * 0.4,
        constraints: BoxConstraints(
          minWidth: 100, // Ensure minimum width
          maxWidth: constraints.maxWidth,
        ),
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: _hourlySteps.isEmpty 
            ? Center(child: Text("No data available"))
            : CustomPaint(painter: StepDataPainter(_hourlySteps)),
      );
    },
  );
}
}

class StepDataPainter extends CustomPainter {
  final List<int> hourlySteps;
  StepDataPainter(this.hourlySteps);

  @override
  void paint(Canvas canvas, Size size) {
    if (hourlySteps.isEmpty || size.width <= 0 || size.height <= 0) return;
    
    final paint = Paint()..color = Colors.green;
    final int count = hourlySteps.length;
    const double spacing = 4;
    
    // Ensure valid bar width calculation
    final double availableWidth = size.width - (count + 1) * spacing;
    final double barWidth = availableWidth > 0 ? availableWidth / count : 0;
    
    // Handle empty data case
    final int maxSteps = hourlySteps.reduce(max);
    if (maxSteps == 0 || barWidth <= 0) return;

    for (int i = 0; i < count; i++) {
      int steps = hourlySteps[i];
      final double barHeight = (steps / maxSteps) * size.height;
      
      // Skip drawing if bar height is 0
      if (barHeight <= 0) continue;

      final double x = spacing + i * (barWidth + spacing);
      final Rect rect = Rect.fromLTWH(
        x, 
        size.height - barHeight, 
        barWidth, 
        barHeight
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(barWidth / 2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StepDataPainter oldDelegate) =>
      oldDelegate.hourlySteps != hourlySteps;
}

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