// lib/partners/partners_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:helpinghand/services/auth_service.dart';
import 'package:helpinghand/widgets/guest_access.dart';

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
              child: Builder(builder: (_) {
                final logoStr = partnerData['image']?.toString() ?? partnerData['logo_url']?.toString();
                final ImageProvider? logo =
                    (logoStr != null && logoStr.startsWith('http')) ? NetworkImage(logoStr) : null;
                return CircleAvatar(
                  radius: isSmallScreen ? 50 : 60,
                  backgroundColor: Colors.white,
                  backgroundImage: logo,
                  onBackgroundImageError: logo != null ? (e, s) {} : null,
                  child: logo == null
                      ? Icon(
                          Icons.business,
                          size: isSmallScreen ? 50 : 60,
                          color: Color(0xFF2A9D8F).withOpacity(0.7),
                        )
                      : null,
                );
              }),
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

            SizedBox(height: screenHeight * 0.01),

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
                  if ((partnerData['phone'] ?? '').toString().isNotEmpty)
                    _buildContactRow(Icons.phone, partnerData['phone'].toString(), isSmallScreen),
                  if ((partnerData['email'] ?? '').toString().isNotEmpty)
                    _buildContactRow(Icons.email, partnerData['email'].toString(), isSmallScreen),
                  if ((partnerData['website'] ?? '').toString().isNotEmpty)
                    _buildContactRow(Icons.language, partnerData['website'].toString(), isSmallScreen),
                  if ((partnerData['category'] ?? '').toString().isNotEmpty)
                    _buildContactRow(Icons.category, partnerData['category'].toString(), isSmallScreen),
                  if (((partnerData['phone'] ?? '').toString().isEmpty) &&
                      ((partnerData['email'] ?? '').toString().isEmpty) &&
                      ((partnerData['website'] ?? '').toString().isEmpty))
                    Text('No contact information provided.',
                        style: TextStyle(color: Colors.grey, fontSize: isSmallScreen ? 12 : 14)),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Partner with Us Button
            ElevatedButton(
              onPressed: () {
                _showPartnershipDialog(context, isSmallScreen, partnerData['name']?.toString() ?? '');
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

  void _showPartnershipDialog(BuildContext context, bool isSmallScreen, String orgName) {
    final orgController = TextEditingController(text: orgName);
    final personController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final messageController = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
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
                  'Thank you for your interest in partnering with us! Please provide your details and we will get in touch with you shortly.',
                  style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: orgController,
                  decoration: InputDecoration(
                    labelText: 'Organization Name',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: personController,
                  decoration: InputDecoration(
                    labelText: 'Contact Person',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Message (optional)',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              ),
            ),
            ElevatedButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (GuestAccess.blockIfGuest(context)) return;
                      if (orgController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text('Please enter your organization name'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      setDialogState(() => submitting = true);
                      try {
                        final response = await ApiService.post(
                          '/partner-applications',
                          {
                            'organization_name': orgController.text.trim(),
                            'contact_person': personController.text.trim(),
                            'email': emailController.text.trim(),
                            'phone': phoneController.text.trim(),
                            'message': messageController.text.trim(),
                          },
                          includeAuth: true,
                        );
                        Navigator.pop(dialogContext);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response['message']?.toString() ??
                                'Partnership request submitted successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => submitting = false);
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Could not submit your request. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2A9D8F),
              ),
              child: submitting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Submit',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}