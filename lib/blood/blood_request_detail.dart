import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:helpinghand/services/auth_service.dart';
import 'package:helpinghand/widgets/guest_access.dart';

class BloodRequestDetail extends StatefulWidget {
  @override
  _BloodRequestDetailState createState() => _BloodRequestDetailState();
}

class _BloodRequestDetailState extends State<BloodRequestDetail> {
  dynamic requestData;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the request data passed as arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      requestData = args as dynamic;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AuthService.isGuest()) {
      return const GuestLockedScaffold(title: 'Request Details');
    }
    if (requestData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Blood Request Detail')),
        body: Center(child: Text('No request data found')),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Request ',
            style: TextStyle(
                fontSize: isSmallScreen ? 16 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
            children: [
              TextSpan(
                text: 'Details',
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 20
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Card
            _buildInfoCard(
              'Patient Information',
              [
                _buildDetailRow('Patient Name', requestData['patient_name'] ?? 'N/A', Icons.person),
                _buildDetailRow('Blood Group', requestData['blood_group'] ?? 'N/A', Icons.bloodtype),
                _buildDetailRow('Mobile Number', requestData['mobile_number'] ?? 'N/A', Icons.phone),
              ],
              isSmallScreen,
            ),

            SizedBox(height: 20),

            // Hospital Info Card
            _buildInfoCard(
              'Hospital Information',
              [
                _buildDetailRow('Hospital Name', requestData['hospital_name'] ?? 'N/A', Icons.local_hospital),
                _buildDetailRow('Location', requestData['location'] ?? 'N/A', Icons.location_on),
              ],
              isSmallScreen,
            ),

            SizedBox(height: 20),

            // Request Details Card
            _buildInfoCard(
              'Request Details',
              [
                _buildDetailRow('Case Type', requestData['case_type'] ?? 'N/A', Icons.medical_services),
                _buildDetailRow('Urgency Level', requestData['urgency_level'] ?? 'N/A', Icons.priority_high),
                _buildDetailRow('Required Date', requestData['required_date'] ?? 'N/A', Icons.calendar_today),
                _buildDetailRow('Blood Units Needed', '${requestData['blood_units'] ?? 'N/A'} Units', Icons.opacity),
                _buildDetailRow('Request Status', requestData['status'] ?? 'N/A', Icons.info),
              ],
              isSmallScreen,
            ),

            SizedBox(height: 20),

            // Additional Details (if any)
            if (requestData['additional_details'] != null && requestData['additional_details'].toString().isNotEmpty)
              _buildInfoCard(
                'Additional Details',
                [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      requestData['additional_details'],
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                isSmallScreen,
              ),

            SizedBox(height: 20),

            // Requester Info (if available)
            if (requestData['requester'] != null)
              _buildInfoCard(
                'Requester Information',
                [
                  _buildDetailRow('Name', requestData['requester']['full_name'] ?? 'N/A', Icons.account_circle),
                  if (requestData['requester']['phone'] != null)
                    _buildDetailRow('Phone', requestData['requester']['phone'], Icons.phone),
                ],
                isSmallScreen,
              ),

            SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareRequest(),
                    icon: Icon(Icons.share, color: Color(0xFFE01219)),
                    label: Text('Share'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFFE01219),
                      side: BorderSide(color: Color(0xFFE01219)),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _donateBlood(),
                    icon: Icon(Icons.favorite, color: Colors.white),
                    label: Text('Donate Blood', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE01219),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildInfoCard(String title, List<Widget> children, bool isSmallScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE01219),
              ),
            ),
            SizedBox(height: 15),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: isSmallScreen ? 18 : 20,
            color: Color(0xFFE01219),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareRequest() {
    final message = '''
🩸 URGENT BLOOD REQUEST 🩸

Patient: ${requestData['patient_name']}
Blood Group: ${requestData['blood_group']}
Hospital: ${requestData['hospital_name']}
Location: ${requestData['location']}
Required Date: ${requestData['required_date']}
Units Needed: ${requestData['blood_units']}

Please help if you can donate blood!
Contact: ${requestData['mobile_number']}

#BloodDonation #SaveLife #HelpingHand
    ''';

    // TODO: Implement actual sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality will be implemented'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _donateBlood() {
    showDialog(
      context: context,
      builder: (context) => _buildDonationDialog(),
    );
  }

  Widget _buildDonationDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();
    bool isSubmitting = false;

    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Donate Blood'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Patient: ${requestData['patient_name']}'),
              Text('Blood Group: ${requestData['blood_group']}'),
              Text('Hospital: ${requestData['hospital_name']}'),
              SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Your Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: isSubmitting ? null : () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: isSubmitting ? null : () async {
              if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill name and phone')),
                );
                return;
              }

              setState(() => isSubmitting = true);

              try {
                final response = await ApiService.post('/blood/donate/${requestData['id']}', {
                  'donor_name': nameController.text.trim(),
                  'donor_phone': phoneController.text.trim(),
                  'notes': notesController.text.trim(),
                }, includeAuth: true);

                if (response['success'] == true) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Blood donation commitment recorded!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() => isSubmitting = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE01219)),
            child: isSubmitting
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : Text('Commit to Donate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}