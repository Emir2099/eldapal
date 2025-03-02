import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appointment_model.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({Key? key, required this.appointment}) : super(key: key);

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late String specialty;
  late String doctorName;
  late String dateLabel;
  late String timeLabel;
  late String doctorImageAsset;

  final List<String> mondayTimes = ["10:00 AM", "01:00 PM", "06:00 PM"];
  bool isTuesdayAvailable = false;

  String? selectedTime;
  String? selectedDayLabel;

  @override
  void initState() {
    super.initState();
    final appt = widget.appointment;
    specialty = appt.specialty;
    doctorName = appt.doctorName;
    dateLabel = DateFormat('d MMM').format(appt.dateTime);
    timeLabel = DateFormat('HH:mm, EEE').format(appt.dateTime);
    doctorImageAsset = appt.doctorImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopSection(),
            const SizedBox(height: 16),
            _buildMyAppointmentsCard(),
            const SizedBox(height: 24),
            _buildNearestPlacesSection(),
            const SizedBox(height: 24),
            _buildBottomButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// **Top Section: Gradient + Back Button + Horizontal Icons + Doctor Image**
  Widget _buildTopSection() {
    return Stack(
      children: [
        Container(
          height: 250,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 236, 191, 191), Color.fromARGB(255, 236, 186, 202), Color.fromARGB(255, 228, 215, 230)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 70, left: 30, right: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specialty,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          dateLabel,
                          style: const TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        const SizedBox(width: 18),
                        Text(
                          timeLabel,
                          style: const TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // **Horizontal Icons**
                    Row(
                      children: [
                        _buildIcon(Icons.call),
                        const SizedBox(width: 12),
                        _buildIcon(Icons.videocam),
                        const SizedBox(width: 12),
                        _buildIcon(Icons.chat),
                      ],
                    ),
                  ],
                ),
              ),
              ClipRRect(
                // borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  doctorImageAsset,
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  /// **My Appointments Card**
  Widget _buildMyAppointmentsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.pink.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  dateLabel.split(" ")[0],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const Text("Sep", style: TextStyle(color: Colors.purple)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(timeLabel, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }

  /// **Nearest Available Places Section**
  Widget _buildNearestPlacesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Nearest available places", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildDayRow("5 Sep, Monday", mondayTimes),
          const SizedBox(height: 16),
          _buildDayRow("6 Sep, Tuesday", null),
        ],
      ),
    );
  }

  Widget _buildDayRow(String dayLabel, List<String>? times) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dayLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 28,
          children: times?.map((t) => _buildTimeCard(t, dayLabel)).toList() ?? [_buildTimeCard("Not available", dayLabel)],
        ),
      ],
    );
  }

  Widget _buildTimeCard(String time, String dayLabel) {
    final isSelected = (selectedTime == time && selectedDayLabel == dayLabel);
    return GestureDetector(
      onTap: () => setState(() {
        selectedTime = time;
        selectedDayLabel = dayLabel;
      }),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink.shade300 : Colors.pink.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  /// **Bottom Button**
  Widget _buildBottomButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink.shade100,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {},
        child: Text(
          selectedTime != null ? "Select $selectedTime - $selectedDayLabel" : "Select time",
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    );
  }
}
