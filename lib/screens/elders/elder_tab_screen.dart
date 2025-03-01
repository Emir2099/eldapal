import 'package:flutter/material.dart';

class ElderTabScreen extends StatelessWidget {
  const ElderTabScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // If you don’t want an AppBar, remove it or style differently
      appBar: AppBar(
        title: const Text('Elder Tab'),
      ),
      body: const Center(
        child: Text('Content for the Elder tab goes here.'),
      ),
    );
  }
}
