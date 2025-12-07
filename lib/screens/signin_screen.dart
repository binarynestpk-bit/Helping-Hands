import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/auth_service.dart';
import 'package:helpinghand/services/api_service.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.login(
        identifier: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (response['success'] == true) {
        final user = response['data']['user'];

        // Check user status
        if (user['status'] == 'pending') {
          _showSnackBar('Your account is pending admin approval', isError: true);
        } else if (user['status'] == 'approved') {
          _showSnackBar('Login successful!');
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showSnackBar('Account status: ${user['status']}', isError: true);
        }
      }
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleGuestLogin() {
    // Handle guest login functionality
    _showSnackBar('Accessing as guest...');
    Navigator.pushReplacementNamed(context, '/home');
    // You can also navigate to a specific guest route if needed:
    // Navigator.pushReplacementNamed(context, '/guest-home');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.04
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: DropdownButton<String>(
                value: 'English',
                items: [DropdownMenuItem(value: 'English', child: Text('English'))],
                onChanged: (value) {},
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/group.png',
                    height: screenHeight * 0.2,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.favorite,
                      size: screenHeight * 0.1,
                      color: Color(0xFF2A9D8F),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  RichText(
                    text: TextSpan(
                      text: 'Welcome ',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: 'Back',
                          style: TextStyle(
                            color: Color(0xFF2A9D8F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Login to your account',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Color(0xFF797979),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            buildTextField(
              'Mobile Number or Email',
              'assets/call.png',
              controller: _phoneController,
              prefixText: '',
              isSmallScreen: isSmallScreen,
            ),
            buildPasswordField(
              controller: _passwordController,
              isSmallScreen: isSmallScreen,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forget-password');
                },
                child: Text(
                  'Forget Password?',
                  style: TextStyle(
                    color: Color(0xFF2A9D8F),
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2A9D8F),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : _handleSignIn,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'Login',
                  style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      color: Colors.white
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't Have an account? ",
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xFF2A9D8F),
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // NEW: Guest Login Section
            SizedBox(height: screenHeight * 0.025),

            // OR Divider
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: Color(0xFFECECEC),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "OR",
                    style: TextStyle(
                      color: Color(0xFF797979),
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Color(0xFFECECEC),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.025),

            // Guest Login Button
            Center(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Color(0xFF2A9D8F),
                    width: 1.5,
                  ),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.white,
                ),
                onPressed: _handleGuestLogin,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      color: Color(0xFF2A9D8F),
                      size: isSmallScreen ? 18 : 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "VIEW AS GUEST",
                      style: TextStyle(
                        color: Color(0xFF2A9D8F),
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.03),
          ],
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
                height: isSmallScreen ? 18 : 20,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.phone,
                  size: isSmallScreen ? 18 : 20,
                  color: Color(0xFF2A9D8F),
                ),
              ),
            ),
            hintText: 'Enter Your $label',
            hintStyle: TextStyle(
              color: Color(0xFF9C9C9C),
              fontSize: isSmallScreen ? 14 : 16,
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

  Widget buildPasswordField({
    required TextEditingController controller,
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.0),
              child: Image.asset(
                'assets/lock.png',
                width: isSmallScreen ? 18 : 20,
                height: isSmallScreen ? 18 : 20,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.lock,
                  size: isSmallScreen ? 18 : 20,
                  color: Color(0xFF2A9D8F),
                ),
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Color(0xFF9C9C9C),
                size: isSmallScreen ? 18 : 22,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            hintText: 'Enter Your Password',
            hintStyle: TextStyle(
              color: Color(0xFF9C9C9C),
              fontSize: isSmallScreen ? 14 : 16,
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
}