// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a delay to simulate splash screen loading
    Future.delayed(Duration(seconds: 3), () {
      // Navigate to sign in screen after delay
      // Using pushReplacement to replace the splash screen
      // so the user can't go back to it
      Navigator.pushReplacementNamed(context, '/signin');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your app logo here
            Image.asset(
              'assets/logo.png', // Make sure this exists in your assets folder
              height: 150,
              width: 150,
              // If the asset doesn't exist, Flutter will show an error
              // You can set an error builder or use a placeholder
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.favorite,
                  color: Color(0xFF2A9D8F),
                  size: 120,
                );
              },
            ),
            SizedBox(height: 40),
            Text(
              'Trusting Hands',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A9D8F),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Let's you in",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 50),
            // Add a loading indicator
            CircularProgressIndicator(
              color: Color(0xFF2A9D8F),
            ),
          ],
        ),
      ),
    );
  }
}