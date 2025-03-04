import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:eldapal/screens/health/sleep_tracker_details.dart';
import 'package:eldapal/screens/health/step_tracker_details.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({Key? key}) : super(key: key);

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final List<DateTime> _dates = [];
  late DateTime _selectedDate;
  String _sleepDurationText = "0h 0m";
  List<int> _sleepStages = List.filled(20, 0);
  int _totalSteps = 0;
  final HealthFactory _health = HealthFactory();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateWeekDates();
    _fetchHealthData();
  }

  void _generateWeekDates() {
    final now = DateTime.now();
    for (int i = -3; i <= 3; i++) {
      _dates.add(now.add(Duration(days: i)));
    }
    _selectedDate = now;
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    HapticFeedback.lightImpact();
    _fetchHealthData();
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Future<void> _fetchHealthData() async {
    setState(() => _isLoading = true);
    await Future.wait([_fetchSleepData(), _fetchStepData()]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchSleepData() async {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day - 1);
    final endTime = now;
    final types = [HealthDataType.SLEEP_ASLEEP];

    try {
      bool authorized = await _health.requestAuthorization(
        [HealthDataType.SLEEP_ASLEEP, HealthDataType.STEPS],
      );

      if (!authorized) {
        setState(() => _sleepDurationText = "Permission required");
        return;
      }

      List<HealthDataPoint> sleepData = await _health.getHealthDataFromTypes(
        startTime,
        endTime,
        types,
      );

      int totalMinutes = 0;
      for (var point in sleepData) {
        totalMinutes += point.dateTo.difference(point.dateFrom).inMinutes;
      }
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      setState(() {
        _sleepDurationText = "${hours}h ${minutes}m";
        _sleepStages = _processSleepData(sleepData);
      });
    } on PlatformException catch (e) {
      setState(() => _sleepDurationText = "Error: ${e.message}");
    } catch (e) {
      setState(() => _sleepDurationText = "Error loading data");
    }
  }

  Future<void> _fetchStepData() async {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day);
    final endTime = now;

    try {
      List<HealthDataPoint> stepData = await _health.getHealthDataFromTypes(
        startTime,
        endTime,
        [HealthDataType.STEPS],
      );

      int total = 0;
      for (var point in stepData) {
        total += int.tryParse(point.value.toString()) ?? 0;
      }
      setState(() => _totalSteps = total);
    } on PlatformException catch (e) {
      setState(() => _totalSteps = -1);
    } catch (e) {
      setState(() => _totalSteps = -2);
    }
  }

  List<int> _processSleepData(List<HealthDataPoint> data) {
    if (data.isEmpty) return List.filled(20, 0);
    List<int> stages = List.filled(20, 0);
    for (int i = 0; i < 20; i++) {
      if (i < 5) stages[i] = 0;
      else if (i < 10) stages[i] = 1;
      else if (i < 15) stages[i] = 3;
      else stages[i] = 4;
    }
    return stages;
  }

  String _getStepText() {
    if (_totalSteps > 0) return NumberFormat().format(_totalSteps);
    if (_totalSteps == -1) return "Permission required";
    if (_totalSteps == -2) return "Data error";
    return "Loading...";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            _buildDateScroller(),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildSleepTrackerCard(context),
                          const SizedBox(height: 16),
                          _buildBottomCards(context),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            "Health Overview",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDateScroller() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = _isSameDay(date, _selectedDate);
          return GestureDetector(
            onTap: () => _onDateSelected(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepPurpleAccent : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSleepTrackerCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepTrackerDetailScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFDDD1FF),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sleep tracker",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _sleepDurationText,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.bedtime, color: Colors.black54),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: CustomPaint(
                painter: SleepDataPainter(_sleepStages),
              ),
            ),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: const Text("Tap for details", 
                style: TextStyle(color: Colors.black38)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: _buildStepsCard(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCalendarCard(constraints),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepsCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StepTrackerDetailScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD0ECFF),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Steps", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Column(
            //   children: [
            //     Text(
            //       _getStepText(),
            //       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            //     const SizedBox(width: 8),
            //     const Text("steps", style: TextStyle(color: Colors.black54)),
            //   ],
            // ),
            const SizedBox(height: 4),
            Text("Distance: ${(_totalSteps * 0.0008).toStringAsFixed(2)} km", 
              style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: const Text("Tap for details", 
                style: TextStyle(color: Colors.black38)),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildCalendarCard(BoxConstraints constraints) {
  final DateTime now = DateTime.now();
  final int currentDay = now.day;

  return Container(
    padding: EdgeInsets.all(constraints.maxWidth * 0.04),
    decoration: BoxDecoration(
      color: const Color(0xFFFFD6E6),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Calendar",
          style: TextStyle(
            fontSize: constraints.maxWidth * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 115, // Fixed height for grid
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final dayNum = index + 1;
              final isToday = dayNum == currentDay;
              
              return Container(
                decoration: BoxDecoration(
                  color: isToday ? Colors.deepPurpleAccent : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isToday ? Colors.deepPurple : Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: isToday
                      ? [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    dayNum.toString(),
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
}

class SleepDataPainter extends CustomPainter {
  final List<int> sleepStages;
  SleepDataPainter(this.sleepStages);

  final Map<int, double> stageToY = {
    0: 0.15, 1: 0.3, 2: 0.45, 3: 0.65, 4: 0.85};

  @override
  void paint(Canvas canvas, Size size) {
    if (sleepStages.isEmpty || size.width <= 0) return;
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
      path.lineTo(i * dx, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SleepDataPainter oldDelegate) => oldDelegate.sleepStages != sleepStages;
}