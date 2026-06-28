import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:helpinghand/services/auth_service.dart';

class MyBloodRequests extends StatefulWidget {
  const MyBloodRequests({Key? key}) : super(key: key);

  @override
  _MyBloodRequestsState createState() => _MyBloodRequestsState();
}

class _MyBloodRequestsState extends State<MyBloodRequests> {
  List<dynamic> myRequests = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedStatus = 'all';

  final Map<String, String> statusFilters = {
    'all': 'All Requests',
    'pending': 'Pending',
    'approved': 'Approved',
    'fulfilled': 'Fulfilled',
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
        errorMessage = null;
      });

      final params = selectedStatus != 'all' ? '?status=$selectedStatus' : '';
      final response = await ApiService.get('/blood/user/requests-enhanced$params', includeAuth: true);

      if (response['success'] == true) {
        setState(() {
          myRequests = response['data']['requests'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
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
            text: 'My Blood ',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
            children: [
              TextSpan(
                text: 'Requests',
                style: TextStyle(color: Color(0xFFE01219)),
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
            icon: Icon(Icons.refresh, color: Color(0xFFE01219)),
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
                      color: isSelected ? Color(0xFFE01219) : Colors.grey.shade200,
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
          Navigator.pushNamed(context, '/blood-form');
        },
        backgroundColor: Color(0xFFE01219),
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
            CircularProgressIndicator(color: Color(0xFFE01219)),
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
            Icon(Icons.bloodtype, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No blood requests found'),
            if (selectedStatus != 'all')
              Text('Try changing the filter above'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/blood-form');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE01219),
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
    final statusBadge = request['statusBadge'] ?? {'text': 'Unknown', 'color': '#6B7280'};
    final canCancel = request['canCancel'] ?? false;
    final canMarkFulfilled = request['canMarkFulfilled'] ?? false;
    final donationsCount = request['donationsCount'] ?? 0;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with patient name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Patient: ${request['patient_name'] ?? 'Unknown'}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorFromHex(statusBadge['color']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusBadge['text'],
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
            _buildDetailRow('Blood Group', request['blood_group'] ?? 'N/A', Icons.bloodtype),
            _buildDetailRow('Hospital', request['hospital_name'] ?? 'N/A', Icons.local_hospital),
            _buildDetailRow('Location', request['location'] ?? 'N/A', Icons.location_on),
            _buildDetailRow('Required Date', request['required_date'] ?? 'N/A', Icons.calendar_today),
            _buildDetailRow('Units Needed', '${request['blood_units'] ?? 'N/A'} Units', Icons.opacity),

            if (donationsCount > 0)
              _buildDetailRow('Donations Received', '$donationsCount', Icons.favorite),

            // Show additional info for fulfilled/cancelled requests
            if (request['fulfilled_at'] != null)
              _buildDetailRow('Fulfilled On', _formatDate(request['fulfilled_at']), Icons.check_circle),

            if (request['cancelled_at'] != null)
              _buildDetailRow('Cancelled On', _formatDate(request['cancelled_at']), Icons.cancel),

            if (request['fulfillment_notes'] != null && request['fulfillment_notes'].toString().isNotEmpty)
              _buildDetailRow('Notes', request['fulfillment_notes'].toString(), Icons.note),

            SizedBox(height: 16),

            // Action buttons
            if (canCancel || canMarkFulfilled)
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
          Icon(icon, size: 18, color: Color(0xFFE01219)),
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
        title: Text('Cancel Blood Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel this blood request?'),
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
            Text('How did you receive the blood?'),
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

  Future<void> _cancelRequest(String requestId, String reason) async {
    try {
      final response = await ApiService.put('/blood/requests/$requestId/cancel', {
        'reason': reason,
      });

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Blood request cancelled successfully'),
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

  Future<void> _markFulfilled(String requestId, String method) async {
    try {
      final response = await ApiService.put('/blood/requests/$requestId/fulfill', {
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}