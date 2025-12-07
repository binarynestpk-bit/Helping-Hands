import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';

class MyFamilyRequests extends StatefulWidget {
  const MyFamilyRequests({Key? key}) : super(key: key);

  @override
  _MyFamilyRequestsState createState() => _MyFamilyRequestsState();
}

class _MyFamilyRequestsState extends State<MyFamilyRequests> {
  List<dynamic> myRequests = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedStatus = 'all';

  // CONSISTENT STATUS FILTERS WITH BLOOD REQUESTS
  final Map<String, String> statusFilters = {
    'all': 'All Requests',
    'pending': 'Pending',
    'under_review': 'Under Review',
    'approved': 'Approved',
    'partially_funded': 'Partially Funded',
    'fully_funded': 'Fully Funded',
    'fulfilled_through_app': 'Fulfilled via App',
    'fulfilled_outside_app': 'Fulfilled Outside',
    'rejected': 'Rejected',
    'cancelled': 'Cancelled',
  };

  @override
  void initState() {
    super.initState();
    _loadMyRequests();
  }

  Future<void> _loadMyRequests() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print('🔍 Loading family requests with status: $selectedStatus');

      final params = selectedStatus != 'all' ? '?status=$selectedStatus' : '';

      // Try enhanced endpoint first, then fallback to basic
      List<String> endpointsToTry = [
        '/family/user/requests-enhanced$params',
        '/shaheed/user/requests-enhanced$params',
        '/family/user/requests$params',
        '/shaheed/user/requests$params',
      ];

      Exception? lastError;

      for (String endpoint in endpointsToTry) {
        try {
          print('🌐 Trying endpoint: $endpoint');
          final response = await ApiService.get(endpoint);
          print('✅ Response from $endpoint: ${response['success']}');

          if (response['success'] == true) {
            setState(() {
              var requestsData = response['data'];
              if (requestsData is Map && requestsData.containsKey('requests')) {
                myRequests = requestsData['requests'] ?? [];
              } else if (requestsData is List) {
                myRequests = requestsData;
              } else {
                myRequests = [];
              }
              print('📊 Loaded ${myRequests.length} family requests');
              if (myRequests.isNotEmpty) {
                print('🏷️ First request status: ${myRequests[0]['status']}');
              }
              isLoading = false;
            });
            return; // Success - exit the function
          }
        } catch (e) {
          print('❌ Failed endpoint $endpoint: $e');
          lastError = e is Exception ? e : Exception(e.toString());
          continue; // Try next endpoint
        }
      }

      // If all endpoints failed, throw the last error
      throw lastError ?? Exception('All family request endpoints failed');

    } catch (e) {
      print('🚨 Final error: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refreshRequests() async {
    await _loadMyRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'My Family ',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
            children: [
              TextSpan(
                text: 'Requests',
                style: TextStyle(color: Color(0xFF2A9D8F)),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF2A9D8F)),
            onPressed: _refreshRequests,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Filter
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: statusFilters.length,
              itemBuilder: (context, index) {
                final status = statusFilters.keys.elementAt(index);
                final label = statusFilters[status]!;
                final isSelected = selectedStatus == status;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedStatus = status;
                    });
                    _loadMyRequests();
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

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshRequests,
              child: _buildContent(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/shaheed-family-form');
        },
        backgroundColor: Color(0xFF2A9D8F),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF2A9D8F)),
            SizedBox(height: 16),
            Text('Loading your requests...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Error: $errorMessage'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshRequests,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (myRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.family_restroom, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No family requests found'),
            if (selectedStatus != 'all')
              Text('Try changing the filter above'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/shaheed-family-form');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2A9D8F),
              ),
              child: Text('Create Request', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: myRequests.length,
      itemBuilder: (context, index) {
        final request = myRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(dynamic request) {
    // Create status badge from actual status field
    final status = request['status'] ?? 'unknown';
    final statusBadge = _getStatusBadge(status);
    final donationsCount = request['donationsCount'] ?? 0;

    // Check if buttons should be shown - CONSISTENT WITH BLOOD REQUESTS
    final canCancel = request['canCancel'] ?? false;
    final canMarkFulfilled = request['canMarkFulfilled'] ?? false;
    final showActionButtons = request['showActionButtons'] ?? false;

    // Final states where no buttons should appear
    final isFinalState = ['fulfilled_through_app', 'fulfilled_outside_app', 'cancelled', 'rejected'].contains(status?.toLowerCase());
    final shouldShowButtons = !isFinalState && showActionButtons && (canCancel || canMarkFulfilled);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with family name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Family: ${request['family_name'] ?? 'Unknown'}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorFromHex(statusBadge['color']!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusBadge['text']!,
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
            _buildDetailRow('Father Name', request['father_name'] ?? 'N/A', Icons.person),
            _buildDetailRow('Children Count', '${request['children_count'] ?? 0}', Icons.child_care),
            _buildDetailRow('Monthly Need', 'PKR ${_safeToDouble(request['monthly_need']).round()}', Icons.attach_money),
            _buildDetailRow('Shahadat Date', _formatDate(request['shahadat_date']), Icons.calendar_today),
            _buildDetailRow('Shahadat Place', request['shahadat_place'] ?? 'N/A', Icons.location_on),

            if (donationsCount > 0)
              _buildDetailRow('Donations Received', '$donationsCount', Icons.favorite),

            // Show additional info for fulfilled/cancelled requests
            if (request['fulfilled_at'] != null)
              _buildDetailRow('Fulfilled On', _formatDate(request['fulfilled_at']), Icons.check_circle),

            if (request['cancelled_at'] != null)
              _buildDetailRow('Cancelled On', _formatDate(request['cancelled_at']), Icons.cancel),

            if (request['fulfillment_notes'] != null && request['fulfillment_notes'].toString().isNotEmpty)
              _buildDetailRow('Notes', request['fulfillment_notes'].toString(), Icons.note),

            if (request['cancelled_reason'] != null && request['cancelled_reason'].toString().isNotEmpty)
              _buildDetailRow('Cancel Reason', request['cancelled_reason'].toString(), Icons.note),

            SizedBox(height: 16),

            // Action buttons - ONLY SHOW FOR NON-FINAL STATES
            if (shouldShowButtons)
              Row(
                children: [
                  if (canCancel) ...[
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
                    if (canMarkFulfilled) SizedBox(width: 12),
                  ],
                  if (canMarkFulfilled)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showFulfillmentDialog(request),
                        icon: Icon(Icons.check, size: 18),
                        label: Text('Mark Fulfilled'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF10B981),
                          foregroundColor: Colors.white,
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
        title: Text('Cancel Family Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel this family support request?'),
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
            onPressed: () async {
              Navigator.pop(context);
              await _cancelRequest(request['id'], reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFulfillmentDialog(dynamic request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark as Fulfilled'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How was the family support provided?'),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _markFulfilled(request['id'], 'app');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3B82F6)),
                    child: Text('Through App', style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _markFulfilled(request['id'], 'outside');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8B5CF6)),
                    child: Text('Outside App', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelRequest(dynamic requestId, String reason) async {
    try {
      final response = await ApiService.put('/family/requests/${requestId.toString()}/cancel', {
        'reason': reason,
      });

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Family request cancelled successfully'),
            backgroundColor: Colors.orange,
          ),
        );
        _refreshRequests();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markFulfilled(dynamic requestId, String method) async {
    try {
      final response = await ApiService.put('/family/requests/${requestId.toString()}/fulfill', {
        'fulfilled_through': method,
        'notes': method == 'app' ? 'Fulfilled through app donation' : 'Fulfilled outside app',
      });

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request marked as fulfilled!'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshRequests();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Create proper status badge based on status - CONSISTENT WITH BLOOD REQUESTS
  Map<String, String> _getStatusBadge(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return {'text': 'Pending', 'color': '#F59E0B'};
      case 'under_review':
        return {'text': 'Under Review', 'color': '#3B82F6'};
      case 'approved':
        return {'text': 'Approved', 'color': '#10B981'};
      case 'partially_funded':
        return {'text': 'Partially Funded', 'color': '#8B5CF6'};
      case 'fully_funded':
        return {'text': 'Fully Funded', 'color': '#059669'};
      case 'fulfilled_through_app':
        return {'text': 'Fulfilled via App', 'color': '#3B82F6'};
      case 'fulfilled_outside_app':
        return {'text': 'Fulfilled Outside', 'color': '#8B5CF6'};
      case 'rejected':
        return {'text': 'Rejected', 'color': '#EF4444'};
      case 'cancelled':
        return {'text': 'Cancelled', 'color': '#6B7280'};
      default:
        return {'text': 'Unknown', 'color': '#6B7280'};
    }
  }

  // Safe conversion method
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

  Color _getColorFromHex(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey; // fallback color
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}