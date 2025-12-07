// lib/shaheed/shaheed_donation_confirm.dart - UPDATED WITH BACKEND
import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';

class ConfirmDonationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ConfirmDonationPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ConfirmDonationPage extends StatefulWidget {
  @override
  _ConfirmDonationPageState createState() => _ConfirmDonationPageState();
}

class _ConfirmDonationPageState extends State<ConfirmDonationPage> {
  String? _selectedPaymentMethod = 'JazzCash'; // Updated to match backend enum
  String _selectedDonationType = 'one_time';
  final TextEditingController _donationAmountController = TextEditingController(text: '15000');

  bool _isLoading = false;
  Map<String, dynamic>? _familyRequest;

  // Payment method options (matching backend exactly)
  final List<Map<String, String>> _paymentMethods = [
    {'value': 'Credit/Debit Card', 'label': 'Credit/Debit Card'},
    {'value': 'JazzCash', 'label': 'JazzCash'},
    {'value': 'Easypaisa', 'label': 'Easypaisa'},
    {'value': 'Bank Transfer', 'label': 'Bank Transfer'},
  ];

  final List<Map<String, String>> _donationTypes = [
    {'value': 'one_time', 'label': 'One-time Donation'},
    {'value': 'monthly_recurring', 'label': 'Monthly Recurring'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (request != null) {
      _familyRequest = request;
      // Set suggested donation amount based on remaining amount
      final remainingAmount = _safeToDouble(request['remaining_amount']);
      if (remainingAmount > 0) {
        _donationAmountController.text = (remainingAmount / 4).round().toString(); // Suggest 1/4 of remaining
      }
    } else {
      // Fallback data
      _familyRequest = {
        'id': 'default-family',
        'family_head_name': 'M.Akbar Family',
        'martyr_name': 'M.Akbar',
        'requested_amount': 50000.0,
        'total_donated': 0.0,
        'remaining_amount': 50000.0,
      };
    }
  }

  @override
  void dispose() {
    _donationAmountController.dispose();
    super.dispose();
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

  Future<void> _processDonation() async {
    if (_familyRequest == null) {
      _showErrorDialog('Family request information not available');
      return;
    }

    final amount = _donationAmountController.text.trim();
    if (amount.isEmpty || double.tryParse(amount) == null || double.parse(amount) <= 0) {
      _showErrorDialog('Please enter a valid donation amount');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final donationData = {
        'amount': double.parse(amount),
        'payment_method': _selectedPaymentMethod!,
        'donation_type': _selectedDonationType,
      };

      final response = await ApiService.donateToFamily(
        _familyRequest!['id'],
        donationData,
      );

      if (response['success'] == true) {
        _showSuccessDialog(amount);
      } else {
        _showErrorDialog(response['message'] ?? 'Failed to process donation');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String amount) {
    final familyName = _familyRequest!['family_head_name'] ?? 'the family';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Donation Successful'),
          ],
        ),
        content: Text(
          'Thank you for your generous donation of PKR $amount to $familyName! Your contribution will make a significant difference in their lives.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                      (route) => false
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Donation Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    if (_familyRequest == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Confirm Donation'),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Text('Family request information not available'),
        ),
      );
    }

    final requestedAmount = _safeToDouble(_familyRequest!['requested_amount']);
    final totalDonated = _safeToDouble(_familyRequest!['total_donated']);
    final remainingAmount = _safeToDouble(_familyRequest!['remaining_amount']);

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Confirm Your ',
            style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
            children: [
              TextSpan(
                text: 'Donation',
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
          : SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Family Details Card
            Card(
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
                                'Family of: ${_familyRequest!['martyr_name'] ?? 'Unknown'}',
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(height: 5),
                              buildInfoRow("assets/heart.png",
                                  'Family Head: ${_familyRequest!['family_head_name'] ?? 'N/A'}', isSmallScreen),
                              buildInfoRow("assets/user.png",
                                  'No of Children: ${_familyRequest!['children_count'] ?? 0}', isSmallScreen),
                              buildInfoRow("assets/calendar.png",
                                  'Status: ${_familyRequest!['status'] ?? 'Active'}', isSmallScreen),
                              buildInfoRow("assets/money.png",
                                  'Goal: PKR ${requestedAmount.round()}', isSmallScreen),
                              if (totalDonated > 0)
                                buildInfoRow("assets/money.png",
                                    'Raised: PKR ${totalDonated.round()}', isSmallScreen),
                              buildInfoRow("assets/money.png",
                                  'Remaining: PKR ${remainingAmount.round()}', isSmallScreen),
                              SizedBox(height: 30),
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
                                    color: remainingAmount > 0 ? Colors.red : Colors.green,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                    remainingAmount > 0 ? 'Active' : 'Funded',
                                    style: TextStyle(
                                      color: remainingAmount > 0 ? Colors.red : Colors.green,
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
                        onPressed: () {
                          Navigator.pushNamed(context, '/shaheed-detail', arguments: _familyRequest);
                        },
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
            ),
            SizedBox(height: 20),

            // Select Payment Method Section
            Text(
              'Select Payment Method',
              style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: _paymentMethods.map((method) {
                    return RadioListTile<String>(
                      title: Text(
                        method['label']!,
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                      ),
                      value: method['value']!,
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value;
                        });
                      },
                      activeColor: Color(0xFF2A9D8F),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Donation Type Section
            Text(
              'Donation Type',
              style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: _donationTypes.map((type) {
                    return RadioListTile<String>(
                      title: Text(
                        type['label']!,
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                      ),
                      value: type['value']!,
                      groupValue: _selectedDonationType,
                      onChanged: (value) {
                        setState(() {
                          _selectedDonationType = value!;
                        });
                      },
                      activeColor: Color(0xFF2A9D8F),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Donation Amount Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Donation Amount',
                      style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(
                      width: isSmallScreen ? 100 : 120,
                      child: TextField(
                        controller: _donationAmountController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold
                        ),
                        decoration: InputDecoration(
                          prefixText: 'PKR ',
                          prefixStyle: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Summary
            if (remainingAmount > 0) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFEAF5F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Donation Impact',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A9D8F),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your donation will help this family with their immediate needs and ongoing support.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],

            // Donate Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processDonation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2A9D8F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 15),
                ),
                child: Text(
                  'Donate Now',
                  style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String iconPath, String text, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Image.asset(
              iconPath,
              width: isSmallScreen ? 16 : 16,
              height: isSmallScreen ? 16 : 16
          ),
          SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}