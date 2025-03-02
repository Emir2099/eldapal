class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String doctorImageUrl; // URL or asset path for doc image

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.doctorImageUrl,
  });
}
