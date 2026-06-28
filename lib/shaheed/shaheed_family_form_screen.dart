// lib/shaheed/shaheed_family_form_screen.dart - COMPLETE CORRECTED VERSION
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helpinghand/widgets/phone_input_field.dart';

class RequestShuhadaSupportScreen extends StatefulWidget {
  @override
  _RequestShuhadaSupportScreenState createState() => _RequestShuhadaSupportScreenState();
}

class _RequestShuhadaSupportScreenState extends State<RequestShuhadaSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // CORRECTED Form controllers to match database fields exactly
  final _familyNameController = TextEditingController();        // Maps to family_name
  final _fatherNameController = TextEditingController();        // Maps to father_name
  final _addressController = TextEditingController();           // Maps to address
  final _mobileController = TextEditingController();            // Maps to mobile_number
  final _childrenCountController = TextEditingController();     // Maps to children_count
  final _boysCountController = TextEditingController();         // Maps to boys_count
  final _girlsCountController = TextEditingController();        // Maps to girls_count
  final _childrenAgesController = TextEditingController();      // Maps to children_ages
  final _shahadatPlaceController = TextEditingController();     // Maps to shahadat_place
  final _shahadatDescriptionController = TextEditingController(); // Maps to shahadat_description
  final _monthlyNeedController = TextEditingController();       // Maps to monthly_need
  final _videoLinkController = TextEditingController();         // Maps to video_link

  // Full E.164 mobile (dial code + number) kept in sync by PhoneInputField.
  String _fullMobile = '+92';

  String? maritalStatus;
  DateTime _selectedShahadatDate = DateTime.now().subtract(Duration(days: 365));
  File? _selectedPhoto;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _familyNameController.dispose();
    _fatherNameController.dispose();
    _addressController.dispose();
    _mobileController.dispose();
    _childrenCountController.dispose();
    _boysCountController.dispose();
    _girlsCountController.dispose();
    _childrenAgesController.dispose();
    _shahadatPlaceController.dispose();
    _shahadatDescriptionController.dispose();
    _monthlyNeedController.dispose();
    _videoLinkController.dispose();
    super.dispose();
  }

  Future<void> _selectShahadatDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedShahadatDate,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedShahadatDate) {
      setState(() {
        _selectedShahadatDate = picked;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 40, maxWidth: 1024, maxHeight: 1024);
    if (picked != null) {
      setState(() { _selectedPhoto = File(picked.path); });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // CORRECTED: Map to your exact database column names
      final requestData = {
        'family_name': _familyNameController.text.trim(),
        'father_name': _fatherNameController.text.trim(),
        'address': _addressController.text.trim(),
        'mobile_number': _fullMobile,
        'marital_status': maritalStatus, // Will be 'Yes' or 'No'
        'children_count': maritalStatus == "Yes" && _childrenCountController.text.isNotEmpty
            ? int.parse(_childrenCountController.text) : 0,
        'boys_count': maritalStatus == "Yes" && _boysCountController.text.isNotEmpty
            ? int.parse(_boysCountController.text) : 0,
        'girls_count': maritalStatus == "Yes" && _girlsCountController.text.isNotEmpty
            ? int.parse(_girlsCountController.text) : 0,
        'children_ages': maritalStatus == "Yes" ? _childrenAgesController.text.trim() : null,
        'shahadat_date': _selectedShahadatDate.toIso8601String().split('T')[0],
        'shahadat_place': _shahadatPlaceController.text.trim(),
        'shahadat_description': _shahadatDescriptionController.text.trim(),
        'monthly_need': double.parse(_monthlyNeedController.text.isNotEmpty
            ? _monthlyNeedController.text : "50000"),
        'video_link': _videoLinkController.text.trim().isNotEmpty
            ? _videoLinkController.text.trim() : null,
      };

      print('ðŸ“¦ Sending corrected request data: $requestData');

      Map<String, dynamic> response;

      if (_selectedPhoto != null) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token') ?? '';
        final uri = Uri.parse('${ApiService.baseUrl}/family/requests');
        final req = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..files.add(await http.MultipartFile.fromPath('photo_attachment', _selectedPhoto!.path));
        requestData.forEach((k, v) { if (v != null) req.fields[k] = v.toString(); });
        final streamed = await req.send();
        final body = await streamed.stream.bytesToString();
        try {
          response = jsonDecode(body) as Map<String, dynamic>;
        } catch (_) {
          if (streamed.statusCode == 413) {
            throw Exception('Photo is too large. Please select a smaller image.');
          }
          throw Exception('Server error (${streamed.statusCode}). Please try again without a photo.');
        }
      } else {
        response = await ApiService.createFamilyRequest(requestData);
      }

      if (response['success'] == true) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(response['message'] ?? 'Failed to submit request');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Request Submitted'),
          ],
        ),
        content: Text(
          'Your family support request has been submitted successfully! '
              'Please wait for admin verification and approval.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                    (route) => false,
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
            Text('Error'),
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

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Request Shuhada ',
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF2A9D8F)))
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 10
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField("Family Name", "Enter Family/Martyr Name", "assets/user.png",
                  isSmallScreen, _familyNameController, required: true),
              buildTextField("Father's Name", "Enter Your Father's Name", "assets/user.png",
                  isSmallScreen, _fatherNameController, required: true),
              buildTextField("Address", "Enter Complete Address", "assets/institution.png",
                  isSmallScreen, _addressController, required: true),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: PhoneInputField(
                  controller: _mobileController,
                  isSmallScreen: isSmallScreen,
                  onChanged: (value) => _fullMobile = value,
                ),
              ),
              buildDropdownField("Marital Status", ["Yes", "No"], (value) {
                setState(() {
                  maritalStatus = value;
                });
              }, isSmallScreen),

              if (maritalStatus == "Yes") ...[
                buildTextField("Number of Children", "Enter Number", "assets/user.png",
                    isSmallScreen, _childrenCountController, keyboardType: TextInputType.number),
                buildTextField("Number of Boys", "Enter Number", "assets/user.png",
                    isSmallScreen, _boysCountController, keyboardType: TextInputType.number),
                buildTextField("Number of Girls", "Enter Number", "assets/user.png",
                    isSmallScreen, _girlsCountController, keyboardType: TextInputType.number),
                buildTextField("Age of Children", "Enter ages (e.g., 5, 7, 9)", "assets/user.png",
                    isSmallScreen, _childrenAgesController),
              ],

              buildDateField("Date of Shahadat", isSmallScreen),
              buildTextField("Place of Shahadat", "Enter Place", "assets/institution.png",
                  isSmallScreen, _shahadatPlaceController, required: true),
              buildTextField("Monthly Need", "Enter monthly need amount", "assets/money.png",
                  isSmallScreen, _monthlyNeedController, keyboardType: TextInputType.number, required: true),
              buildDescriptionField("Description of Current Situation", isSmallScreen),
              buildUploadBox("Photo Attachment", "Upload photo Incident, Janaza", isSmallScreen),
              buildTextField("Video Link", "Video Link (Youtube/Facebook)", "assets/attach.png",
                  isSmallScreen, _videoLinkController),
              SizedBox(height: 20),
              buildSubmitButton(isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label,
      String hintText,
      String assetIcon,
      bool isSmallScreen,
      TextEditingController controller,
      {String? prefixText, bool required = false, TextInputType keyboardType = TextInputType.text}
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label + (required ? ' *' : ''),
            style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold
            )
        ),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: Image.asset(assetIcon, fit: BoxFit.contain),
              ),
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            border: UnderlineInputBorder(),
            prefixText: prefixText,
            prefixStyle: TextStyle(
              color: Colors.black,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
          validator: (value) {
            if (required && (value == null || value.trim().isEmpty)) {
              return '$label is required';
            }

            // Field-specific validation
            if (label.contains('Family Name') && value != null && value.isNotEmpty) {
              if (value.trim().length < 2 || value.trim().length > 255) {
                return 'Family name must be between 2 and 255 characters';
              }
            }

            if (label.contains('Father') && value != null && value.isNotEmpty) {
              if (value.trim().length < 2 || value.trim().length > 255) {
                return 'Father name must be between 2 and 255 characters';
              }
            }

            if (label.contains('Place') && value != null && value.isNotEmpty) {
              if (value.trim().length < 2 || value.trim().length > 255) {
                return 'Place must be between 2 and 255 characters';
              }
            }

            if (label.contains('Mobile') && value != null && value.isNotEmpty) {
              // REMOVED ALL CONSTRAINTS - just check if not empty
              if (value.trim().isEmpty) {
                return 'Mobile number is required';
              }
            }

            if (label.contains('Monthly Need') && value != null && value.isNotEmpty) {
              final amount = double.tryParse(value);
              if (amount == null) {
                return 'Please enter a valid amount';
              }
              if (amount < 1000 || amount > 500000) {
                return 'Monthly need must be between PKR 1,000 and PKR 500,000';
              }
            }

            // Apply number range validation only to count fields, not amount fields
            if (keyboardType == TextInputType.number && value != null && value.isNotEmpty &&
                !label.contains('Monthly Need')) {
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              final number = int.parse(value);
              if (number < 0 || number > 20) {
                return 'Value must be between 0 and 20';
              }
            }

            return null;
          },
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget buildDateField(String label, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            '$label *',
            style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold
            )
        ),
        SizedBox(height: 5),
        InkWell(
          onTap: _selectShahadatDate,
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset("assets/schedule.png", fit: BoxFit.contain),
                ),
              ),
              border: UnderlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              '${_selectedShahadatDate.day}/${_selectedShahadatDate.month}/${_selectedShahadatDate.year}',
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget buildDropdownField(
      String label,
      List<String> options,
      ValueChanged<String?> onChanged,
      bool isSmallScreen,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            '$label *',
            style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold
            )
        ),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: maritalStatus,
          items: options.map((option) =>
              DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  )
              )
          ).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, size: isSmallScreen ? 24 : 30),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            return null;
          },
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget buildDescriptionField(String label, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            '$label *',
            style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold
            )
        ),
        SizedBox(height: 5),
        TextFormField(
          controller: _shahadatDescriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Describe your current situation and needs in detail (minimum 50 characters)",
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            contentPadding: EdgeInsets.all(12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label is required';
            }
            if (value.trim().length < 50) {
              return 'Please provide at least 50 characters';
            }
            if (value.trim().length > 2000) {
              return 'Description must be less than 2000 characters';
            }
            return null;
          },
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget buildUploadBox(String label, String hintText, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        GestureDetector(
          onTap: _pickPhoto,
          child: Container(
            width: double.infinity,
            height: isSmallScreen ? 80 : 100,
            decoration: BoxDecoration(
              border: Border.all(color: _selectedPhoto != null ? Color(0xFF2A9D8F) : Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
              color: _selectedPhoto != null ? Color(0xFF2A9D8F).withOpacity(0.05) : null,
            ),
            child: _selectedPhoto != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF2A9D8F), size: 28),
                      SizedBox(width: 8),
                      Flexible(child: Text(_selectedPhoto!.path.split('/').last, style: TextStyle(color: Color(0xFF2A9D8F), fontSize: 13), overflow: TextOverflow.ellipsis)),
                      SizedBox(width: 8),
                      GestureDetector(onTap: () => setState(() => _selectedPhoto = null), child: Icon(Icons.close, color: Colors.red, size: 20)),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file, color: Colors.grey, size: isSmallScreen ? 32 : 40),
                      SizedBox(height: 5),
                      Text(hintText, style: TextStyle(color: Color(0xFF9C9C9C), fontSize: isSmallScreen ? 12 : 14)),
                      Text('Tap to select', style: TextStyle(color: Color(0xFF2A9D8F), fontSize: 11)),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildSubmitButton(bool isSmallScreen) {
    return Center(
      child: ElevatedButton(
        onPressed: _submitRequest,
        child: Text(
          "Submit",
          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2A9D8F),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 30 : 40,
              vertical: isSmallScreen ? 12 : 15
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

