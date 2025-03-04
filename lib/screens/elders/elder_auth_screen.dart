import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ----------------- ElderModeAuthScreen -----------------

/// This screen shows an OTP-style password input (four circular fields)
/// to enable (or disable) Elder Mode.
/// The correct OTP is hard-coded as "1234" in this example.
class ElderModeAuthScreen extends StatefulWidget {
  const ElderModeAuthScreen({Key? key}) : super(key: key);

  @override
  State<ElderModeAuthScreen> createState() => _ElderModeAuthScreenState();
}

class _ElderModeAuthScreenState extends State<ElderModeAuthScreen> {
  final int pinLength = 4;
  final List<TextEditingController> controllers = [];
  final List<FocusNode> focusNodes = [];
  String enteredPin = "";
  final String correctPin = "1234";

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < pinLength; i++) {
      controllers.add(TextEditingController());
      focusNodes.add(FocusNode());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNodes[0]);
    });
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onPinChanged() {
    String pin = controllers.map((c) => c.text).join();
    if (pin.length == pinLength) {
      if (pin == correctPin) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect password. Please try again.")),
        );
        for (var controller in controllers) {
          controller.clear();
        }
        FocusScope.of(context).requestFocus(focusNodes[0]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Password"),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive sizes
            final pinFieldSize = constraints.maxWidth * 0.12;
            final fontSize = isSmallScreen ? 16.0 : 20.0;
            final fieldPadding = isSmallScreen ? 4.0 : 8.0;
            
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.05,
                  vertical: constraints.maxHeight * 0.05,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Enter 4-digit Elder Mode Password",
                      style: TextStyle(fontSize: fontSize),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: constraints.maxHeight * 0.05),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(pinLength, (index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: fieldPadding),
                            child: _buildPinField(index, pinFieldSize),
                          );
                        }),
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

  Widget _buildPinField(int index, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.all(size * 0.2),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(size * 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(size * 0.5),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < pinLength - 1) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
          }
          _onPinChanged();
        },
      ),
    );
  }
}