// lib/partners/partners_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';

class PartnerDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get partner data from arguments if available
    final Map<String, dynamic> partnerData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {
              'id': '1',
              'name': 'Name NGO',
              'image': 'assets/mask_group.png',
              'description': """
**simply dummy** text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries but also the leap into electronic typesetting, remaining essentially unchanged.

It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.

**containing Lorem Ipsum** passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.

**but also the leap into** electronic typesetting, remaining essentially unchanged.
""",
            };

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          partnerData['name'],
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: Color(0xFF2A9D8F),
              size: isSmallScreen ? 20 : 24,
            ),
            onPressed: () {
              // Show share dialog or options
              _showShareOptions(context, isSmallScreen);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 10
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Centered Partner Logo
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: isSmallScreen ? 50 : 60,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(partnerData['image']),
                onBackgroundImageError: (exception, stackTrace) {},
                child: ClipOval(
                  child: Icon(
                    Icons.business,
                    size: isSmallScreen ? 50 : 60,
                    color: Color(0xFF2A9D8F).withOpacity(0.7),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Partner Name
            Text(
              partnerData['name'],
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),

            // Description Text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                partnerData['description'],
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 15,
                  color: Colors.black87,
                  height: 1.5, // Better text readability
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Partner Projects Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Color(0xFFEAF5F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Projects',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildProjectItem(
                    'Medical Camp (February 2025)',
                    'Providing free medical checkups and medicines to underserved communities.',
                    isSmallScreen,
                  ),
                  _buildProjectItem(
                    'Educational Scholarships (January 2025)',
                    'Awarded 50 scholarships to deserving students for higher education.',
                    isSmallScreen,
                  ),
                  _buildProjectItem(
                    'Disaster Relief (December 2024)',
                    'Provided emergency supplies to families affected by recent floods.',
                    isSmallScreen,
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Contact Information
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildContactRow(Icons.phone, '+92 300-1234567', isSmallScreen),
                  _buildContactRow(Icons.email, 'info@${partnerData['name'].toString().toLowerCase().replaceAll(' ', '')}.org', isSmallScreen),
                  _buildContactRow(Icons.language, 'www.${partnerData['name'].toString().toLowerCase().replaceAll(' ', '')}.org', isSmallScreen),
                  _buildContactRow(Icons.location_on, 'Main Street, City Center, Pakistan', isSmallScreen),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Partner with Us Button
            ElevatedButton(
              onPressed: () {
                _showPartnershipDialog(context, isSmallScreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2A9D8F),
                minimumSize: Size(double.infinity, isSmallScreen ? 45 : 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Partner With Us',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: 20),

            // Return to Partners
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'View All Partners',
                style: TextStyle(
                  color: Color(0xFF2A9D8F),
                  decoration: TextDecoration.underline,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectItem(String title, String description, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 14 : 15,
            ),
          ),
          SizedBox(height: 3),
          Text(
            description,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.grey[700],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: isSmallScreen ? 18 : 20,
            color: Color(0xFF2A9D8F),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showShareOptions(BuildContext context, bool isSmallScreen) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Partner Information',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(context, 'WhatsApp', Icons.chat, Colors.green, isSmallScreen),
                _buildShareOption(context, 'Facebook', Icons.facebook, Colors.blue, isSmallScreen),
                _buildShareOption(context, 'Twitter', Icons.public, Colors.lightBlue, isSmallScreen),
                _buildShareOption(context, 'Email', Icons.email, Colors.orange, isSmallScreen),
              ],
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, isSmallScreen ? 45 : 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(BuildContext context, String title, IconData icon, Color color, bool isSmallScreen) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sharing via $title...')),
        );
      },
      child: Column(
        children: [
          Container(
            width: isSmallScreen ? 40 : 50,
            height: isSmallScreen ? 40 : 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: isSmallScreen ? 25 : 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
          ),
        ],
      ),
    );
  }

  void _showPartnershipDialog(BuildContext context, bool isSmallScreen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Partner With Us',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thank you for your interest in partnering with us! Please provide your contact information and we will get in touch with you shortly.',
                style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Organization Name',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Contact Person',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Partnership request submitted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2A9D8F),
            ),
            child: Text(
              'Submit',
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            ),
          ),
        ],
      ),
    );
  }
}