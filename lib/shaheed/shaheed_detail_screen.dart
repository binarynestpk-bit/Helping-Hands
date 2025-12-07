// lib/shaheed/shaheed_detail_screen.dart - UPDATED WITH BACKEND
import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';

class ShaheedFamilyDetail extends StatefulWidget {
  @override
  _ShaheedFamilyDetailState createState() => _ShaheedFamilyDetailState();
}

class _ShaheedFamilyDetailState extends State<ShaheedFamilyDetail> {
  Map<String, dynamic>? _familyRequest;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get arguments - could be request data or request ID
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map<String, dynamic>) {
      // If full request data is passed
      if (arguments.containsKey('id')) {
        _loadFamilyRequest(arguments['id']);
      } else {
        // Use the passed data directly (fallback for static data)
        setState(() {
          _familyRequest = _transformLegacyData(arguments);
          _isLoading = false;
        });
      }
    } else if (arguments is String) {
      // If only ID is passed
      _loadFamilyRequest(arguments);
    } else {
      // Fallback to default static data
      setState(() {
        _familyRequest = _getDefaultData();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFamilyRequest(String requestId) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await ApiService.getFamilyRequest(requestId);

      if (response['success'] == true) {
        setState(() {
          _familyRequest = response['data']['request'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response['message'] ?? 'Failed to load family request';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  // Transform legacy static data format to match API format
  Map<String, dynamic> _transformLegacyData(Map<String, dynamic> legacyData) {
    return {
      'id': 'legacy-${DateTime.now().millisecondsSinceEpoch}',
      'family_head_name': legacyData['familyName'] ?? 'Unknown Family',
      'martyr_name': legacyData['familyName'] ?? 'Unknown',
      'children_count': int.tryParse(legacyData['childrenCount'] ?? '0') ?? 0,
      'requested_amount': double.tryParse(legacyData['monthlyNeed']?.replaceAll(',', '') ?? '50000') ?? 50000,
      'current_situation': 'The family of ${legacyData['familyName'] ?? 'this martyr'} has faced tremendous hardship since the martyrdom.',
      'relationship': 'family',
      'martyrdom_date': '2025-02-03',
      'martyrdom_place': 'Unknown',
      'city': 'Unknown',
      'contact_number': '+92300000000',
      'status': 'approved',
      'total_donated': 0.0,
      'remaining_amount': double.tryParse(legacyData['monthlyNeed']?.replaceAll(',', '') ?? '50000') ?? 50000,
      'funding_progress': 0,
      'priority_level': 'urgent',
    };
  }

  Map<String, dynamic> _getDefaultData() {
    return {
      'id': 'default-family',
      'family_head_name': 'M.Akbar Family',
      'martyr_name': 'M.Akbar',
      'children_count': 6,
      'requested_amount': 50000.0,
      'current_situation': 'The family of M.Akbar has faced tremendous hardship since his martyrdom. With six young children to care for, his widow has struggled to provide for their basic needs and education.',
      'relationship': 'husband',
      'martyrdom_date': '2025-02-03',
      'martyrdom_place': 'Waziristan',
      'city': 'Islamabad',
      'contact_number': '+92300000000',
      'status': 'approved',
      'total_donated': 0.0,
      'remaining_amount': 50000.0,
      'funding_progress': 0,
      'priority_level': 'urgent',
    };
  }

  // Safe conversion methods
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';

    try {
      DateTime parsedDate;
      if (date is String) {
        parsedDate = DateTime.parse(date);
      } else {
        return 'N/A';
      }

      return '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
    } catch (e) {
      return date.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Family ',
            style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
            children: [
              TextSpan(
                text: 'Details',
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF2A9D8F)))
          : _hasError
          ? _buildErrorWidget()
          : _familyRequest == null
          ? _buildNotFoundWidget()
          : _buildFamilyDetails(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Error Loading Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final arguments = ModalRoute.of(context)?.settings.arguments;
              if (arguments is String) {
                _loadFamilyRequest(arguments);
              } else if (arguments is Map<String, dynamic> && arguments.containsKey('id')) {
                _loadFamilyRequest(arguments['id']);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2A9D8F)),
            child: Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Family Details Not Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'The family details could not be found.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyDetails() {
    final request = _familyRequest!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    final requestedAmount = _safeToDouble(request['requested_amount']);
    final totalDonated = _safeToDouble(request['total_donated']);
    final remainingAmount = _safeToDouble(request['remaining_amount']);
    final fundingProgress = request['funding_progress'] ?? 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Family Info Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Family of: ${request['martyr_name'] ?? 'Unknown'}',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.share,
                                color: Color(0xFF2A9D8F),
                                size: isSmallScreen ? 20 : 24,
                              ),
                              onPressed: () {
                                _showShareOptions(context, isSmallScreen);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        InfoRow(label: 'Family Head', value: request['family_head_name'] ?? 'N/A', isSmallScreen: isSmallScreen),
                        InfoRow(label: "No of Children's", value: '${request['children_count'] ?? 0}', isSmallScreen: isSmallScreen),
                        InfoRow(label: 'City', value: request['city'] ?? 'N/A', isSmallScreen: isSmallScreen),
                        InfoRow(label: 'Requested Amount', value: 'PKR ${requestedAmount.round()}', isSmallScreen: isSmallScreen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Funding Progress Card
          if (totalDonated > 0 || fundingProgress > 0) ...[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Funding Progress',
                      style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: fundingProgress / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A9D8F)),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Raised: PKR ${totalDonated.round()}'),
                        Text('Goal: PKR ${requestedAmount.round()}'),
                      ],
                    ),
                    Text('$fundingProgress% Complete'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],

          // Martyr Information Section
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Martyr Information',
                    style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 10),
                  InfoRow(label: 'Martyr Name', value: request['martyr_name'] ?? 'N/A', isSmallScreen: isSmallScreen),
                  InfoRow(label: 'Date of Martyrdom', value: _formatDate(request['martyrdom_date']), isSmallScreen: isSmallScreen),
                  InfoRow(label: 'Place of Martyrdom', value: request['martyrdom_place'] ?? 'N/A', isSmallScreen: isSmallScreen),
                  InfoRow(label: 'Contact Number', value: request['contact_number'] ?? 'N/A', isSmallScreen: isSmallScreen),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Current Situation
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Family Story',
                    style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    request['current_situation'] ?? 'No description available.',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      height: 1.5,
                    ),
                  ),
                  if (request['specific_needs'] != null && request['specific_needs'].isNotEmpty) ...[
                    SizedBox(height: 10),
                    Text(
                      'Specific Needs:',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      request['specific_needs'],
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Donate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/shaheed-donation-confirm',
                  arguments: request,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2A9D8F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 15),
              ),
              child: Text(
                remainingAmount > 0 ? 'DONATE NOW' : 'VIEW DONATIONS',
                style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.white
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Related Requests Section
          Text(
            'Related Requests',
            style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 10),
          RelatedRequestCard(
            onViewDetails: () {
              Navigator.pushReplacementNamed(
                context,
                '/shaheed-detail',
                arguments: _getDefaultData(),
              );
            },
            isSmallScreen: isSmallScreen,
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
              'Share This Family Story',
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
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isSmallScreen;

  const InfoRow({required this.label, required this.value, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text('•', style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
          SizedBox(width: 2),
          Text(
            '$label: ',
            style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RelatedRequestCard extends StatelessWidget {
  final VoidCallback onViewDetails;
  final bool isSmallScreen;

  const RelatedRequestCard({required this.onViewDetails, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                        'Family of: Ahmad Khan',
                        style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 5),
                      buildInfoRow("assets/heart.png", 'Martial Status: ', 'Yes'),
                      buildInfoRow("assets/user.png", 'No of Children\'s: ', '4'),
                      buildInfoRow("assets/calendar.png", 'Date of Shahadat: ', '15/01/2025'),
                      buildInfoRow("assets/money.png", 'Monthly Need: ', '45,000'),
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
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                            'High',
                            style: TextStyle(
                              color: Colors.orange,
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
                onPressed: onViewDetails,
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
    );
  }

  Widget buildInfoRow(String iconPath, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Image.asset(
              iconPath,
              width: isSmallScreen ? 16 : 16,
              height: isSmallScreen ? 16 : 16
          ),
          SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
          ),
          Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              )
          ),
        ],
      ),
    );
  }
}