# Eldapal

Eldapal is a Flutter-based mobile application designed to assist elderly users in managing their daily activities, health, and well-being. The app provides a user-friendly interface with features like medication reminders, health tracking, emergency assistance, and more. It also includes an Elder Mode for simplified navigation and accessibility.

---

## Features

### 1. **Home Screen**
- **Dynamic Header**: Displays the current mood (e.g., "Calming", "Relaxing") based on the time of day.
- **Navigation Assistant**: A chatbot-like feature with voice and text input for quick navigation to app features.
- **Quick Access Tiles**: Carousel of tiles for easy access to key features like Medicine Reminder, Appointments, Emergency, and more.

### 2. **Elder Mode**
- Simplified interface for elderly users.
- Large buttons and high-contrast UI for better accessibility.
- SOS button for emergencies.
- Medication alerts with vibration and sound notifications.

### 3. **Medication Management**
- Add, edit, and delete medications.
- Set reminders with date, time, and frequency.
- Mark medications as "Taken" or "Pending".
- View medication history.

### 4. **Health Tracking**
- **Sleep Tracker**: Visualize sleep stages (Awake, REM, Deep Sleep) with a dynamic chart.
- **Step Tracker**: Track daily steps and view hourly breakdowns.
- **Health Overview**: Weekly health data summary with interactive date scroller.

### 5. **Appointments**
- Schedule and manage appointments.
- View upcoming appointments with doctor details.
- Nearest available places for medical consultations.

### 6. **Relax Mode**
- Play ASMR sounds like rain, ocean waves, and forest birds.
- Interactive cards with gradient animations for each sound.
- Background audio playback support.

### 7. **Memory Support**
- Face recognition to identify family members and caregivers.
- Memory quiz to help users recognize loved ones.
- Voice-based interaction for accessibility.

### 8. **Settings**
- Customize app preferences:
  - Enable/disable sounds and notifications.
  - Adjust text size and volume.
  - High contrast mode for better visibility.
  - Language selection (e.g., English, Spanish, French).
- Save and load settings using `SharedPreferences`.

### 9. **Emergency Assistance**
- SOS button for immediate help.
- Emergency call functionality with pre-configured contact numbers.
- Triple vibration feedback for critical alerts.

---

## Technical Details

### **Technologies Used**
- **Flutter**: Cross-platform mobile app development.
- **Dart**: Programming language for Flutter.
- **Hive**: Lightweight database for local storage.
- **Just Audio**: Audio playback for ASMR sounds.
- **Speech to Text**: Voice input for navigation and memory quiz.
- **Google ML Kit**: Face recognition for memory support.
- **Health Package**: Integration with health APIs for sleep and step tracking.

### **Folder Structure**
- `lib/screens`: Contains all the screens of the app.
  - `home_screen.dart`: Main screen with navigation and dynamic header.
  - `medication`: Medication management screens.
  - `health`: Health tracking screens (Sleep Tracker, Step Tracker).
  - `appointments`: Appointment scheduling and details.
  - `elders`: Elder Mode and related screens.
  - `facerecognition`: Memory support with face recognition.
  - `settings`: App settings and preferences.
  - `relax_mode_screen.dart`: Relaxation mode with ASMR sounds.
- `lib/widgets`: Reusable UI components like custom dialogs and date selectors.
- `lib/services`: Background services like music playback and face recognition.
- `lib/providers`: State management for medications and other features.
- `assets`: Contains images, audio files, and other static resources.

---

## Installation

### Prerequisites
- Flutter SDK installed ([Flutter Installation Guide](https://docs.flutter.dev/get-started/install)).
- Android Studio or Visual Studio Code for development.

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/eldapal.git
   ```
2. Navigate to the project directory:
   ```bash
   cd eldapal
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

---

## Permissions

The app requires the following permissions:
- **Camera**: For face recognition.
- **Microphone**: For voice input.
- **Storage**: To save and retrieve face data.
- **Health Data**: To access sleep and step tracking data.
- **Vibration**: For medication and SOS alerts.

Ensure these permissions are granted for the app to function correctly.




