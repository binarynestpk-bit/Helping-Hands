// lib/partners/partners_list_screen.dart (updated for responsiveness)
import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';

class PartnersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          'Partners',
          style: TextStyle(
            fontSize: ResponsiveHelper.responsiveHeadingSize(context),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: PartnersScreen(),
    );
  }
}

class PartnersScreen extends StatelessWidget {
  // Mock data for partners
  final List<Map<String, dynamic>> partners = [
    {
      'id': '1',
      'name': 'ABC Foundation',
      'image': 'assets/mask_group.png',
      'description': 'A non-profit organization focused on education and healthcare.',
    },
    {
      'id': '2',
      'name': 'XYZ Hospital',
      'image': 'assets/mask_group.png',
      'description': 'Leading hospital providing quality healthcare services.',
    },
    {
      'id': '3',
      'name': 'Education Trust',
      'image': 'assets/mask_group.png',
      'description': 'Supporting educational initiatives for underprivileged children.',
    },
    {
      'id': '4',
      'name': 'Health Alliance',
      'image': 'assets/mask_group.png',
      'description': 'Alliance of healthcare providers working together for better healthcare.',
    },
    {
      'id': '5',
      'name': 'Community Services',
      'image': 'assets/mask_group.png',
      'description': 'Providing essential services to local communities.',
    },
    {
      'id': '6',
      'name': 'Hope Foundation',
      'image': 'assets/mask_group.png',
      'description': 'Bringing hope to families in need through various support programs.',
    },
    {
      'id': '7',
      'name': 'First Responders',
      'image': 'assets/mask_group.png',
      'description': 'Emergency response team providing critical care during disasters.',
    },
    {
      'id': '8',
      'name': 'Relief Organization',
      'image': 'assets/mask_group.png',
      'description': 'Focused on disaster relief and humanitarian aid.',
    },
    {
      'id': '9',
      'name': 'Children\'s Aid',
      'image': 'assets/mask_group.png',
      'description': 'Supporting children\'s welfare and development programs.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Determine grid cross axis count based on screen width
    int crossAxisCount = 3; // Default for large screens

    if (screenWidth < 480) {
      crossAxisCount = 2; // Medium screens
    }

    if (screenWidth < 360) {
      crossAxisCount = 1; // Small screens
    }

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: 10
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info text
          Text(
            'Our trusted partners who collaborate with us to make a difference in the lives of those in need.',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 20),

          // Grid of partners
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: partners.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 15,
                mainAxisSpacing: 20,
                childAspectRatio: isSmallScreen ? 0.9 : 0.75, // Adjust ratio for better fit
              ),
              itemBuilder: (context, index) {
                final partner = partners[index];
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: isSmallScreen ? 40 : 45,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(partner['image']),
                        onBackgroundImageError: (exception, stackTrace) {},
                        child: ClipOval(
                          child: Icon(
                            Icons.business,
                            size: isSmallScreen ? 40 : 45,
                            color: Color(0xFF2A9D8F).withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Text(
                        partner['name'],
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2A9D8F),
                        minimumSize: Size(isSmallScreen ? 80 : 90, isSmallScreen ? 30 : 35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Navigate to partner details
                        Navigator.pushNamed(
                          context,
                          '/partners-detail',
                          arguments: partner,
                        );
                      },
                      child: Text(
                        'View Details',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 10 : 12
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}