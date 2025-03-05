import 'dart:io';
import 'package:flutter/material.dart';
import 'face_recognition_service.dart';

class FaceRecognitionScreen extends StatefulWidget {
  const FaceRecognitionScreen({Key? key}) : super(key: key);

  @override
  FaceRecognitionScreenState createState() => FaceRecognitionScreenState();
}

class FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  final FaceRecognitionService _service = FaceRecognitionService();
  final Map<String, String> _relationships = {
    'son': 'Son',
    'daughter': 'Daughter',
    'caretaker': 'Caretaker',
    'doctor': 'Doctor',
  };
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _service.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Recognition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRegisterButton(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildFaceGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await _service.initialize();
    setState(() {});
  }

  Widget _buildRegisterButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add_a_photo),
      label: const Text('Add Family Member'),
      onPressed: () => _showRegistrationDialog(),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        textStyle: const TextStyle(fontSize: 20),
      ),
    );
  }

  void _showRegistrationDialog() {
    String name = '';
    String relationship = 'son';
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Register New Family Member'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => name = value,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: relationship,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Relationship'
                  ),
                  items: _relationships.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: (value) => relationship = value ?? 'son',
                ),
                if (isProcessing)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isProcessing ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isProcessing 
                    ? null 
                    : () async {
                        setState(() => isProcessing = true);
                        try {
                          if (name.isEmpty) {
                            throw Exception('Please enter a name');
                          }
                          await _service.registerFace(name, relationship, context); // Pass context here
                          if (mounted) {
                            Navigator.pop(context);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Registration successful!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            final error = e.toString();
                            if (error.contains('permissions')) {
                              // Show permission dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Permissions Required'),
                                  content: const Text(
                                    'Camera and storage permissions are required for face recognition. '
                                    'Would you like to open settings to enable them?'
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _service.openAppSettings();
                                      },
                                      child: const Text('Open Settings'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${error.replaceAll('Exception:', '')}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } finally {
                          if (mounted) setState(() => isProcessing = false);
                        }
                      },
                child: const Text('Register'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFaceGrid() {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
          ),
          itemCount: _service.registeredFaces.length,
          itemBuilder: (context, index) {
            final data = _service.registeredFaces[index];
            return _buildFaceCard(data);
          },
        );
      },
    );
  }

  Widget _buildFaceCard(Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(data['imagePath']),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  data['relationship'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}