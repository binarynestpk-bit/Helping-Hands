import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';

class EducationRequestDetail extends StatefulWidget {
  @override
  _EducationRequestDetailState createState() => _EducationRequestDetailState();
}

class _EducationRequestDetailState extends State<EducationRequestDetail> {
  dynamic request;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (request == null) {
      request = ModalRoute.of(context)?.settings.arguments;
      if (request != null) {
        _loadRequestDetails();
      }
    }
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

  Future<void> _loadRequestDetails() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await ApiService.get('/education/requests/${request['id']}');

      if (response['success']) {
        setState(() {
          request = response['data']['request'];
          isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading details: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    if (request == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF2A9D8F),
          title: Text('Request Details', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(child: Text('No request data found')),
      );
    }

    // FIXED: Safe handling of all numeric values
    final feeAmount = _safeToDouble(request['fee_amount']);
    final totalDonated = _safeToDouble(request['total_donated']);
    final remainingAmount = _safeToDouble(request['remaining_amount'] ?? feeAmount);
    final fundingProgress = (_safeToDouble(request['funding_progress'])).round();
    final isFunded = request['is_funded'] ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2A9D8F),
        title: Text(
          'Request Details',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF2A9D8F)))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isFunded ? Colors.green.withOpacity(0.1) : Color(0xFF2A9D8F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isFunded ? Colors.green : Color(0xFF2A9D8F),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isFunded ? 'FUNDED' : 'ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.school,
                          color: isFunded ? Colors.green : Color(0xFF2A9D8F),
                          size: 24,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      request['student_name'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${request['degree'] ?? 'N/A'} at ${request['institution_name'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A9D8F),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildDetailRow('Father Name', request['father_name'] ?? 'N/A', Icons.person),
                    _buildDetailRow('CGPA/Result', request['cgpa_result'] ?? 'N/A', Icons.grade),
                    _buildDetailRow('Semester/Year', request['semester_year'] ?? 'N/A', Icons.calendar_today),
                    _buildDetailRow('Phone', request['mobile_number'] ?? 'N/A', Icons.phone),
                    SizedBox(height: 16),
                    Text(
                      'Request Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A9D8F),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildDetailRow('Fee Amount', 'PKR ${feeAmount.round()}', Icons.monetization_on),
                    _buildDetailRow('Required Date', request['required_date'] ?? 'N/A', Icons.date_range),
                    if (request['reason'] != null) ...[
                      SizedBox(height: 12),
                      Text(
                        'Reason:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        request['reason'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Funding Progress Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Funding Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A9D8F),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${fundingProgress}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isFunded ? Colors.green : Color(0xFF2A9D8F),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: fundingProgress / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFunded ? Colors.green : Color(0xFF2A9D8F),
                      ),
                      minHeight: 8,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Raised', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            Text('PKR ${totalDonated.round()}', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Remaining', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            Text('PKR ${remainingAmount.round()}', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            // Donate Button
            if (!isFunded)
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _showDonationDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2A9D8F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Support This Student',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Color(0xFF2A9D8F)),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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

  void _showDonationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DonationDialog(
        request: request,
        onDonationComplete: () {
          _loadRequestDetails();
        },
      ),
    );
  }
}

// Simple Donation Dialog
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
  String selectedPaymentMethod = 'jazzcash';
  bool isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isProcessing = true;
    });

    try {
      final donationData = {
        'amount': double.parse(_amountController.text),
        'payment_method': selectedPaymentMethod,
      };

      final response = await ApiService.post(
        '/education/donate/${widget.request['id']}',
        donationData,
        includeAuth: true,
      );

      if (response['success']) {
        Navigator.of(context).pop();
        widget.onDonationComplete();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Success!'),
                ],
              ),
              content: Text(response['message'] ?? 'Thank you for your donation!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Support ${widget.request['student_name']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (PKR)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Amount required';
                if (double.tryParse(value) == null) return 'Invalid amount';
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedPaymentMethod,
              decoration: InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'jazzcash', child: Text('JazzCash')),
                DropdownMenuItem(value: 'easypaisa', child: Text('Easypaisa')),
                DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : _processDonation,
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2A9D8F)),
                    child: isProcessing
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Donate', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}