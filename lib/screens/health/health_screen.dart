import 'package:flutter/material.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Monitoring'),
      ),
      body: const Center(
        child: Text('Health Screen'),
      ),
    );
  }
}
