import 'dart:io';
import 'dart:math';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaceRecognitionService {
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector();
  Box<dynamic>? _faceDatabase;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _faceDatabase = await Hive.openBox('faceDatabase');
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      // Request permissions one by one with proper error handling
      final camera = await Permission.camera.request();
      final storage = await Permission.storage.request();
      final photos = await Permission.photos.request();

      // Check if all permissions are granted
      if (camera.isGranted && (storage.isGranted || photos.isGranted)) {
        return true;
      }

      // If any permission is permanently denied, throw specific error
      if (camera.isPermanentlyDenied || storage.isPermanentlyDenied || photos.isPermanentlyDenied) {
        throw Exception('Some permissions are permanently denied. Please enable them in settings.');
      }

      return false;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  Future<File> _getImage(BuildContext context) async {
    final permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      throw Exception('Please grant camera and storage permissions to use this feature');
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await showDialog<XFile>(
        context: context, // Use provided context instead of Get.context
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Take Photo'),
                onTap: () async {
                  final XFile? photo = await picker.pickImage(
                    source: ImageSource.camera,
                    preferredCameraDevice: CameraDevice.front,
                  );
                  if (photo != null) {
                    Navigator.pop(context, photo);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  final XFile? photo = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (photo != null) {
                    Navigator.pop(context, photo);
                  }
                },
              ),
            ],
          ),
        ),
      );

      if (image == null) throw Exception('No image selected');
      return File(image.path);
    } catch (e) {
      throw Exception('Error selecting image: $e');
    }
  }

  Future<void> registerFace(String name, String relationship, BuildContext context) async {
    if (name.isEmpty) throw Exception('Name cannot be empty');
    
    await initialize();
    try {
      final image = await _getImage(context);
      final inputImage = InputImage.fromFile(image);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        throw Exception('No faces detected in the image');
      }

      final face = faces.first;
      final faceData = {
        'name': name,
        'relationship': relationship,
        'embeddings': _serializeLandmarks(face.landmarks),
        'imagePath': image.path,
        'lastRecognized': DateTime.now(),
      };
      
      await _faceDatabase!.put(name, faceData);
      await _faceDatabase!.flush(); // Force immediate write
      print('Successfully registered face: $name');

    } catch (e) {
      print('Error registering face: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _serializeLandmarks(
      Map<FaceLandmarkType, FaceLandmark?> landmarks) {
    return landmarks.map((key, value) {
      if (value == null) return MapEntry(key.toString(), null);
      return MapEntry(
        key.toString(),
        {'x': value.position.x.toDouble(), 'y': value.position.y.toDouble()},
      );
    })..removeWhere((key, value) => value == null);
  }

  Future<Map<String, dynamic>?> recognizeFace(File image) async {
    await initialize();
    try {
      final inputImage = InputImage.fromFile(image);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) return null;

      final detectedFace = faces.first;
      MapEntry<String, dynamic>? bestMatch;

      for (var entry in _faceDatabase!.toMap().entries) {
        final storedFace = entry.value;
        final similarity = _calculateSimilarity(
          detectedFace.landmarks,
          storedFace['embeddings'],
        );

        if (similarity > 0.8 && (bestMatch == null || similarity > bestMatch.value)) {
          bestMatch = MapEntry(entry.key, storedFace);
        }
      }
      return bestMatch?.value;
    } catch (e) {
      print('Error recognizing face: $e');
      return null;
    }
  }

  double _calculateSimilarity(
    Map<FaceLandmarkType, FaceLandmark?> detected,
    Map<String, dynamic> stored,
  ) {
    double distance = 0;
    for (var entry in stored.entries) {
      final type = FaceLandmarkType.values.firstWhere(
        (e) => e.toString() == entry.key,
        orElse: () => FaceLandmarkType.leftEye,
      );
      final dPoint = detected[type]?.position;
      final sPoint = entry.value as Map<String, dynamic>;
      
      if (dPoint != null) {
        distance += pow(dPoint.x - sPoint['x'], 2) + 
                    pow(dPoint.y - sPoint['y'], 2);
      }
    }
    return 1 / (1 + sqrt(distance));
  }

  List<Map<String, dynamic>> get registeredFaces {
    if (_faceDatabase == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _faceDatabase!.values
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
    Get.snackbar(
      'Settings',
      'Please enable required permissions',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void dispose() {
    _faceDetector.close();
    _faceDatabase?.close();
  }
}