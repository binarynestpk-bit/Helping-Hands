// lib/education/education_requests.dart
import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';

class EducationRequests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Education Support ',
            style: TextStyle(
                color: Colors.black,
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w500
            ),
            children: [
              TextSpan(
                text: 'Requests',
                style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.w600
                ),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 10
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search field moved to the top
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by student name, institution, or degree...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(), // Pushes the empty state to the center
            Image.asset(
              'assets/empty-folder.png',
              height: screenWidth * 0.25, // Responsive height
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.folder_open,
                size: screenWidth * 0.25,
                color: Colors.grey.shade300,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'No Requests Available Right Now',
              style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold
              ),
            ),
            Spacer(), // Keeps content centered
          ],
        ),
      ),
    );
  }
}