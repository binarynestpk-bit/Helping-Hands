// lib/screens/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';

class NotificationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotificationScreen(),
    );
  }
}

class NotificationScreen extends StatelessWidget {
  final List<NotificationItem> notifications = [
    NotificationItem(
      icon: 'assets/siren.png',
      title: "Urgent Blood Request: O+ Needed",
      description: "XYZ Hospital, Karachi, requires O+ blood for a critical surgery. Please donate if you can.",
      time: "2 min ago",
      isUrgent: true,
    ),
    NotificationItem(
      icon: 'assets/bell.png',
      title: "Education Support Request Approved",
      description: "Your request for semester fee assistance has been approved. Funds will be processed soon.",
      time: "15 min ago",
    ),
    NotificationItem(
      icon: 'assets/bell.png',
      title: "Shuhada Family Fundraiser Launched",
      description: "We updated your point and progress statistics according to points.",
      time: "1 hour ago",
    ),
    NotificationItem(
      icon: 'assets/bell.png',
      title: "Daily Task",
      description: "A new support campaign for the family of Capt. Ahmad has been launched. Contribute today.",
      time: "4 hours ago",
    ),
    NotificationItem(
      icon: 'assets/heart-red.png',
      title: "Thank You for Your Donation!",
      description: "Your generous contribution to the Education Fund has made a difference. Thank you!",
      time: "7 hours ago",
    ),
    NotificationItem(
      icon: 'assets/heart-red.png',
      title: "New Donor Registered in Your Area",
      description: "A new blood donor is available in Islamabad. Let's welcome them to the community.",
      time: "1 day ago",
    ),
    NotificationItem(
      icon: 'assets/bell.png',
      title: "Shuhada Family Support Goal Reached",
      description: "We've successfully raised the required funds for the Khan family. Thank you for your support.",
      time: "5 days ago",
    ),
    NotificationItem(
      icon: 'assets/danger.png',
      title: "Road Accident in DHA, Lahore",
      description: "A severe accident on Main Boulevard, DHA. Traffic is being diverted.",
      time: "5 days ago",
      isUrgent: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and responsive flags
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    // Responsive sizes
    final appBarTitleSize = isSmallScreen ? 20.0 : 22.0;
    final headingFontSize = isSmallScreen ? 16.0 : 18.0;
    final titleFontSize = isSmallScreen ? 14.0 : 16.0;
    final descriptionFontSize = isSmallScreen ? 12.0 : 14.0;
    final timeFontSize = isSmallScreen ? 10.0 : 12.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final horizontalPadding = screenWidth * 0.05;
    final verticalSpacing = isSmallScreen ? 6.0 : 8.0;
    final counterSize = isSmallScreen ? 8.0 : 10.0;

    // Avatar sizes
    final avatarRadius = isSmallScreen ? 18.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: iconSize),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Notifications",
          style: TextStyle(
              fontSize: appBarTitleSize,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
        actions: [
          IconButton(
            icon: Image.asset('assets/pipe.png', width: iconSize),
            onPressed: () {
              // Filter functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with counter and mark all as read
            Row(
              children: [
                Text(
                  "Recent Notification",
                  style: TextStyle(
                      fontSize: headingFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                  ),
                ),
                SizedBox(width: 5),
                CircleAvatar(
                  radius: counterSize,
                  backgroundColor: Color(0xFF2A9D8F),
                  child: Text(
                    "1",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: counterSize * 1.2
                    ),
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    // Mark all as read functionality
                  },
                  child: Text(
                    "Mark all as read",
                    style: TextStyle(
                        color: Color(0xFF2A9D8F),
                        fontSize: descriptionFontSize
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Notifications list
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: verticalSpacing),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Notification icon
                        CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: item.isUrgent ? Color(0xFFFFE5E5) : Color(0xFFEAF5F4),
                          child: Image.asset(
                              item.icon,
                              width: avatarRadius * 1.2,
                              height: avatarRadius * 1.2
                          ),
                        ),
                        SizedBox(width: 10),

                        // Notification content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                item.description,
                                style: TextStyle(
                                    fontSize: descriptionFontSize,
                                    color: Colors.black.withOpacity(0.6)
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),

                        // Notification time
                        Text(
                          item.time,
                          style: TextStyle(
                              fontSize: timeFontSize,
                              color: Color(0xFF2A9D8F)
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem {
  final String icon;
  final String title;
  final String description;
  final String time;
  final bool isUrgent;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    this.isUrgent = false,
  });
}