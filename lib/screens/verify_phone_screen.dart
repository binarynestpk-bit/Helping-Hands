// lib/screens/verify_phone_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helpinghand/utils/responsive_helper.dart';

class VerifyPhoneScreen extends StatefulWidget {
  final String mode; // 'signup' or 'reset_password'

  // Constructor with default parameter
  const VerifyPhoneScreen({Key? key, this.mode = 'signup'}) : super(key: key);

  @override
  _VerifyPhoneScreenState createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  List<TextEditingController> controllers = List.generate(6, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      controllers[index].text = value.substring(value.length - 1);
      if (index < 5) {
        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
      }
    }
  }

  void _onKeyDown(RawKeyEvent event, int index) {
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        index > 0 &&
        controllers[index].text.isEmpty) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }
  }

  void _verifyCode() {
    // Check the mode and navigate accordingly
    if (widget.mode == 'reset_password') {
      Navigator.pushNamed(context, '/create-new-password');
    } else {
      // Default to signup flow
      Navigator.pushReplacementNamed(context, '/profile-completion');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and responsive flags
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    // Calculate responsive sizes
    final titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final subtitleFontSize = isSmallScreen ? 14.0 : 16.0;
    final otpFieldSize = isSmallScreen ? 45.0 : 50.0;
    final otpTextSize = isSmallScreen ? 18.0 : 22.0;
    final buttonHeight = isSmallScreen ? 45.0 : 50.0;
    final buttonTextSize = isSmallScreen ? 16.0 : 18.0;
    final linkTextSize = isSmallScreen ? 14.0 : 16.0;
    final verticalSpacing = screenHeight * 0.03;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: isSmallScreen ? 22 : 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.04
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Verify ',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Phone',
                    style: TextStyle(color: Color(0xFF2A9D8F)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Code is sent to 123-123-123',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: subtitleFontSize, color: Color(0xFF000000)),
            ),
            SizedBox(height: verticalSpacing),

            // OTP Input Fields
            Form(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: otpFieldSize,
                    height: otpFieldSize,
                    margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 3 : 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black54),
                    ),
                    alignment: Alignment.center,
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (event) => _onKeyDown(event, index),
                      child: TextField(
                        controller: controllers[index],
                        focusNode: focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: TextStyle(
                            fontSize: otpTextSize,
                            fontWeight: FontWeight.bold
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) => _onChanged(value, index),
                        onTap: () {
                          controllers[index].selection = TextSelection.fromPosition(
                            TextPosition(offset: controllers[index].text.length),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 20),

            // Request Again Link
            GestureDetector(
              onTap: () {
                // Request code again logic
              },
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Didn't receive code? ",
                  style: TextStyle(fontSize: linkTextSize, color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Request Again',
                      style: TextStyle(
                        color: Color(0xFF2A9D8F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: verticalSpacing),

            // Verify Button
            SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2A9D8F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _verifyCode,
                child: Text(
                  'Verify And Next',
                  style: TextStyle(fontSize: buttonTextSize, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}