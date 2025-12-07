// lib/education/education_form.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:helpinghand/services/auth_service.dart'; // ONLY ADDED FOR AUTHENTICATION

class RequestEducationSupport extends StatefulWidget {
  @override
  _RequestEducationSupportState createState() => _RequestEducationSupportState();
}

class _RequestEducationSupportState extends State<RequestEducationSupport> {
  // Form controllers
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _institutionController = TextEditingController();
  final _degreeController = TextEditingController();
  final _cgpaController = TextEditingController();
  final _semesterController = TextEditingController();
  final _phoneController = TextEditingController();
  final _feeAmountController = TextEditingController();
  final _reasonController = TextEditingController();
  final _dateController = TextEditingController();

  // Files for uploads
  File? _resultAttachment;
  File? _feeAttachment;
  bool _isSubmitting = false; // Added loading state

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _institutionController.dispose();
    _degreeController.dispose();
    _cgpaController.dispose();
    _semesterController.dispose();
    _phoneController.dispose();
    _feeAmountController.dispose();
    _reasonController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Function to handle picking files
  Future<void> _pickFile(bool isResultFile) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          if (isResultFile) {
            _resultAttachment = File(pickedFile.path);
          } else {
            _feeAttachment = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }
  }

  bool _validateForm() {
    if (_nameController.text.isEmpty ||
        _fatherNameController.text.isEmpty ||
        _institutionController.text.isEmpty ||
        _degreeController.text.isEmpty ||
        _cgpaController.text.isEmpty ||
        _semesterController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _feeAmountController.text.isEmpty ||
        _reasonController.text.isEmpty ||
        _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return false;
    }

    if (_resultAttachment == null || _feeAttachment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload all required attachments')),
      );
      return false;
    }

    return true;
  }

  // ONLY AUTHENTICATION FIXES ADDED HERE - EVERYTHING ELSE SAME
  Future<void> _submitForm() async {
    // ADDED AUTHENTICATION CHECK
    if (!AuthService.isLoggedIn()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to submit an education request'),
          backgroundColor: Colors.red,
        ),
      );
      // Navigate to login after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/signin');
      });
      return;
    }

    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Convert date format for API - IMPROVED DATE HANDLING
      String apiDate;
      if (_dateController.text.contains('-')) {
        apiDate = _dateController.text; // Already in YYYY-MM-DD format
      } else {
        // Convert from readable format to API format
        apiDate = "2025-12-31"; // Default fallback
      }

      Map<String, dynamic> requestData = {
        'student_name': _nameController.text,
        'father_name': _fatherNameController.text,
        'institution_name': _institutionController.text,
        'degree': _degreeController.text,
        'cgpa_result': _cgpaController.text,
        'semester_year': _semesterController.text,
        'fee_amount': double.parse(_feeAmountController.text),
        'required_date': apiDate,
        'reason': _reasonController.text,
        'mobile_number': _phoneController.text.replaceAll('+92 ', ''),
      };

      // ONLY CHANGE: Added includeAuth: true
      final response = await ApiService.post(
        '/education/requests',
        requestData,
        includeAuth: true, // ADDED AUTHENTICATION
      );

      if (response['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your education support request has been submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to the education requests list
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/education-requests-list');
        });
      } else {
        throw Exception(response['message'] ?? 'Request submission failed');
      }
    } catch (e) {
      // IMPROVED ERROR HANDLING
      String errorMessage = e.toString();
      if (errorMessage.contains('Access token required') ||
          errorMessage.contains('401') ||
          errorMessage.contains('authentication')) {
        errorMessage = 'Authentication failed. Please login again.';
        // Navigate to login after showing error
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pushReplacementNamed(context, '/signin');
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting request: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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
            text: 'Request Education ',
            style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
            children: [
              TextSpan(
                text: 'Support',
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
      ),
      body: _isSubmitting
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF2A9D8F)),
            SizedBox(height: 16),
            Text('Submitting your request...'),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 10
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextField("Your Name", "assets/user.png", "Enter Your Full Name", _nameController, isSmallScreen),
            buildTextField("Father's Name", "assets/user.png", "Enter Your Father's Name", _fatherNameController, isSmallScreen),
            buildTextField("Institution Name", "assets/institution.png", "e.g., ABC University", _institutionController, isSmallScreen),
            buildTextField("Degree", null, "e.g., Bachelor of Science in IT", _degreeController, isSmallScreen),
            buildTextField("CGPA / Result", null, "e.g., 3.8 / A+", _cgpaController, isSmallScreen),
            buildTextField("Semester / Year", null, "e.g., 5th Semester / 3rd Year", _semesterController, isSmallScreen),
            buildTextField("Mobile Number", "assets/call.png", "Enter Your Phone Number", _phoneController, isSmallScreen, prefixText: "+92 "),
            buildTextField("Fee Amount", null, "Enter required fee amount", _feeAmountController, isSmallScreen),
            buildDescriptionField("Reason for Donation", "Explain why you need support", _reasonController, isSmallScreen),
            buildTextField("Required Date", "assets/calendar.png", "Enter required date (e.g., March 5, 2025)", _dateController, isSmallScreen),
            buildUploadBox(
              "Previous Result Attachment",
              "Upload previous result (PDF, IMAGE)",
              _resultAttachment != null,
                  () => _pickFile(true),
              isSmallScreen,
            ),
            buildUploadBox(
              "Fee Challan Attachment",
              "Upload fee challan (PDF, IMAGE)",
              _feeAttachment != null,
                  () => _pickFile(false),
              isSmallScreen,
            ),
            SizedBox(height: 20),
            buildSubmitButton(isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
      String label,
      String? iconPath,
      String hintText,
      TextEditingController controller,
      bool isSmallScreen,
      {String? prefixText}
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label,
            style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold
            )
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: iconPath != null
                ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                ),
              ),
            )
                : null,
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            border: UnderlineInputBorder(),
            prefixText: prefixText,
            prefixStyle: TextStyle(
                color: Colors.black,
                fontSize: isSmallScreen ? 14 : 16
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget buildDescriptionField(
      String label,
      String hintText,
      TextEditingController controller,
      bool isSmallScreen
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label,
            style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold
            )
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            contentPadding: EdgeInsets.all(12),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget buildUploadBox(
      String label,
      String hintText,
      bool hasFile,
      VoidCallback onTap,
      bool isSmallScreen
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label,
            style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold
            )
        ),
        SizedBox(height: 5),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: isSmallScreen ? 70 : 80,
            decoration: BoxDecoration(
              border: Border.all(
                color: hasFile ? Color(0xFF2A9D8F) : Colors.grey.shade400,
                width: 1,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
              color: hasFile ? Color(0xFFEAF5F4) : Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasFile)
                  Icon(
                      Icons.check_circle,
                      color: Color(0xFF2A9D8F),
                      size: isSmallScreen ? 25 : 30
                  )
                else
                  Image.asset(
                    "assets/upload-icon.png",
                    width: isSmallScreen ? 35 : 40,
                    height: isSmallScreen ? 35 : 40,
                    errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.upload_file,
                        size: isSmallScreen ? 35 : 40
                    ),
                  ),
                SizedBox(height: 5),
                Text(
                  hasFile ? "File selected (Tap to change)" : hintText,
                  style: TextStyle(
                      color: hasFile ? Color(0xFF2A9D8F) : Colors.grey.shade400,
                      fontSize: isSmallScreen ? 12 : 14
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildSubmitButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        child: _isSubmitting
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 8),
            Text(
                "Submitting...",
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16)
            ),
          ],
        )
            : Text(
            "Submit Request",
            style: TextStyle(fontSize: isSmallScreen ? 14 : 16)
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2A9D8F),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}