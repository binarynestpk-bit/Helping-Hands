// lib/blood/blood_donation.dart (UPDATED WITH ACTION BUTTONS GRID)
import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';

class BloodDonationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: RichText(
          text: TextSpan(
            text: 'Blood ',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveHeadingSize(context),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: 'Donation',
                style: TextStyle(
                  color: Color(0xFFE01219),
                ),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner Image
            Container(
              width: double.infinity,
              height: screenHeight * 0.22, // Responsive height
              decoration: BoxDecoration(
                color: Colors.red.shade50,
              ),
              child: Image.asset(
                'assets/blood_donation_banner.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    Icons.bloodtype,
                    size: screenWidth * 0.15, // Responsive icon size
                    color: Colors.red,
                  ),
                ),
              ),
            ),

            Padding(
              padding: ResponsiveHelper.responsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Donate Blood, Save Lives",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveHeadingSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Your blood donation can save up to 3 lives. Every drop counts. Be a hero by donating blood or requesting blood when in need.",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveTextSize(context),
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // NEW: Action Buttons Section (same as Shaheed family style)
                  _buildActionButtonsGrid(context, ResponsiveHelper.isSmallScreen(context)),
                  SizedBox(height: 30),

                  // Blood Types Section
                  Text(
                    "Blood Types & Compatibility",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveHeadingSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: screenWidth > 600
                        ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildBloodTypeCard(context, "A+", "Can receive from: A+, A-, O+, O-"),
                            _buildBloodTypeCard(context, "A-", "Can receive from: A-, O-"),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildBloodTypeCard(context, "B+", "Can receive from: B+, B-, O+, O-"),
                            _buildBloodTypeCard(context, "B-", "Can receive from: B-, O-"),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildBloodTypeCard(context, "AB+", "Can receive from: All types"),
                            _buildBloodTypeCard(context, "AB-", "Can receive from: AB-, A-, B-, O-"),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildBloodTypeCard(context, "O+", "Can receive from: O+, O-"),
                            _buildBloodTypeCard(context, "O-", "Can receive from: O- only"),
                          ],
                        ),
                      ],
                    )
                        : Column(
                      children: [
                        _buildBloodTypeCard(context, "A+", "Can receive from: A+, A-, O+, O-", isFullWidth: true),
                        SizedBox(height: 10),
                        _buildBloodTypeCard(context, "A-", "Can receive from: A-, O-", isFullWidth: true),
                        SizedBox(height: 10),
                        _buildBloodTypeCard(context, "B+", "Can receive from: B+, B-, O+, O-", isFullWidth: true),
                        SizedBox(height: 10),
                        _buildBloodTypeCard(context, "B-", "Can receive from: B-, O-", isFullWidth: true),
                        SizedBox(height: 10),
                        _buildBloodTypeCard(context, "AB+", "Can receive from: All types", isFullWidth: true),
                        SizedBox(height: 10),
                        _buildBloodTypeCard(context, "AB-", "Can receive from: AB-, A-, B-, O-", isFullWidth: true),
                        SizedBox(height: 10),
                        _buildBloodTypeCard(context, "O+", "Can receive from: O+, O-", isFullWidth: true),
                        SizedBox(height: 10),
                        _buildBloodTypeCard(context, "O-", "Can receive from: O- only", isFullWidth: true),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // FAQ Section
                  Text(
                    "Frequently Asked Questions",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveHeadingSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  _buildFaqItem(
                      "Who can donate blood?",
                      "Healthy individuals aged 17-65, weighing at least 50kg, can donate blood."
                  ),
                  _buildFaqItem(
                      "How often can I donate blood?",
                      "Men can donate every 12 weeks, women every 16 weeks."
                  ),
                  _buildFaqItem(
                      "Is blood donation safe?",
                      "Yes, it's completely safe. New, sterile equipment is used for each donor."
                  ),
                  _buildFaqItem(
                      "How long does it take to donate blood?",
                      "The actual blood donation takes about 8-10 minutes, but the entire process takes about an hour."
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SizedBox(
            width: ResponsiveHelper.responsiveButtonWidth(context),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE01219),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/blood-form');
              },
              child: Text(
                "Request Blood Now",
                style: TextStyle(
                  fontSize: ResponsiveHelper.isSmallScreen(context) ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // NEW: Action Buttons Grid (same style as Shaheed family screen but with blood donation theme)
  Widget _buildActionButtonsGrid(BuildContext context, bool isSmallScreen) {
    return Column(
      children: [
        // Request Blood Button (Primary - Blood Red)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/blood-form');
            },
            icon: Icon(Icons.local_hospital, color: Colors.white),
            label: Text(
              "Request Blood",
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE01219), // Blood red color
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),
        SizedBox(height: 12),

        // My Blood Requests Button (Outlined - Blood Red)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/my-blood-requests');
            },
            icon: Icon(Icons.list_alt, color: Color(0xFFE01219)),
            label: Text(
              "My Blood Requests",
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: Color(0xFFE01219)),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: Color(0xFFE01219)),
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),
        SizedBox(height: 12),

        // View Blood Requests Button (Outlined - Dark)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/blood-requests-list');
            },
            icon: Icon(Icons.view_list, color: Colors.black),
            label: Text(
              "View All Requests",
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: Colors.black),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: Colors.black),
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBloodTypeCard(BuildContext context, String bloodType, String description, {bool isFullWidth = false}) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: isFullWidth ? double.infinity : (screenWidth < 360 ? 120 : 150),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFE01219).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              bloodType,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE01219),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: ResponsiveHelper.isSmallScreen(context) ? 10 : 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}