// lib/shaheed/shaheed_family_screen.dart - UPDATED WITH MY REQUESTS BUTTON
import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';

class ShuhadaFamilySupportApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

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
        title: RichText(
          text: TextSpan(
            text: 'Shuhada ',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: 'Family Support',
                style: TextStyle(
                  color: Color(0xFF2A9D8F),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero Image
              Image.asset(
                'assets/shuhada_family_support.png',
                height: screenHeight * 0.2,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: screenHeight * 0.2,
                  color: Color(0xFFEAF5F4),
                  child: Center(
                    child: Icon(
                      Icons.family_restroom,
                      size: screenWidth * 0.2,
                      color: Color(0xFF2A9D8F),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),

              // Title and Description
              Text(
                "Extend Your Compassion by Donating to Support the Shuhada Family",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Your contributions help provide financial assistance, education, and healthcare to the families of martyrs who sacrificed their lives for the nation.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Action Buttons Section
              _buildActionButtonsGrid(context, isSmallScreen),
              SizedBox(height: screenHeight * 0.03),

              // Information Cards
              _buildInfoCard(
                'How Your Donation Helps',
                'Your contributions provide immediate relief to families of martyrs, helping with:',
                [
                  'Monthly financial assistance for basic needs',
                  'Educational support for children',
                  'Medical care and health insurance',
                  'Vocational training and employment assistance',
                  'Psychological support and counseling',
                ],
                Icons.volunteer_activism,
                Color(0xFF2A9D8F),
                isSmallScreen,
              ),
              SizedBox(height: 20),
              _buildInfoCard(
                'Who Can Apply',
                'Our support program is available to:',
                [
                  'Immediate family members of martyrs',
                  'Spouses and children of martyrs',
                  'Parents dependent on martyred children',
                  'Siblings who were dependent on martyred individuals',
                ],
                Icons.people,
                Color(0xFF2A9D8F),
                isSmallScreen,
              ),
              SizedBox(height: 20),
              _buildInfoCard(
                'Required Documents',
                'To verify eligibility, please have these documents ready:',
                [
                  'Proof of martyrdom certificate',
                  'Family relationship documents',
                  'Identity documents (CNIC)',
                  'Recent photographs',
                  'Bank account details for fund transfers',
                ],
                Icons.description,
                Color(0xFF2A9D8F),
                isSmallScreen,
              ),
              SizedBox(height: screenHeight * 0.03),

              // Testimonial
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFEAF5F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      "\"The support we received has been life-changing. It helped my children continue their education after we lost my husband. We are forever grateful for this compassionate initiative.\"",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "- Fatima, wife of Shaheed Abdul Rahman",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Donate Button
              Container(
                width: double.infinity,
                height: isSmallScreen ? 50 : 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showDonationOptions(context, isSmallScreen);
                  },
                  icon: Icon(Icons.favorite, color: Colors.white),
                  label: Text(
                    "Donate Now",
                    style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2A9D8F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtonsGrid(BuildContext context, bool isSmallScreen) {
    return Column(
      children: [
        // Request Support Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/shaheed-family-form');
            },
            icon: Icon(Icons.add_circle, color: Colors.white),
            label: Text(
              "Request Support",
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2A9D8F),
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),
        SizedBox(height: 12),

        // My Requests Button - NEW
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/my-family-requests');
            },
            icon: Icon(Icons.list_alt, color: Color(0xFF2A9D8F)),
            label: Text(
              "My Family Requests",
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: Color(0xFF2A9D8F)),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: Color(0xFF2A9D8F)),
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),
        SizedBox(height: 12),

        // View All Requests Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/shaheed-requests');
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

  Widget _buildInfoCard(
      String title,
      String subtitle,
      List<String> points,
      IconData icon,
      Color color,
      bool isSmallScreen
      ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10),
          ...points.map((point) => _buildBulletPoint(point, isSmallScreen)).toList(),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Color(0xFF2A9D8F), fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showDonationOptions(BuildContext context, bool isSmallScreen) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Choose Donation Method",
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _buildDonationOption(
              context,
              "One-Time Donation",
              "Make a single contribution to help families in need",
              Icons.payment,
                  () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/shaheed-donation-confirm');
              },
              isSmallScreen,
            ),
            SizedBox(height: 16),
            _buildDonationOption(
              context,
              "Monthly Contribution",
              "Set up a recurring donation to provide sustained support",
              Icons.repeat,
                  () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/shaheed-donation-confirm');
              },
              isSmallScreen,
            ),
            SizedBox(height: 16),
            _buildDonationOption(
              context,
              "Sponsor a Family",
              "Directly support a specific family's needs",
              Icons.family_restroom,
                  () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/shaheed-requests');
              },
              isSmallScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationOption(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap,
      bool isSmallScreen,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF2A9D8F).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF2A9D8F).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Color(0xFF2A9D8F),
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF2A9D8F),
              size: isSmallScreen ? 14 : 16,
            ),
          ],
        ),
      ),
    );
  }
}