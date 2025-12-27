// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:helpinghand/screens/verify_phone_screen.dart';
import 'package:helpinghand/screens/email_verification_screen.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:helpinghand/utils/responsive_helper.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isChecked = false;
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedCity;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.post('/auth/register', {
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'city': _selectedCity,
      });

      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        // Navigate to email verification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(
              email: _emailController.text.trim(),
              userName: _nameController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = e.toString();
      if (errorMessage.contains('User already exists')) {
        errorMessage = 'An account with this email or phone already exists';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validateInputs() {
    // Basic validation
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return false;
    }

    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return false;
    }

    // Check terms acceptance
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please accept the Terms & Conditions')),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.04
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Create ',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A9D8F),
                    ),
                    children: [
                      TextSpan(
                        text: 'New Account',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 5),
              Center(
                child: Text(
                  'Sign up to get started',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Color(0xFF797979),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              buildTextField(
                'Full Name',
                'assets/user.png',
                controller: _nameController,
                isSmallScreen: isSmallScreen,
              ),
              buildTextField(
                'Email Address',
                'assets/sms-tracking.png',
                controller: _emailController,
                isSmallScreen: isSmallScreen,
              ),
              buildTextField(
                'Mobile Number',
                'assets/call.png',
                controller: _phoneController,
                prefixText: '+92 ',
                isSmallScreen: isSmallScreen,
              ),
              buildPasswordField(
                'Password',
                'assets/lock.png',
                isConfirmPassword: false,
                isSmallScreen: isSmallScreen,
              ),
              buildPasswordField(
                'Confirm Password',
                'assets/lock.png',
                isConfirmPassword: true,
                isSmallScreen: isSmallScreen,
              ),
              buildDropdownField(
                'City/Emirate',
                'assets/global-search.png',
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: 10),

              // Checkbox functionality
              Row(
                children: [
                  Transform.scale(
                    scale: isSmallScreen ? 0.9 : 1.0,
                    child: Checkbox(
                      value: _isChecked,
                      activeColor: Color(0xFF2A9D8F),
                      onChanged: (bool? value) {
                        setState(() {
                          _isChecked = value!;
                        });
                      },
                    ),
                  ),
                  Text(
                    'I agree with ',
                    style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Show terms & conditions
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Text(
                              'This is a sample terms and conditions text. In a real app, this would contain the actual terms and conditions of your service.',
                              style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Close',
                                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        color: Color(0xFF2A9D8F),
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2A9D8F),
                    minimumSize: Size(double.infinity, isSmallScreen ? 45 : 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: (_isChecked && !_isLoading) ? _handleSignUp : null,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Continue',
                          style: TextStyle(fontSize: isSmallScreen ? 16 : 18, color: Colors.white),
                        ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/signin');
                      },
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          color: Color(0xFF2A9D8F),
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label,
      String iconPath, {
        required TextEditingController controller,
        bool isPassword = false,
        String prefixText = '',
        required bool isSmallScreen,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            prefixText: prefixText,
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.0),
              child: Image.asset(
                  iconPath,
                  width: isSmallScreen ? 18 : 20,
                  height: isSmallScreen ? 18 : 20
              ),
            ),
            hintText: 'Enter Your $label',
            hintStyle: TextStyle(
              color: Color(0xFF9C9C9C),
              fontSize: isSmallScreen ? 12 : 14,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFECECEC)),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildPasswordField(
      String label,
      String iconPath, {
        required bool isConfirmPassword,
        required bool isSmallScreen,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
        SizedBox(height: 5),
        TextField(
          controller: isConfirmPassword ? _confirmPasswordController : _passwordController,
          obscureText: isConfirmPassword ? _obscureConfirmPassword : _obscurePassword,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.0),
              child: Image.asset(
                  iconPath,
                  width: isSmallScreen ? 18 : 20,
                  height: isSmallScreen ? 18 : 20
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isConfirmPassword
                    ? (_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility)
                    : (_obscurePassword ? Icons.visibility_off : Icons.visibility),
                color: Color(0xFF9C9C9C),
                size: isSmallScreen ? 18 : 20,
              ),
              onPressed: () {
                setState(() {
                  if (isConfirmPassword) {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  } else {
                    _obscurePassword = !_obscurePassword;
                  }
                });
              },
            ),
            hintText: 'Enter Your $label',
            hintStyle: TextStyle(
              color: Color(0xFF9C9C9C),
              fontSize: isSmallScreen ? 12 : 14,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFECECEC)),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildDropdownField(
      String label,
      String iconPath, {
        required bool isSmallScreen,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: _selectedCity,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.0),
              child: Image.asset(
                  iconPath,
                  width: isSmallScreen ? 18 : 20,
                  height: isSmallScreen ? 18 : 20
              ),
            ),
            hintText: 'Select City',
            hintStyle: TextStyle(
              color: Color(0xFF9C9C9C),
              fontSize: isSmallScreen ? 12 : 14,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFECECEC)),
            ),
          ),
          items: ['Dubai', 'Abu Dhabi', 'Sharjah', 'Ajman']
              .map((city) => DropdownMenuItem(
            value: city,
            child: Text(
              city,
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            ),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCity = value;
            });
          },
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, size: isSmallScreen ? 24 : 30),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}