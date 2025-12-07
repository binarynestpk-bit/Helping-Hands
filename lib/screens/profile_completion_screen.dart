// lib/screens/profile_completion_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:helpinghand/screens/verify_phone_screen.dart';

class ProfileCompletionScreen extends StatefulWidget {
  @override
  _ProfileCompletionScreenState createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  // Controllers for text fields
  final _nameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _currentAddressController = TextEditingController();
  final _permanentAddressController = TextEditingController();

  // Image files
  File? _profileImage;
  File? _cnicFrontImage;
  File? _cnicBackImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _cnicController.dispose();
    _bloodGroupController.dispose();
    _currentAddressController.dispose();
    _permanentAddressController.dispose();
    super.dispose();
  }

  // Function to handle image selection
  Future<void> _pickImage(ImageSource source, int imageType) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          switch (imageType) {
            case 1:
              _profileImage = File(pickedFile.path);
              break;
            case 2:
              _cnicFrontImage = File(pickedFile.path);
              break;
            case 3:
              _cnicBackImage = File(pickedFile.path);
              break;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _showImagePicker(int imageType) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, imageType);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, imageType);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool _validateInputs() {
    if (_nameController.text.isEmpty ||
        _cnicController.text.isEmpty ||
        _bloodGroupController.text.isEmpty ||
        _currentAddressController.text.isEmpty ||
        _permanentAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all text fields')),
      );
      return false;
    }

    if (_profileImage == null || _cnicFrontImage == null || _cnicBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload all required images')),
      );
      return false;
    }

    // Validate CNIC format
    final cnicRegex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
    if (!cnicRegex.hasMatch(_cnicController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CNIC should be in format: 12345-6789012-3')),
      );
      return false;
    }

    return true;
  }

  void _showApprovalDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Color(0xFFEAF5F4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Color(0xFF2A9D8F),
                    size: 50,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Profile Submitted",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Your information has been uploaded and sent to the admin. You can access your account after approval.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2A9D8F),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to sign in page
                    Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/signin',
                            (route) => false
                    );
                  },
                  child: Text(
                    "Go to Login",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(""),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: RichText(
                text: TextSpan(
                  text: 'Complete ',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Your Profile',
                      style: TextStyle(color: Color(0xFF2A9D8F)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Please fill in the required information to set up your profile and start using the app.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF797979)),
              ),
            ),
            SizedBox(height: 30),

            // Input Fields
            buildTextField("Full Name", "assets/user.png", "Enter Your Full Name", _nameController),
            buildTextField("CNIC Number", "assets/identity.png", "Enter Your CNIC (E.G., 12345-6789012-3)", _cnicController),
            buildTextField("Blood Group", "assets/blood-type.png", "Enter Your Blood Group", _bloodGroupController),
            buildTextField("Current Address", "assets/pin.png", "Enter Your Current Address", _currentAddressController),
            buildTextField("Permanent Address", "assets/pin.png", "Enter Your Permanent Address", _permanentAddressController),

            SizedBox(height: 10),

            // Image Upload Sections
            buildUploadBox(
              "Photo Attachment",
              "Upload Your Photo (PNG/JPG)",
              _profileImage != null ? FileImage(_profileImage!) : null,
                  () => _showImagePicker(1),
            ),
            buildUploadBox(
              "CNIC Attachment (Front Side)",
              "Upload CNIC Front Side",
              _cnicFrontImage != null ? FileImage(_cnicFrontImage!) : null,
                  () => _showImagePicker(2),
            ),
            buildUploadBox(
              "CNIC Attachment (Back Side)",
              "Upload CNIC Back Side",
              _cnicBackImage != null ? FileImage(_cnicBackImage!) : null,
                  () => _showImagePicker(3),
            ),

            SizedBox(height: 20),

            // Complete Profile Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2A9D8F),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (_validateInputs()) {
                    // Show approval dialog instead of navigating to home
                    _showApprovalDialog(context);
                  }
                },
                child: Text(
                  'Complete Profile',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // TextField with Proper Alignment
  Widget buildTextField(String label, String iconPath, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15), // Align text properly
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12), // Adjust padding for icon
              child: Image.asset(iconPath, width: 22, height: 22),
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: 50, // Ensures icon doesn't push text away
              minHeight: 50, // Ensures proper alignment
            ),
            hintText: hintText,
            hintStyle: TextStyle(color: Color(0xFF9C9C9C)),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFECECEC)),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  // Upload Box Design
  Widget buildUploadBox(String label, String hintText, ImageProvider? backgroundImage, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 5),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(8),
              image: backgroundImage != null
                  ? DecorationImage(
                image: backgroundImage,
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: backgroundImage == null ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/upload-icon.png", width: 50, height: 50),
                SizedBox(height: 5),
                Text(
                  hintText,
                  style: TextStyle(color: Color(0xFF9C9C9C)),
                ),
              ],
            ) : null,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}