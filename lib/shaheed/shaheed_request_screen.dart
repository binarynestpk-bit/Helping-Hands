// lib/shaheed/shaheed_request_screen.dart - UPDATED WITH BACKEND
import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';

class ShuhadaSupportRequests extends StatefulWidget {
  @override
  _ShuhadaSupportRequestsState createState() => _ShuhadaSupportRequestsState();
}

class _ShuhadaSupportRequestsState extends State<ShuhadaSupportRequests> {
  List<Map<String, dynamic>> _familyRequests = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFamilyRequests();
  }

  Future<void> _loadFamilyRequests() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await ApiService.getAllFamilyRequests();

      if (response['success'] == true) {
        setState(() {
          _familyRequests = (response['data']['requests'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response['message'] ?? 'Failed to load family requests';
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

  List<Map<String, dynamic>> get _filteredRequests {
    if (_searchQuery.isEmpty) {
      return _familyRequests;
    }

    return _familyRequests.where((request) {
      final familyName = (request['family_name'] ?? request['family_head_name'] ?? '').toLowerCase();
      final martyrName = (request['martyr_name'] ?? '').toLowerCase();
      final city = (request['city'] ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();

      return familyName.contains(query) ||
          martyrName.contains(query) ||
          city.contains(query);
    }).toList();
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

  String _getPriorityColor(String? priority) {
    switch (priority) {
      case 'urgent':
        return 'red';
      case 'high':
        return 'orange';
      case 'medium':
        return 'blue';
      case 'low':
        return 'green';
      default:
        return 'blue';
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
            text: 'Shuhada Support ',
            style: TextStyle(
                color: Colors.black,
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w500
            ),
            children: [
              TextSpan(
                text: 'Requests',
                style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.w600
                ),
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
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 10
        ),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name, martyr name, city...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.teal))
                  : _hasError
                  ? _buildErrorWidget()
                  : _filteredRequests.isEmpty
                  ? _buildEmptyWidget()
                  : _buildRequestsList(),
            ),
          ],
        ),
      ),
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
            'Error Loading Requests',
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
            onPressed: _loadFamilyRequests,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/empty-folder.png',
            height: 100,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.folder_open,
              size: 100,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 20),
          Text(
            _searchQuery.isEmpty
                ? 'No Requests Available Right Now'
                : 'No requests found for "$_searchQuery"',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (_searchQuery.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              'Try adjusting your search terms',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadFamilyRequests,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: Text('Refresh', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return RefreshIndicator(
      onRefresh: _loadFamilyRequests,
      color: Colors.teal,
      child: ListView.builder(
        itemCount: _filteredRequests.length,
        itemBuilder: (context, index) {
          final request = _filteredRequests[index];
          return _buildRequestCard(context, request, isSmallScreen);
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> request, bool isSmallScreen) {
    final requestedAmount = _safeToDouble(request['requested_amount']);
    final totalDonated = _safeToDouble(request['total_donated']);
    final priorityLevel = request['priority_level'] ?? 'medium';
    final fundingProgress = request['funding_progress'] ?? 0;

    // Format martyrdom date
    String formattedDate = 'N/A';
    if (request['martyrdom_date'] != null) {
      try {
        final date = DateTime.parse(request['martyrdom_date']);
        formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (e) {
        formattedDate = request['martyrdom_date'].toString();
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(15),
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
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600
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
                        color: _getPriorityColor(priorityLevel) == 'red' ? Colors.red :
                        _getPriorityColor(priorityLevel) == 'orange' ? Colors.orange :
                        _getPriorityColor(priorityLevel) == 'green' ? Colors.green : Colors.blue,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      priorityLevel.toUpperCase(),
                      style: TextStyle(
                        color: _getPriorityColor(priorityLevel) == 'red' ? Colors.red :
                        _getPriorityColor(priorityLevel) == 'orange' ? Colors.orange :
                        _getPriorityColor(priorityLevel) == 'green' ? Colors.green : Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildDetailRow(Icons.favorite_border,
                'Family Head: ${request['family_name'] ?? request['family_head_name'] ?? 'N/A'}', isSmallScreen),
            _buildDetailRow(Icons.group,
                'No of Children: ${request['children_count'] ?? 0}', isSmallScreen),
            _buildDetailRow(Icons.calendar_today,
                'Date of Shahadat: $formattedDate', isSmallScreen),
            _buildDetailRow(Icons.receipt,
                'Requested: PKR ${requestedAmount.round()}', isSmallScreen),
            _buildDetailRow(Icons.location_on,
                'City: ${request['city'] ?? 'N/A'}', isSmallScreen),

            // Funding progress bar
            if (totalDonated > 0) ...[
              SizedBox(height: 10),
              Text(
                'Funding Progress: $fundingProgress%',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 5),
              LinearProgressIndicator(
                value: fundingProgress / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
              SizedBox(height: 5),
              Text(
                'Raised: PKR ${totalDonated.round()}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 11 : 12,
                  color: Colors.grey[600],
                ),
              ),
            ],

            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/shaheed-detail',
                    arguments: request,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 8 : 10,
                  ),
                ),
                child: Text(
                    'View Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 12 : 14,
                    )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(
              icon,
              size: isSmallScreen ? 18 : 20,
              color: Colors.teal
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
                text,
                style: TextStyle(fontSize: isSmallScreen ? 13 : 14)
            ),
          ),
        ],
      ),
    );
  }
}