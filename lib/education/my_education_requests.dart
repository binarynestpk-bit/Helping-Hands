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
  String? errorMessage;

  final Map<String, String> statusFilters = {
    'all': 'All',
    'pending': 'Pending',
    'approved': 'Approved',
    'partially_funded': 'Partially Funded',
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
      String err = e.toString();
      if (err.contains('401') || err.contains('Access token required') ||
          err.contains('403') || err.contains('access denied') ||
          err.contains('authentication') || err.contains('approved')) {
        Navigator.pushReplacementNamed(context, '/signin');
        return;
      }
      setState(() {
        isLoading = false;
        errorMessage = err;
      });
    }
  }

  List<dynamic> get filteredRequests {
    if (selectedFilter == 'all') {
      return myRequests;
    }
    return myRequests.where((request) =>
      _deriveStatus(request) == selectedFilter
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
                ? Center(child: CircularProgressIndicator(color: Color(0xFF2A9D8F)))
                : errorMessage != null
                ? Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 12),
                    Text(errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red[700])),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () { setState(() { errorMessage = null; }); _loadMyRequests(); },
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2A9D8F)),
                      child: Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
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
    final status = _deriveStatus(request);

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
              _cancelRequest(request['id'].toString(), reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelRequest(String requestId, String reason) async {
    try {
      final response = await ApiService.put('/education/requests/$requestId/cancel', {
        'reason': reason,
      });
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request cancelled successfully'), backgroundColor: Colors.orange),
        );
        _loadMyRequests();
      } else {
        throw Exception(response['message'] ?? 'Failed to cancel');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'approved': return Colors.green;
      case 'partially_funded': return Colors.teal;
      case 'funded': return Colors.blue;
      case 'rejected': return Colors.red;
      case 'cancelled': return Colors.grey;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Pending Approval';
      case 'approved': return 'Approved';
      case 'partially_funded': return 'Partially Funded';
      case 'funded': return 'Fully Funded';
      case 'rejected': return 'Rejected';
      case 'cancelled': return 'Cancelled';
      default: return status.toUpperCase();
    }
  }

  String _deriveStatus(dynamic request) {
    final base = (request['status'] ?? 'pending').toString().toLowerCase();
    if (base == 'approved') {
      final total = _safeToDouble(request['total_donated']);
      final fee = _safeToDouble(request['fee_amount']);
      if (total >= fee && fee > 0) return 'funded';
      if (total > 0) return 'partially_funded';
    }
    return base;
  }
}