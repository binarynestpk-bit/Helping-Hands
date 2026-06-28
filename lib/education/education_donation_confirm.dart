// lib/education/education_donation_confirm.dart
import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';

class EducationConfirmDonationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ConfirmDonationPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ConfirmDonationPage extends StatefulWidget {
  @override
  _ConfirmDonationPageState createState() => _ConfirmDonationPageState();
}

class _ConfirmDonationPageState extends State<ConfirmDonationPage> {
  final TextEditingController _donationAmountController = TextEditingController(text: '15,000'); // Default donation amount

  @override
  void dispose() {
    _donationAmountController.dispose(); // Dispose the controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Confirm Your ',
            style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
            children: [
              TextSpan(
                text: 'Donation',
                style: TextStyle(color: Color(0xFF2A9D8F)),
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
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Family Details Card
            Card(
              margin: EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: isSmallScreen ? 18 : 20,
                          backgroundColor: Colors.grey.shade200,
                          child: Image.asset(
                              "assets/user.png",
                              width: isSmallScreen ? 20 : 24,
                              height: isSmallScreen ? 20 : 24
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student: M.Hassan',
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(height: 5),
                              buildInfoRow("assets/institution.png", 'Institution: A.B.C. Institution', isSmallScreen),
                              buildInfoRow("assets/graduation-capp.png", 'Degree: BSCS', isSmallScreen),
                              buildInfoRow("assets/report-card.png", 'CGPA / Result: 3.9 CGPA', isSmallScreen),
                              buildInfoRow("assets/hand.png", 'Fee Amount: 5000 ', isSmallScreen),
                              SizedBox(height: 30), // Add space for the button
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                    'Urgent',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: isSmallScreen ? 12 : 14,
                                    )
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/education-request-detail');
                        },
                        child: Text(
                          'View Details',
                          style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              color: Colors.white
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2A9D8F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 4 : 4
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Donation Amount Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Donation Amount',
                      style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(
                      width: isSmallScreen ? 100 : 120, // Limit the width of the TextField
                      child: TextField(
                        controller: _donationAmountController,
                        keyboardType: TextInputType.number, // Allow only numbers
                        textAlign: TextAlign.end, // Align text to the right
                        style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold
                        ),
                        decoration: InputDecoration(
                          prefixText: 'Rs ',
                          prefixStyle: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold
                          ),
                          border: InputBorder.none, // Remove the default border
                          contentPadding: EdgeInsets.zero, // Remove default padding
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Donate Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Donation processed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Navigate back to home screen
                  Future.delayed(Duration(seconds: 2), () {
                    Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                            (route) => false
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2A9D8F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 15),
                ),
                child: Text(
                  'Donate Now',
                  style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
// lib/education/education_donation_confirm.dart (continuation)
  Widget buildInfoRow(String iconPath, String text, bool isSmallScreen) {
    return Row(
      children: [
        Image.asset(
            iconPath,
            width: isSmallScreen ? 16 : 16,
            height: isSmallScreen ? 16 : 16
        ),
        SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}