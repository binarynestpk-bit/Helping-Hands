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

  final Map<String, String> statusFilters = {
    'all': 'All Requests',
    'pending': 'Pending',
    'approved': 'Approved',
    'funded': 'Funded',
    'rejected': 'Rejected',
    'cancelled': 'Cancelled',
  };

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
        backgroundColor: Colors.white,
        elevation: 0,
        title: RichText(
          text: TextSpan(
            text: 'My Education ',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'Requests',
                style: TextStyle(
                  color: Color(0xFF2A9D8F),
                ),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF2A9D8F)),
            onPressed: _loadMyRequests,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Filter - Horizontal Scrolling Chips (like blood module)
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: statusFilters.length,
              itemBuilder: (context, index) {
                final status = statusFilters.keys.elementAt(index);
                final label = statusFilters[status]!;
                final isSelected = selectedFilter == status;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = status;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12, top: 8, bottom: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF2A9D8F) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
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

  Widget _buildRequestCard(dynamic request) {
    final status = request['status'] ?? 'pending';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with student name and status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Student: ${request['student_name'] ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Request details
            _buildDetailRow('Institution', request['institution_name'] ?? 'N/A', Icons.school),
            _buildDetailRow('Degree', request['degree'] ?? 'N/A', Icons.book),
            _buildDetailRow('Fee Amount', 'PKR ${_safeToDouble(request['fee_amount']).round()}', Icons.monetization_on),
            _buildDetailRow('Required Date', request['required_date'] ?? 'N/A', Icons.calendar_today),
            _buildDetailRow('Semester/Year', request['semester_year'] ?? 'N/A', Icons.school_outlined),

            SizedBox(height: 16),

            // Action buttons for pending/approved requests
            if (status == 'pending' || status == 'approved')
              Row(
                children: [
                  if (status == 'pending') ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showCancelDialog(request),
                        icon: Icon(Icons.cancel_outlined, size: 18),
                        label: Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                  if (status == 'approved') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/education-request-detail',
                            arguments: request,
                          );
                        },
                        icon: Icon(Icons.visibility, size: 18),
                        label: Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2A9D8F),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Color(0xFF2A9D8F)),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(dynamic request) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Education Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel this education request?'),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Reason (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancel functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cancel feature coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
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
        return 'Approved';
      case 'pending':
        return 'Pending Approval';
      case 'funded':
        return 'Funded';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }
}