// lib/utils/responsive_helper.dart
import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: MediaQuery.of(context).size.width * 0.05,
      vertical: 10,
    );
  }

  // Get responsive width for cards
  static double responsiveCardWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.9; // 90% of screen width
  }

  // Get responsive height for images
  static double responsiveImageHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.25; // 25% of screen height
  }

  // Get responsive button width
  static double responsiveButtonWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.85; // 85% of screen width
  }

  // Get responsive text size for headings
  static double responsiveHeadingSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 360 ? 20 : 24;
  }

  // Get responsive text size for normal text
  static double responsiveTextSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 360 ? 14 : 16;
  }

  // Check if device has small screen
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }
}