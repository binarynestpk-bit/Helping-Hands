// lib/screens/islamic_donation_screen.dart (NEW SEPARATE PAGE)
import 'package:flutter/material.dart';
import 'package:helpinghand/services/api_service.dart';

class IslamicDonationScreen extends StatefulWidget {
  @override
  _IslamicDonationScreenState createState() => _IslamicDonationScreenState();
}

class _IslamicDonationScreenState extends State<IslamicDonationScreen> {
  String _selectedPaymentMethod = 'JazzCash';
  String _selectedDonationType = 'Zakat';
  final TextEditingController _amountController = TextEditingController(text: '1000');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isProcessing = false;
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, String>> _paymentMethods = [
    {'value': 'JazzCash', 'label': 'JazzCash'},
    {'value': 'Easypaisa', 'label': 'Easypaisa'},
    {'value': 'Credit/Debit Card', 'label': 'Credit/Debit Card'},
    {'value': 'Bank Transfer', 'label': 'Bank Transfer'},
  ];

  // Islamic donation types with descriptions
  final List<Map<String, dynamic>> _donationTypes = [
    {
      'value': 'Zakat',
      'label': 'Zakat',
      'description': 'Obligatory charity for eligible Muslims (2.5% of wealth)',
      'icon': Icons.security,
      'color': Color(0xFF2A9D8F),
      'arabicName': 'زكاة',
    },
    {
      'value': 'Khums',
      'label': 'Khums',
      'description': 'Religious tax on surplus income (20% for eligible)',
      'icon': Icons.account_balance,
      'color': Color(0xFF1976D2),
      'arabicName': 'خمس',
    },
    {
      'value': 'Sadaqah',
      'label': 'Sadaqah',
      'description': 'Voluntary charity given out of compassion and love',
      'icon': Icons.favorite,
      'color': Color(0xFFE91E63),
      'arabicName': 'صدقة',
    },
    {
      'value': 'Fitrah',
      'label': 'Sadaqah al-Fitr',
      'description': 'Charity given before Eid-ul-Fitr prayer',
      'icon': Icons.mosque,
      'color': Color(0xFF9C27B0),
      'arabicName': 'صدقة الفطر',
    },
    {
      'value': 'General',
      'label': 'General Donation',
      'description': 'Any other charitable contribution',
      'icon': Icons.volunteer_activism,
      'color': Color(0xFFFF9800),
      'arabicName': 'تبرع عام',
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processIslamicDonation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Get the selected donation type details
      final donationType = _donationTypes.firstWhere(
            (type) => type['value'] == _selectedDonationType,
        orElse: () => _donationTypes[0],
      );

      // Prepare donation data
      final donationData = {
        'donation_type': _selectedDonationType,
        'amount': double.parse(_amountController.text.trim()),
        'payment_method': _selectedPaymentMethod,
        'donor_name': _nameController.text.trim(),
        'donor_phone': _phoneController.text.trim(),
        'donor_email': _emailController.text.trim(),
        'notes': _notesController.text.trim(),
        'category': 'islamic_donation',
      };

      // Simulate API call (replace with actual API call)
      await Future.delayed(Duration(seconds: 2));

      // Show success dialog
      _showSuccessDialog(donationType);

    } catch (e) {
      _showError('Donation failed: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog(Map<String, dynamic> donationType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('تبارك الله!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your ${donationType['label']} (${donationType['arabicName']}) donation of PKR ${_amountController.text} has been processed successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF2A9D8F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'May Allah accept your charity and bless you abundantly.\nجزاك الله خيراً',
                style: TextStyle(
                  color: Color(0xFF2A9D8F),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to home screen
            },
            child: Text('Ameen', style: TextStyle(color: Color(0xFF2A9D8F), fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF2A9D8F),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.mosque, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              "Islamic Donation",
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Islamic greeting
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2A9D8F).withOpacity(0.1), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A9D8F),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Give in the way of Allah and contribute to those in need',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Donation Type Selection
              Text(
                "Select Type of Islamic Donation",
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A9D8F),
                ),
              ),
              SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF2A9D8F).withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: _donationTypes.map((donationType) {
                    return RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(
                            donationType['icon'],
                            color: donationType['color'],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      donationType['label'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      donationType['arabicName'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: donationType['color'],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  donationType['description'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      value: donationType['value'],
                      groupValue: _selectedDonationType,
                      onChanged: (value) {
                        setState(() {
                          _selectedDonationType = value!;
                        });
                      },
                      activeColor: donationType['color'],
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24),


              // Amount Input
              Text(
                "Donation Amount",
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A9D8F),
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF2A9D8F)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A9D8F),
                      ),
                      decoration: InputDecoration(
                        prefixText: 'PKR ',
                        prefixStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A9D8F),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Amount is required';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount < 100) {
                          return 'Please enter a valid amount (minimum PKR 100)';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Payment Method Selection
              Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A9D8F),
                ),
              ),
              SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: _paymentMethods.map((method) {
                    return RadioListTile<String>(
                      title: Text(method['label']!),
                      value: method['value']!,
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                      activeColor: Color(0xFF2A9D8F),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24),

              // Additional Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  hintText: 'Any special intention or message...',
                  prefixIcon: Icon(Icons.note, color: Color(0xFF2A9D8F)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF2A9D8F)),
                  ),
                ),
              ),
              SizedBox(height: 32),

              // Islamic reminder
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF2A9D8F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF2A9D8F).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Color(0xFF2A9D8F)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Remember: "The example of those who spend in the way of Allah is like a grain that sprouts seven ears; in every ear there are a hundred grains." - Quran 2:261',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2A9D8F),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Donate Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processIslamicDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2A9D8F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Processing...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Give ${_donationTypes.firstWhere((type) => type['value'] == _selectedDonationType)['label']} PKR ${_amountController.text}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'بِسْمِ اللَّهِ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}