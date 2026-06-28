import 'package:flutter/material.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:helpinghand/widgets/phone_input_field.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EditProfileScreen({Key? key, this.userData}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _fullNameController;
  late TextEditingController _fatherNameController;
  late TextEditingController _cityController;
  late TextEditingController _currentAddressController;
  late TextEditingController _permanentAddressController;
  late TextEditingController _phoneController;

  // Full E.164 mobile (dial code + number) kept in sync by PhoneInputField.
  String _fullMobile = '+92';
  String _initialDialCode = '+92';

  String? _selectedBloodGroup;
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.userData?['full_name'] ?? '');
    _fatherNameController = TextEditingController(text: widget.userData?['father_name'] ?? '');
    _cityController = TextEditingController(text: widget.userData?['city'] ?? '');
    _currentAddressController = TextEditingController(text: widget.userData?['current_address'] ?? '');
    _permanentAddressController = TextEditingController(text: widget.userData?['permanent_address'] ?? '');
    final existingPhone = (widget.userData?['phone'] ?? '').toString();
    final split = PhoneInputField.split(existingPhone);
    _initialDialCode = split.$1;
    _phoneController = TextEditingController(text: split.$2);
    _fullMobile = existingPhone.isNotEmpty ? existingPhone : _initialDialCode;
    _selectedBloodGroup = widget.userData?['blood_group'];
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _fatherNameController.dispose();
    _cityController.dispose();
    _currentAddressController.dispose();
    _permanentAddressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'full_name': _fullNameController.text.trim(),
        'father_name': _fatherNameController.text.trim(),
        'city': _cityController.text.trim(),
        'current_address': _currentAddressController.text.trim(),
        'permanent_address': _permanentAddressController.text.trim(),
        'phone': _fullMobile,
        if (_selectedBloodGroup != null) 'blood_group': _selectedBloodGroup,
      };

      final response = await ApiService.put('/user/profile', data);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF2A9D8F),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _fatherNameController,
                label: 'Father Name',
                icon: Icons.supervisor_account,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _cityController,
                label: 'City',
                icon: Icons.location_city,
              ),
              SizedBox(height: 16),
              PhoneInputField(
                controller: _phoneController,
                initialDialCode: _initialDialCode,
                label: 'Phone',
                onChanged: (value) => _fullMobile = value,
              ),
              SizedBox(height: 16),
              _buildBloodGroupDropdown(),
              SizedBox(height: 16),
              _buildTextField(
                controller: _currentAddressController,
                label: 'Current Address',
                icon: Icons.home,
                maxLines: 2,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _permanentAddressController,
                label: 'Permanent Address',
                icon: Icons.location_on,
                maxLines: 2,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2A9D8F),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF2A9D8F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2A9D8F), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget _buildBloodGroupDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodGroup,
      decoration: InputDecoration(
        labelText: 'Blood Group',
        prefixIcon: Icon(Icons.bloodtype, color: Color(0xFF2A9D8F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2A9D8F), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _bloodGroups.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedBloodGroup = newValue;
        });
      },
    );
  }
}
