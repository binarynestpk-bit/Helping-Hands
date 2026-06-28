import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:helpinghand/services/auth_service.dart';

class EducationRequestsList extends StatefulWidget {
  @override
  _EducationRequestsListState createState() => _EducationRequestsListState();
}

class _EducationRequestsListState extends State<EducationRequestsList> {
  List<dynamic> educationRequests = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEducationRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEducationRequests() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await ApiService.get('/education/requests');

      if (response['success']) {
        setState(() {
          educationRequests = response['data']['requests'];
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
          content: Text('Error loading requests: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshRequests() async {
    await _loadEducationRequests();
  }

  List<dynamic> get filteredRequests {
    if (searchQuery.isEmpty) {
      return educationRequests;
    }
    return educationRequests.where((request) {
      final studentName = (request['student_name'] ?? '').toString().toLowerCase();
      final institution = (request['institution_name'] ?? '').toString().toLowerCase();
      final degree = (request['degree'] ?? '').toString().toLowerCase();
      final searchLower = searchQuery.toLowerCase();

      return studentName.contains(searchLower) ||
          institution.contains(searchLower) ||
          degree.contains(searchLower);
    }).toList();
  }

  // FIXED: Safe conversion function to handle all numeric values
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2A9D8F),
        title: RichText(
          text: TextSpan(
            text: 'Education ',
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
            onPressed: _refreshRequests,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by student, institution, or degree...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF2A9D8F)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
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
                  Text('Loading education requests...'),
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
                    searchQuery.isEmpty
                        ? 'No education requests available'
                        : 'No requests found for "$searchQuery"',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (searchQuery.isNotEmpty) ...[
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      child: Text('Clear search'),
                    ),
                  ],
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _refreshRequests,
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
    );
  }

  Widget _buildRequestCard(dynamic request) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    // FIXED: Use safe conversion for all numeric values
    final fundingProgress = (_safeToDouble(request['funding_progress'])).round();
    final totalDonated = _safeToDouble(request['total_donated']);
    final feeAmount = _safeToDouble(request['fee_amount']);
    final remainingAmount = _safeToDouble(request['remaining_amount'] ?? feeAmount);
    final isFunded = request['is_funded'] ?? false;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
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
              color: isFunded ? Colors.green.withOpacity(0.1) : Color(0xFF2A9D8F).withOpacity(0.1),
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
                    color: isFunded ? Colors.green : Color(0xFF2A9D8F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isFunded ? 'FUNDED' : 'ACTIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.school,
                  color: isFunded ? Colors.green : Color(0xFF2A9D8F),
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

                // CGPA & Semester
                Row(
                  children: [
                    Icon(Icons.grade, color: Colors.grey[600], size: 16),
                    SizedBox(width: 8),
                    Text(
                      'CGPA: ${request['cgpa_result'] ?? 'N/A'} | ${request['semester_year'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Fee Amount
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Fee: PKR ${feeAmount.round()}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),

                // Funding Progress
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
                SizedBox(height: 16),

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
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isFunded ? null : () {
                          _showDonationDialog(request);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFunded ? Colors.grey : Color(0xFF2A9D8F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isFunded ? Icons.check : Icons.favorite,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              isFunded ? 'Funded' : 'Donate',
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDonationDialog(dynamic request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DonationDialog(
        request: request,
        onDonationComplete: () {
          _refreshRequests();
        },
      ),
    );
  }
}

class DonationDialog extends StatefulWidget {
  final dynamic request;
  final VoidCallback onDonationComplete;

  const DonationDialog({
    Key? key,
    required this.request,
    required this.onDonationComplete,
  }) : super(key: key);

  @override
  _DonationDialogState createState() => _DonationDialogState();
}

class _DonationDialogState extends State<DonationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  bool isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processDonation() async {
    if (!AuthService.isLoggedIn()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to make a donation'), backgroundColor: Colors.red),
      );
      Navigator.of(context).pop();
      Navigator.pushReplacementNamed(context, '/signin');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final userData = AuthService.getUserData();
    final donorEmail = userData?['email']?.toString() ?? '';
    final donorPhone = (userData?['phone'] ?? userData?['mobile'] ?? '').toString();
    final donorName = userData?['full_name']?.toString() ?? '';

    // Step 1: Process real payment through Zindigi
    final paymentResult = await Navigator.pushNamed(
      context,
      '/zindigi-payment',
      arguments: {
        'amount': amount,
        'donor_mobile': donorPhone,
        'donor_email': donorEmail,
        'donor_name': donorName,
        'donation_type': 'education',
        'request_id': widget.request['id'].toString(),
      },
    ) as Map<String, dynamic>?;

    if (!mounted) return;

    if (paymentResult == null || paymentResult['success'] != true) {
      if (paymentResult?['cancelled'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Please try again.'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    // Payment confirmed server-side. The backend records the donation and
    // updates the request's funding status once Zindigi confirms the payment.
    if (!mounted) return;
    Navigator.of(context).pop();
    widget.onDonationComplete();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Donation Successful!'),
        ]),
        content: const Text('Thank you for your donation!'),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    final remainingAmount = _safeToDouble(widget.request['remaining_amount'] ?? widget.request['fee_amount']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          // Clear the phone's system navigation bar so the buttons are tappable.
          bottom: 20 + MediaQuery.of(context).padding.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),

              Row(
                children: [
                  Icon(Icons.favorite, color: Color(0xFF2A9D8F)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Support ${widget.request['student_name'] ?? 'Student'}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A9D8F),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF2A9D8F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.request['degree'] ?? 'N/A'} at ${widget.request['institution_name'] ?? 'N/A'}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2A9D8F),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Remaining Amount: PKR ${remainingAmount.round()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              Text(
                'Donation Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (PKR)',
                  prefixIcon: Icon(Icons.monetization_on, color: Color(0xFF2A9D8F)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF2A9D8F)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Enter valid amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isProcessing ? null : () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : _processDonation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2A9D8F),
                      ),
                      child: isProcessing
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Donate Now',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add the missing _safeToDouble function
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
}