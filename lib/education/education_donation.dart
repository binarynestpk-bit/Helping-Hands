// lib/education/education_donation.dart (UPDATED WITH ACTION BUTTONS GRID)
import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';

class EducationDonationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: RichText(
          text: TextSpan(
            text: 'Education ',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveHeadingSize(context),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: 'Support',
                style: TextStyle(
                  color: Color(0xFF2A9D8F),
                ),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Image
              Image.asset(
                'assets/education_banner.png',
                height: screenHeight * 0.20,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: screenHeight * 0.20,
                  color: Color(0xFFEAF5F4),
                  child: Center(
                    child: Icon(
                      Icons.school,
                      size: screenWidth * 0.15,
                      color: Color(0xFF2A9D8F),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),

              // Title and Description
              Text(
                "Make a Difference: Support a Child's Education",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Your contributions help provide quality education to underprivileged children, enabling them to build a brighter future for themselves and their communities.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // NEW: Action Buttons Grid (same style as blood donation and Shaheed family)
              _buildActionButtonsGrid(context, isSmallScreen),
              SizedBox(height: screenHeight * 0.03),

              // Education Impact Section
              _buildSectionTitle("Our Impact", Icons.trending_up, isSmallScreen),
              SizedBox(height: 15),
              screenWidth > 480
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard("1,500+", "Students Supported", isSmallScreen),
                  _buildStatCard("250+", "Schools Partnered", isSmallScreen),
                  _buildStatCard("98%", "Graduation Rate", isSmallScreen),
                ],
              )
                  : Column(
                children: [
                  _buildStatCard("1,500+", "Students Supported", isSmallScreen, isFullWidth: true),
                  SizedBox(height: 10),
                  _buildStatCard("250+", "Schools Partnered", isSmallScreen, isFullWidth: true),
                  SizedBox(height: 10),
                  _buildStatCard("98%", "Graduation Rate", isSmallScreen, isFullWidth: true),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),

              // What We Support Section
              _buildSectionTitle("What We Support", Icons.school, isSmallScreen),
              SizedBox(height: 15),
              _buildInfoCard(
                "Tuition Fees",
                "We cover partial or full tuition fees for underprivileged students across all educational levels.",
                Icons.money,
                isSmallScreen,
              ),
              SizedBox(height: 15),
              _buildInfoCard(
                "Educational Materials",
                "We provide textbooks, stationery, uniforms, and other essential learning materials.",
                Icons.book,
                isSmallScreen,
              ),
              SizedBox(height: 15),
              _buildInfoCard(
                "Scholarships",
                "We offer merit-based and need-based scholarships for exceptional students.",
                Icons.star,
                isSmallScreen,
              ),
              SizedBox(height: screenHeight * 0.03),

              // Student Stories
              _buildSectionTitle("Student Success Stories", Icons.people, isSmallScreen),
              SizedBox(height: 15),
              _buildStudentStory(
                "Ahmed Khan",
                "Computer Science Student",
                "With the support of donors, Ahmed was able to continue his education despite family financial struggles. He's now in his final year of Computer Science and has already secured an internship.",
                isSmallScreen,
              ),
              SizedBox(height: 15),
              _buildStudentStory(
                "Sara Malik",
                "Medical Student",
                "Sara comes from a remote village where girls' education was not prioritized. Thanks to educational support, she's now pursuing her dream of becoming a doctor to serve her community.",
                isSmallScreen,
              ),
              SizedBox(height: screenHeight * 0.03),

              // How It Works Section
              _buildSectionTitle("How It Works", Icons.help_outline, isSmallScreen),
              SizedBox(height: 15),
              _buildStepCard(
                "1",
                "Apply for Support",
                "Students or parents can submit an application with required documentation and proof of financial need.",
                isSmallScreen,
              ),
              SizedBox(height: 10),
              _buildStepCard(
                "2",
                "Verification",
                "Our team verifies the application details and assesses the level of support needed.",
                isSmallScreen,
              ),
              SizedBox(height: 10),
              _buildStepCard(
                "3",
                "Matching with Donors",
                "Approved applications are matched with donors who wish to support education.",
                isSmallScreen,
              ),
              SizedBox(height: 10),
              _buildStepCard(
                "4",
                "Fund Disbursement",
                "Funds are disbursed directly to educational institutions to ensure proper utilization.",
                isSmallScreen,
              ),
              SizedBox(height: screenHeight * 0.04),

              // Donate Button
              Container(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/education-requests-list');
                  },
                  icon: Icon(Icons.school_outlined, color: Colors.white),
                  label: Text(
                    "Support a Student",
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

  // NEW: Action Buttons Grid (same style as blood donation and Shaheed family screens)
  Widget _buildActionButtonsGrid(BuildContext context, bool isSmallScreen) {
    return Column(
      children: [
        // Request Education Support Button (Primary - Green)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/education-form');
            },
            icon: Icon(Icons.school, color: Colors.white),
            label: Text(
              "Request Education Support",
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2A9D8F), // Education green color
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),
        SizedBox(height: 12),

        // My Education Requests Button (Outlined - Green)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/my-education-requests');
            },
            icon: Icon(Icons.list_alt, color: Color(0xFF2A9D8F)),
            label: Text(
              "My Education Requests",
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

        // View Education Requests Button (Outlined - Dark)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/education-requests-list');
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

  Widget _buildSectionTitle(String title, IconData icon, bool isSmallScreen) {
    return Row(
      children: [
        Icon(
          icon,
          color: Color(0xFF2A9D8F),
          size: isSmallScreen ? 20 : 24,
        ),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String number, String label, bool isSmallScreen, {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : (isSmallScreen ? 90 : 100),
      padding: EdgeInsets.all(isSmallScreen ? 10 : 15),
      decoration: BoxDecoration(
        color: Color(0xFFEAF5F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A9D8F),
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          SizedBox(width: 15),
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
                SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentStory(String name, String program, String story, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
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
              CircleAvatar(
                backgroundColor: Color(0xFF2A9D8F).withOpacity(0.1),
                radius: isSmallScreen ? 16 : 20,
                child: Icon(
                  Icons.person,
                  color: Color(0xFF2A9D8F),
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      program,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Color(0xFF2A9D8F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            story,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(String number, String title, String description, bool isSmallScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isSmallScreen ? 25 : 30,
          height: isSmallScreen ? 25 : 30,
          decoration: BoxDecoration(
            color: Color(0xFF2A9D8F),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ),
        SizedBox(width: 15),
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
              SizedBox(height: 5),
              Text(
                description,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}