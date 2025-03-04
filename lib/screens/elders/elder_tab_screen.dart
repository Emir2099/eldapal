import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'elder_mode_enabled_screen.dart';
import 'elder_auth_screen.dart';

class ElderTabScreen extends StatefulWidget {
  final ValueChanged<bool> onElderModeChanged; 
  
  const ElderTabScreen({
    Key? key,
    required this.onElderModeChanged, 
  }) : super(key: key);

  @override
  State<ElderTabScreen> createState() => _ElderTabScreenState();
}

class _ElderTabScreenState extends State<ElderTabScreen> {
  bool isElderModeEnabled = false;

  Future<void> _exitElderMode() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ElderModeAuthScreen()),
    );
    if (result == true) {
      widget.onElderModeChanged(false);
      setState(() => isElderModeEnabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isElderModeEnabled,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isElderModeEnabled ? 'Elder Mode Active' : 'Elder Tab'),
          leading: isElderModeEnabled
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _exitElderMode,
                )
              : null,
          automaticallyImplyLeading: !isElderModeEnabled,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return isElderModeEnabled
                  ? const ElderModeEnabledScreen()
                  : SingleChildScrollView(
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                          minWidth: constraints.maxWidth,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 24.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Do you want to enter Elder Mode?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8), // Match the No button
                                ),
                              ),
                              onPressed: () async {
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ElderModeAuthScreen(),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {
                                    isElderModeEnabled = true;
                                  });
                                  widget.onElderModeChanged(true);
                                }
                              },
                              child: const Text(
                                'Yes',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 35,
                                  vertical: 16,
                                ),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Elder Mode not enabled.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Text(
                                'No',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}

