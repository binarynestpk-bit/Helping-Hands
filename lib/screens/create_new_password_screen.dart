// lib/screens/create_new_password_screen.dart
import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  @override
  _CreateNewPasswordScreenState createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                text: 'Create New ',
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
              'Your new password must be different from previous used password.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: subtitleFontSize, color: Color(0xFF797979)),
            ),
            SizedBox(height: verticalSpacing),

            // Password field
            _buildPasswordField(
              'Password',
              'assets/lock.png',
              _passwordController,
              _obscurePassword,
                  () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              isSmallScreen,
              labelFontSize,
              hintFontSize,
              iconSize,
            ),

            // Confirm Password field
            _buildPasswordField(
              'Confirm Password',
              'assets/lock.png',
              _confirmPasswordController,
              _obscureConfirmPassword,
                  () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              isSmallScreen,
              labelFontSize,
              hintFontSize,
              iconSize,
            ),

            SizedBox(height: verticalSpacing),

            // Reset Password Button
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
                  if (_validateInputs()) {
                    // Password reset successful, navigate to sign in screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password reset successful'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Navigate to signin screen
                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/signin', (route) => false
                      );
                    });
                  }
                },
                child: Text(
                  'Reset Password',
                  style: TextStyle(fontSize: buttonTextSize, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      String label,
      String iconPath,
      TextEditingController controller,
      bool obscureText,
      VoidCallback onToggleVisibility,
      bool isSmallScreen,
      double labelFontSize,
      double hintFontSize,
      double iconSize,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: labelFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.0),
              child: Image.asset(
                  iconPath,
                  width: iconSize,
                  height: iconSize
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Color(0xFF9C9C9C),
                size: iconSize,
              ),
              onPressed: onToggleVisibility,
            ),
            hintText: 'Enter Your $label',
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
        SizedBox(height: 20),
      ],
    );
  }

  bool _validateInputs() {
    // Get the password and confirm password texts
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Check if passwords are empty
    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Check if passwords match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Check password length
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 6 characters long'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }
}