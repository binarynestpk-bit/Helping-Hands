import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:helpinghand/services/auth_service.dart';

class MyEducationRequests extends StatefulWidget {
  @override
  _MyEducationRequestsState createState() => _MyEducationRequestsState();
}

class _MyEducationRequestsState extends State<MyEducationRequests> {
  List<dynamic> myRequests = [];
  bool isLoading = true;
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadMyRequests();
  }

  Future<void> _loadMyRequests() async {
    if (!AuthService.isLoggedIn()) {
      Navigator.pushReplacementNamed(context, '/signin');
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final response = await ApiService.get('/education/user/requests', includeAuth: true);

      if (response['success']) {
        setState(() {
          myRequests = response['data']['requests'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load requests');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      String errorMessage = e.toString();
      if (errorMessage.contains('Access token required') ||
          errorMessage.contains('401') ||
          errorMessage.contains('authentication')) {
        Navigator.pushReplacementNamed(context, '/signin');
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading requests: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<dynamic> get filteredRequests {
    if (selectedFilter == 'all') {
      return myRequests;
    }
    return myRequests.where((request) =>
    (request['status'] ?? '').toString().toLowerCase() == selectedFilter
    ).toList();
  }

  // FIXED: Safe conversion function
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

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2A9D8F),
        title: RichText(
          text: TextSpan(
            text: 'My Education ',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
            children: [
              TextSpan(
                text: 'Requests',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadMyRequests,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterTab('All', 'all'),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildFilterTab('Pending', 'pending'),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildFilterTab('Approved', 'approved'),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildFilterTab('Funded', 'funded'),
                ),
              ],
            ),
          ),

          // Requests List
          Expanded(
            child: isLoading
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2A9D8F)),
                  SizedBox(height: 16),
                  Text('Loading your requests...'),
                ],
              ),
            )
                : filteredRequests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    selectedFilter == 'all'
                        ? 'No education requests submitted yet'
                        : 'No ${selectedFilter} requests found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/education-form');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2A9D8F),
                    ),
                    child: Text(
                      'Create Education Request',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadMyRequests,
              color: Color(0xFF2A9D8F),
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: filteredRequests.length,
                itemBuilder: (context, index) {
                  return _buildRequestCard(filteredRequests[index]);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/education-form');
        },
        backgroundColor: Color(0xFF2A9D8F),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterTab(String title, String value) {
    final isSelected = selectedFilter == value;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2A9D8F) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Color(0xFF2A9D8F) : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(dynamic request) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    final status = request['status'] ?? 'pending';
    final feeAmount = _safeToDouble(request['fee_amount']);
    final totalDonated = _safeToDouble(request['total_donated']);
    final fundingProgress = (_safeToDouble(request['funding_progress'])).round();
    final isFunded = request['is_funded'] ?? false;
    final remainingAmount = _safeToDouble(request['remaining_amount'] ?? feeAmount);

    // Format date
    String formattedDate = 'N/A';
    if (request['created_at'] != null) {
      try {
        final date = DateTime.parse(request['created_at']);
        formattedDate = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        formattedDate = request['created_at'].toString().split('T')[0];
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                ),
                Spacer(),
                Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                  size: 20,
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Info
                Row(
                  children: [
                    Icon(Icons.person, color: Color(0xFF2A9D8F), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request['student_name'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Institution & Degree
                Row(
                  children: [
                    Icon(Icons.school, color: Colors.grey[600], size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${request['degree'] ?? 'N/A'} at ${request['institution_name'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 15,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Fee Amount and Date
                Row(
                  children: [
                    Icon(Icons.monetization_on, color: Colors.grey[600], size: 16),
                    SizedBox(width: 8),
                    Text(
                      'PKR ${feeAmount.round()} • $formattedDate',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Funding Progress (only for approved/funded requests)
                if (status == 'approved' || status == 'funded') ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Funding Progress',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '${fundingProgress}%',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              fontWeight: FontWeight.bold,
                              color: isFunded ? Colors.green : Color(0xFF2A9D8F),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: fundingProgress / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isFunded ? Colors.green : Color(0xFF2A9D8F),
                        ),
                        minHeight: 6,
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Raised: PKR ${totalDonated.round()}',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Remaining: PKR ${remainingAmount.round()}',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/education-request-detail',
                            arguments: request,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFF2A9D8F)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.visibility, color: Color(0xFF2A9D8F), size: 16),
                            SizedBox(width: 4),
                            Text(
                              'View Details',
                              style: TextStyle(
                                color: Color(0xFF2A9D8F),
                                fontSize: isSmallScreen ? 12 : 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (status == 'approved') ...[
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _shareRequest(request);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.share, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Share',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 12 : 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'funded':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'APPROVED';
      case 'pending':
        return 'PENDING';
      case 'funded':
        return 'FUNDED';
      case 'rejected':
        return 'REJECTED';
      default:
        return status.toUpperCase();
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'funded':
        return Icons.stars;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _shareRequest(dynamic request) {
    // Implement share functionality
    String shareText = '''
🎓 Help Support ${request['student_name']}'s Education!

${request['degree']} at ${request['institution_name']}
Fee Amount: PKR ${_safeToDouble(request['fee_amount']).round()}
Funding Progress: ${(_safeToDouble(request['funding_progress'])).round()}%

Every contribution makes a difference in someone's education journey!

#EducationSupport #HelpingHand
''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share feature coming soon!'),
        action: SnackBarAction(
          label: 'Copy Text',
          onPressed: () {
            // Copy to clipboard functionality would go here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Text copied to clipboard!')),
            );
          },
        ),
      ),
    );
  }
}