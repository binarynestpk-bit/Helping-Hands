// lib/screens/forget_password_screen.dart
import 'package:flutter/material.dart';
import 'package:helpinghand/screens/verify_phone_screen.dart';
import 'package:helpinghand/utils/responsive_helper.dart';

class ForgetPasswordScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and responsive flags
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    // Calculate responsive sizes
    final titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final subtitleFontSize = isSmallScreen ? 14.0 : 16.0;
    final labelFontSize = isSmallScreen ? 14.0 : 16.0;
    final hintFontSize = isSmallScreen ? 12.0 : 14.0;
    final buttonHeight = isSmallScreen ? 45.0 : 50.0;
    final buttonTextSize = isSmallScreen ? 16.0 : 18.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mobile Number',
                style: TextStyle(
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                ),
              ),
            ),
            SizedBox(height: 5),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Image.asset(
                      'assets/call.png',
                      width: iconSize,
                      height: iconSize
                  ),
                ),
                prefixText: '+92 ',
                prefixStyle: TextStyle(
                    color: Colors.black,
                    fontSize: isSmallScreen ? 14 : 16
                ),
                hintText: 'Enter Your Phone Number',
                hintStyle: TextStyle(
                  color: Color(0xFF9C9C9C),
                  fontSize: hintFontSize,
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFECECEC)),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
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
                      builder: (context) => VerifyPhoneScreen(mode: 'reset_password'),
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