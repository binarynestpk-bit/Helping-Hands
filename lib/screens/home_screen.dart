// lib/screens/home_screen.dart (UPDATED VERSION - Islamic donations moved to separate page)
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _currentPage = 0;
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF2A9D8F),
        elevation: 0,
        title: Text(
          "Trusting Hands",
          style: TextStyle(
            fontSize: isSmallScreen ? 20 : 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      // Add the navigation drawer
      endDrawer: _buildNavigationDrawer(context, isSmallScreen),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: isSmallScreen ? 25 : 30,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome!",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "Minahil",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "👋",
                              style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFEFF6F5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                    child: Icon(
                      Icons.search,
                      color: Color(0xFF2A9D8F),
                      size: isSmallScreen ? 24 : 28,
                    ),
                  ),
                ],
              ),
            ),

            // Donation Progress Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFEFF6F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Donation Progress",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.more_horiz),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: screenHeight * 0.25,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                getTitlesWidget: (value, meta) {
                                  String text = '';
                                  switch (value.toInt()) {
                                    case 0:
                                      text = 'Q1';
                                      break;
                                    case 1:
                                      text = 'Q2';
                                      break;
                                    case 2:
                                      text = 'Q3';
                                      break;
                                    case 3:
                                      text = 'Q4';
                                      break;
                                    case 4:
                                      text = 'Q5';
                                      break;
                                    case 5:
                                      text = 'Q6';
                                      break;
                                    case 6:
                                      text = 'Q7';
                                      break;
                                  }
                                  return Text(
                                    text,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: isSmallScreen ? 10 : 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            // Blood Donations (Red)
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 1),
                                FlSpot(1, 2.5),
                                FlSpot(2, 1.5),
                                FlSpot(3, 3.5),
                                FlSpot(4, 2),
                                FlSpot(5, 2.8),
                                FlSpot(6, 3.8),
                              ],
                              isCurved: true,
                              color: const Color(0xFFE01219),
                              barWidth: isSmallScreen ? 2 : 3,
                              dotData: const FlDotData(show: false),
                            ),
                            // Education Donations (Green)
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 0.8),
                                FlSpot(1, 2.8),
                                FlSpot(2, 3.5),
                                FlSpot(3, 1.5),
                                FlSpot(4, 3.2),
                                FlSpot(5, 2.2),
                                FlSpot(6, 2.2),
                              ],
                              isCurved: true,
                              color: const Color(0xFF2A9D8F),
                              barWidth: isSmallScreen ? 2 : 3,
                              dotData: const FlDotData(show: false),
                            ),
                            // Shuhada Family (Yellow)
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 0.5),
                                FlSpot(1, 1.2),
                                FlSpot(2, 0.8),
                                FlSpot(3, 2.8),
                                FlSpot(4, 2.6),
                                FlSpot(5, 3.0),
                                FlSpot(6, 3.0),
                              ],
                              isCurved: true,
                              color: const Color(0xFFFFC107),
                              barWidth: isSmallScreen ? 2 : 3,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: screenWidth * 0.03,
                      children: [
                        _buildLegendItem(Color(0xFFE01219), "Blood Donations"),
                        _buildLegendItem(Color(0xFF2A9D8F), "Education Care"),
                        _buildLegendItem(Color(0xFFFFC107), "Matyrs Family Support"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // MOVED UP: Get Involved Today Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Text(
                "Get Involved Today",
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Original donation options grid (reverted to simple styling)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: screenWidth < 360 ? 1 : 2,
                childAspectRatio: screenWidth < 360 ? 2.5 : 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // Blood Donation Card
                  _buildDonationOptionWithImage(
                    "Blood Bank",
                    "assets/blood-donation.png",
                        () => Navigator.pushNamed(context, '/blood-donation'),
                    isSmallScreen: isSmallScreen,
                  ),

                  // Education Donation Card
                  _buildDonationOptionWithImage(
                    "Education Care",
                    "assets/graduation-capp.png",
                        () => Navigator.pushNamed(context, '/education-donation'),
                    isSmallScreen: isSmallScreen,
                  ),

                  // Shuhada Family Support Card
                  _buildDonationOptionWithImage(
                    "Martyrs Family Support",
                    "assets/hand.png",
                        () => Navigator.pushNamed(context, '/shaheed-family'),
                    isSmallScreen: isSmallScreen,
                  ),

                  // Our Partners Card
                  _buildDonationOptionWithImage(
                    "Our Partners",
                    "assets/handshake.png",
                        () => Navigator.pushNamed(context, '/partners'),
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // MOVED DOWN: Urgent Requests
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Urgent Requests",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                    child: Text(
                      "See all Notifications",
                      style: TextStyle(
                        color: Color(0xFF2A9D8F),
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Urgent Request Card
            Container(
              height: screenHeight * 0.28,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: isSmallScreen ? 20 : 24,
                                  backgroundImage: AssetImage('assets/patient.png'),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Patient: Ali Khan",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 16 : 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "Urgent",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: isSmallScreen ? 10 : 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            _buildInfoRow(Icons.bloodtype, "Blood Group: A+", Colors.red),
                            SizedBox(height: 8),
                            _buildInfoRow(Icons.local_hospital, "Hospital: ABC Medical Center", Colors.grey),
                            SizedBox(height: 8),
                            _buildInfoRow(Icons.location_on, "Location: Peshawar", Colors.grey),
                            SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/blood-request-detail');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFE01219),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 12 : 16,
                                      vertical: isSmallScreen ? 6 : 8
                                  ),
                                ),
                                child: Text(
                                  "View Details",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen ? 12 : 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Page indicator dots
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                      (index) => Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Color(0xFF2A9D8F)
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 100), // Space for FAB and bottom navigation
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: Container(
          height: isSmallScreen ? 50 : 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home icon
              IconButton(
                icon: Image.asset(
                  'assets/home.png',
                  width: isSmallScreen ? 20 : 24,
                  height: isSmallScreen ? 20 : 24,
                  color: _selectedIndex == 0 ? Color(0xFF2A9D8F) : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
              // List (Requests) icon
              IconButton(
                icon: Image.asset(
                  'assets/list.png',
                  width: isSmallScreen ? 20 : 24,
                  height: isSmallScreen ? 20 : 24,
                  color: _selectedIndex == 1 ? Color(0xFF2A9D8F) : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                  _showRequestOptions(context);
                },
              ),
              // Spacer for the center button
              SizedBox(width: isSmallScreen ? 40 : 48),
              // Notifications icon
              IconButton(
                icon: Image.asset(
                  'assets/notification-bing.png',
                  width: isSmallScreen ? 20 : 24,
                  height: isSmallScreen ? 20 : 24,
                  color: _selectedIndex == 3 ? Color(0xFF2A9D8F) : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              // Profile icon
              IconButton(
                icon: Image.asset(
                  'assets/profile.png',
                  width: isSmallScreen ? 20 : 24,
                  height: isSmallScreen ? 20 : 24,
                  color: _selectedIndex == 4 ? Color(0xFF2A9D8F) : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 4;
                  });
                  _showProfileOptions(context);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        height: isSmallScreen ? 50 : 60,
        width: isSmallScreen ? 50 : 60,
        child: FloatingActionButton(
          onPressed: () {
            _showDonateOptions(context);
          },
          backgroundColor: Color(0xFF2A9D8F),
          child: Text(
            "Donate\nNow",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 10 : 12,
              height: 1.0,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Original simple donation card (reverted back to original styling)
  Widget _buildDonationOptionWithImage(String title, String imagePath, VoidCallback onTap, {bool isSmallScreen = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF2A9D8F), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: isSmallScreen ? 40 : 50,
              height: isSmallScreen ? 40 : 50,
              color: Color(0xFF2A9D8F),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Navigation Drawer
  Widget _buildNavigationDrawer(BuildContext context, bool isSmallScreen) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2A9D8F),
              Color(0xFF2A9D8F).withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header with profile
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: isSmallScreen ? 40 : 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: isSmallScreen ? 38 : 48,
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Minahil",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Trusted Member",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      _buildDrawerItem(
                        icon: Icons.mosque,
                        title: "Other Donations",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/general-donation');
                        },
                        color: Color(0xFF2A9D8F),
                        isSmallScreen: isSmallScreen,
                      ),

                      _buildDrawerItem(
                        icon: Icons.bloodtype,
                        title: "Life Support",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/blood-donation');
                        },
                        color: Color(0xFFE01219),
                        isSmallScreen: isSmallScreen,
                      ),

                      _buildDrawerItem(
                        icon: Icons.school,
                        title: "Education",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/education-donation');
                        },
                        color: Color(0xFF2A9D8F),
                        isSmallScreen: isSmallScreen,
                      ),

                      _buildDrawerItem(
                        icon: Icons.handshake,
                        title: "Our Partners",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/partners');
                        },
                        color: Color(0xFF2A9D8F),
                        isSmallScreen: isSmallScreen,
                      ),

                      _buildDrawerItem(
                        icon: Icons.family_restroom,
                        title: "Martyrs Support",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/shaheed-family');
                        },
                        color: Color(0xFFFFC107),
                        isSmallScreen: isSmallScreen,
                      ),

                      _buildDrawerItem(
                        icon: Icons.contact_support,
                        title: "Contact Us",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/contact-us');
                        },
                        color: Color(0xFF2A9D8F),
                        isSmallScreen: isSmallScreen,
                      ),

                      _buildDrawerItem(
                        icon: Icons.help_outline,
                        title: "Get Help",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/get-help');
                        },
                        color: Color(0xFFFFC107),
                        isSmallScreen: isSmallScreen,
                      ),

                      Spacer(),

                      // Close drawer button
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: Color(0xFF2A9D8F)),
                            label: Text(
                              "Close Menu",
                              style: TextStyle(
                                color: Color(0xFF2A9D8F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xFF2A9D8F)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simple drawer menu item (removed subtitle and extra styling)
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
    bool isSmallScreen = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: color,
          size: isSmallScreen ? 20 : 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: isSmallScreen ? 14 : 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Row(
      children: [
        Icon(
          icon,
          size: isSmallScreen ? 14 : 16,
          color: iconColor,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // UPDATED: Simplified donation options (removed Islamic donation modal)
  void _showDonateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SimpleDonationOptionsSheet(),
    );
  }

  void _showRequestOptions(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "View Requests",
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            _buildRequestOption(
              "Blood Donation Requests",
              Icons.bloodtype,
              Color(0xFFE01219),
                  () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/blood-requests-list');
              },
              isSmallScreen: isSmallScreen,
            ),
            Divider(),
            _buildRequestOption(
              "Education Support Requests",
              Icons.school,
              Color(0xFF2A9D8F),
                  () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/education-requests-list');
              },
              isSmallScreen: isSmallScreen,
            ),
            Divider(),
            _buildRequestOption(
              "Shuhada Family Requests",
              Icons.family_restroom,
              Color(0xFFFFC107),
                  () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/shaheed-requests');
              },
              isSmallScreen: isSmallScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestOption(String title, IconData icon, Color color, VoidCallback onTap, {bool isSmallScreen = false}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
      leading: Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
      title: Text(
        title,
        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
      ),
      trailing: Icon(Icons.chevron_right, size: isSmallScreen ? 20 : 24),
      onTap: onTap,
    );
  }

  void _showProfileOptions(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Profile Options",
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            _buildProfileOption(
              "View Profile",
              Icons.person,
              Color(0xFF2A9D8F),
                  () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/view-profile');
              },
              isSmallScreen: isSmallScreen,
            ),
            Divider(),
            _buildProfileOption(
              "Settings",
              Icons.settings,
              Color(0xFF2A9D8F),
                  () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
              isSmallScreen: isSmallScreen,
            ),
            Divider(),
            _buildProfileOption(
              "Logout",
              Icons.logout,
              Colors.red,
                  () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/signin');
              },
              isSmallScreen: isSmallScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(String title, IconData icon, Color color, VoidCallback onTap, {bool isSmallScreen = false}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
      leading: Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
      title: Text(
        title,
        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
      ),
      trailing: Icon(Icons.chevron_right, size: isSmallScreen ? 20 : 24),
      onTap: onTap,
    );
  }
}

// SIMPLIFIED: Donation Options Sheet (without Islamic donations)
class SimpleDonationOptionsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),

          // Title
          Text(
            "Choose Donation Type",
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),

          // Donation options
          _buildDonationOption(
            context,
            "Other Donations",
            "Give your zakat, khums, sadaqah, or any Islamic charity",
            Icons.mosque,
                () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/general-donation'); // Navigate to Islamic donation page
            },
            isSmallScreen,
          ),
          SizedBox(height: 16),
          _buildDonationOption(
            context,
            "Life Line Blood Bank",
            "Help save lives through blood donation",
            Icons.bloodtype,
                () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/blood-donation');
            },
            isSmallScreen,
          ),
          SizedBox(height: 16),
          _buildDonationOption(
            context,
            "Education Care",
            "Help students with their educational needs",
            Icons.school,
                () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/education-donation');
            },
            isSmallScreen,
          ),
          SizedBox(height: 16),
          _buildDonationOption(
            context,
            "Martyrs Family Support",
            "Support families of martyrs",
            Icons.family_restroom,
                () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/shaheed-family');
            },
            isSmallScreen,
          ),
          SizedBox(height: 20),
        ],
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF2A9D8F).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
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