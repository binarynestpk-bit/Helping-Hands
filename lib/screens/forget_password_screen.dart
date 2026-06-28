// lib/screens/forget_password_screen.dart
import 'package:flutter/material.dart';
import 'package:helpinghand/screens/verify_phone_screen.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/widgets/phone_input_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController phoneController = TextEditingController();

  // Full E.164 mobile (dial code + number) kept in sync by PhoneInputField.
  String _fullMobile = '+92';

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and responsive flags
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    // Calculate responsive sizes
    final titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final subtitleFontSize = isSmallScreen ? 14.0 : 16.0;
    final buttonHeight = isSmallScreen ? 45.0 : 50.0;
    final buttonTextSize = isSmallScreen ? 16.0 : 18.0;
    final verticalSpacing = screenHeight * 0.03;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
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
                text: 'Forget ',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Password',
                    style: TextStyle(color: Color(0xFF2A9D8F)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'You will receive a 6-digit code to verify next.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: subtitleFontSize, color: Color(0xFF000000)),
            ),
            SizedBox(height: verticalSpacing),

            // Phone Number field
            PhoneInputField(
              controller: phoneController,
              isSmallScreen: isSmallScreen,
              onChanged: (value) => _fullMobile = value,
            ),

            SizedBox(height: verticalSpacing),

            // Send Code Button
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
                onPressed: () {
                  // Validate phone number if needed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerifyPhoneScreen(
                          mode: 'reset_password',
                          phone: _fullMobile),
                    ),
                  );
                },
                child: Text(
                  'Send Code',
                  style: TextStyle(
                    fontSize: buttonTextSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}