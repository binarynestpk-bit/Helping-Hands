import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodRequestsList extends StatefulWidget {
  @override
  _BloodRequestsListState createState() => _BloodRequestsListState();
}

class _BloodRequestsListState extends State<BloodRequestsList> {
  List<dynamic> bloodRequests = [];
  bool isLoading = true;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBloodRequests();
  }

  Future<void> _loadBloodRequests() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await ApiService.get('/blood/requests');

      if (response['success'] == true) {
        setState(() {
          bloodRequests = response['data']['requests'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load requests');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading blood requests: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fix the _makePhoneCall function in your blood_requests_list.dart

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number not available')),
      );
      return;
    }

    // Clean the phone number (remove spaces, dashes, etc.)
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure it has proper format
    if (!cleanNumber.startsWith('+') && !cleanNumber.startsWith('0')) {
      cleanNumber = '+92$cleanNumber';
    }

    print('=== PHONE CALL DEBUG ===');
    print('Original number: $phoneNumber');
    print('Cleaned number: $cleanNumber');
    print('======================');

    // Create the phone URI
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      // Check if the device can handle phone calls
      if (await canLaunchUrl(phoneUri)) {
        print('✅ Can launch phone URI: $phoneUri');
        await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication, // Force external app
        );
      } else {
        print('❌ Cannot launch phone URI: $phoneUri');
        throw 'Phone app not available on this device';
      }
    } catch (e) {
      print('Phone call error: $e');

      // Show user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not make phone call. You can manually dial: $cleanNumber'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Copy',
            textColor: Colors.white,
            onPressed: () {
              // You can add clipboard functionality here if needed
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Number: $cleanNumber')),
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> _openMaps(dynamic request) async {
    // Enhanced coordinate checking
    double? lat;
    double? lng;

    // Try to get coordinates from multiple possible fields
    if (request['latitude'] != null && request['longitude'] != null) {
      try {
        lat = double.parse(request['latitude'].toString());
        lng = double.parse(request['longitude'].toString());
      } catch (e) {
        print('Error parsing coordinates: $e');
      }
    }

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GPS coordinates not available for this request'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final String locationName = request['hospital_name'] ?? 'Hospital Location';

    // Try multiple map applications
    final List<String> mapUrls = [
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$locationName',
      'https://maps.apple.com/?q=$lat,$lng',
      'geo:$lat,$lng?q=$lat,$lng($locationName)',
    ];

    bool launched = false;
    for (String url in mapUrls) {
      try {
        final Uri mapUri = Uri.parse(url);
        if (await canLaunchUrl(mapUri)) {
          await launchUrl(mapUri, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open maps application')),
      );
    }
  }

// 1. Fix the donation API call in blood_requests_list.dart
// Update your _showDonationDialog method:

  void _showDonationDialog(dynamic request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Commit to Donate'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Are you sure you want to commit to donating blood for:'),
                  SizedBox(height: 10),
                  Text('Patient: ${request['patient_name'] ?? 'Unknown'}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Blood Group: ${request['blood_group'] ?? 'N/A'}'),
                  Text('Hospital: ${request['hospital_name'] ?? 'N/A'}'),
                  SizedBox(height: 15),
                  Text('By committing, you agree to contact the requester and arrange the donation.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    setState(() {
                      isSubmitting = true;
                    });

                    try {
                      // Check if user is authenticated
                      String? token = ApiService.getToken();
                      if (token == null) {
                        throw Exception('Please login again to donate blood');
                      }

                      // Prepare donation data (matching backend expectations)
                      Map<String, dynamic> donationData = {
                        'donor_name': 'John Doe', // Get from user profile
                        'donor_phone': '+923001234567', // Get from user profile
                        'notes': 'Available immediately for donation',
                      };

                      // CRITICAL: Make sure to include authentication
                      final response = await ApiService.post(
                        '/blood/donate/${request['id']}',
                        donationData,
                        includeAuth: true, // IMPORTANT: This was missing!
                      );

                      Navigator.of(context).pop();

                      if (response['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Thank you for your commitment to donate!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        // Refresh the requests list
                        _loadBloodRequests();
                      } else {
                        throw Exception(response['message'] ?? 'Failed to commit donation');
                      }
                    } catch (e) {
                      Navigator.of(context).pop();

                      String errorMessage = e.toString();
                      if (errorMessage.contains('token required') ||
                          errorMessage.contains('authentication') ||
                          errorMessage.contains('401')) {
                        errorMessage = 'Authentication failed. Please logout and login again.';
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $errorMessage'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 5),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE01219),
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text('Commit to Donate'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<dynamic> get filteredRequests {
    if (searchQuery.isEmpty) {
      return bloodRequests;
    }

    return bloodRequests.where((request) {
      final patientName = (request['patient_name'] ?? '').toLowerCase();
      final bloodGroup = (request['blood_group'] ?? '').toLowerCase();
      final hospitalName = (request['hospital_name'] ?? '').toLowerCase();
      final location = (request['location'] ?? '').toLowerCase();
      final query = searchQuery.toLowerCase();

      return patientName.contains(query) ||
          bloodGroup.contains(query) ||
          hospitalName.contains(query) ||
          location.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Blood ',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE01219),
            ),
            children: [
              TextSpan(
                text: 'Requests',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBloodRequests,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by patient, blood group, hospital...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // Content
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredRequests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    searchQuery.isEmpty
                        ? 'No blood requests available'
                        : 'No requests found matching "$searchQuery"',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (searchQuery.isNotEmpty) ...[
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchQuery = '';
                        });
                      },
                      child: Text('Clear Search'),
                    ),
                  ],
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadBloodRequests,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: filteredRequests.length,
                itemBuilder: (context, index) {
                  final request = filteredRequests[index];
                  return _buildRequestCard(request);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(dynamic request) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    // DEBUG: Print the request data to console
    print('=== DEBUG BLOOD REQUEST ===');
    print('Patient: ${request['patient_name']}');
    print('Hospital: ${request['hospital_name']}');
    print('Latitude: ${request['latitude']}');
    print('Longitude: ${request['longitude']}');
    print('Map Address: ${request['map_address']}');
    print('Full Request Keys: ${request.keys.toList()}');
    print('========================');

    // Determine urgency color
    Color urgencyColor = Color(0xFF2A9D8F); // Default
    if (request['urgency_level'] == 'Urgent') {
      urgencyColor = Color(0xFFE01219);
    } else if (request['urgency_level'] == 'Normal') {
      urgencyColor = Color(0xFFFD7444);
    }

    // Enhanced coordinate checking
    bool hasLocationData = false;
    double? lat;
    double? lng;

    // Try to parse coordinates
    if (request['latitude'] != null && request['longitude'] != null) {
      try {
        lat = double.parse(request['latitude'].toString());
        lng = double.parse(request['longitude'].toString());
        hasLocationData = (lat != 0 && lng != 0); // Make sure they're not zero
        print('✅ Parsed coordinates: $lat, $lng');
      } catch (e) {
        print('❌ Error parsing coordinates: $e');
        hasLocationData = false;
      }
    } else {
      print('❌ No latitude/longitude fields found');
    }

    // Get mobile number for calling
    String mobileNumber = request['mobile_number'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with patient name and urgency
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Patient: ${request['patient_name'] ?? 'Unknown'}',
                    style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: urgencyColor,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      request['urgency_level'] ?? 'Normal',
                      style: TextStyle(
                        color: urgencyColor,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),

            // Request details
            _buildDetailRow(
                context,
                'assets/r-blood-type.png',
                'Blood Group: ${request['blood_group'] ?? 'N/A'}',
                isSmallScreen
            ),
            _buildDetailRow(
                context,
                'assets/r-hospital.png',
                'Hospital: ${request['hospital_name'] ?? 'N/A'}',
                isSmallScreen
            ),
            _buildDetailRow(
                context,
                'assets/r-pin.png',
                'Location: ${request['location'] ?? request['map_address'] ?? 'N/A'}',
                isSmallScreen
            ),
            _buildDetailRow(
                context,
                'assets/r-calender.png',
                'Required: ${request['required_date'] ?? 'N/A'}',
                isSmallScreen
            ),
            _buildDetailRow(
                context,
                'assets/r-blood-units.png',
                'Units: ${request['blood_units'] ?? 'N/A'}',
                isSmallScreen
            ),

            // DEBUG: Show coordinate status
            Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: hasLocationData ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Icon(
                    hasLocationData ? Icons.location_on : Icons.location_off,
                    size: 16,
                    color: hasLocationData ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      hasLocationData
                          ? 'GPS: ${lat?.toStringAsFixed(4)}, ${lng?.toStringAsFixed(4)}'
                          : 'No GPS coordinates available',
                      style: TextStyle(
                        fontSize: 12,
                        color: hasLocationData ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            // Action buttons
            Row(
              children: [
                // Call button
                if (mobileNumber.isNotEmpty) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _makePhoneCall(mobileNumber),
                      icon: Icon(Icons.phone, size: 16),
                      label: Text('Call', style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],

                // Navigate button - ALWAYS SHOW
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasLocationData
                        ? () => _openMaps(request)
                        : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('GPS coordinates not available for this request'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                    icon: Icon(
                      hasLocationData ? Icons.navigation : Icons.location_off,
                      size: 16,
                    ),
                    label: Text(
                        hasLocationData ? 'Navigate' : 'No GPS',
                        style: TextStyle(fontSize: isSmallScreen ? 12 : 14)
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: hasLocationData ? Colors.blue : Colors.grey,
                      side: BorderSide(color: hasLocationData ? Colors.blue : Colors.grey),
                      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10),
                    ),
                  ),
                ),
                SizedBox(width: 8),

                // Details button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/blood-request-detail',
                        arguments: request,
                      );
                    },
                    icon: Icon(Icons.info_outline, size: 16),
                    label: Text('Details', style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10),
                    ),
                  ),
                ),
                SizedBox(width: 8),

                // Donate button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDonationDialog(request),
                    icon: Icon(Icons.volunteer_activism, size: 16),
                    label: Text('Donate', style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE01219),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String assetPath, String text, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              color: Colors.red,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.circle,
                size: 8,
                color: Colors.red,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}