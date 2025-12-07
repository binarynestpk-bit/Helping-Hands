import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:helpinghand/services/auth_service.dart'; // ADDED FOR AUTHENTICATION CHECK
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class BloodForm extends StatefulWidget {
  @override
  _BloodFormState createState() => _BloodFormState();
}

class _BloodFormState extends State<BloodForm> {
  bool _isLoading = false;

  // Dropdown values
  String? _selectedBloodGroup;
  String? _selectedCaseType;
  String? _selectedUrgencyLevel;

  // Text controllers
  final _patientNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _requiredDateController = TextEditingController();
  final _bloodUnitsController = TextEditingController();
  final _additionalDetailsController = TextEditingController();

  // Location variables
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedAddress;
  String? _selectedPlaceName;
  GoogleMapController? _mapController;

  // Lists for dropdown options
  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];
  final List<String> _caseTypes = [
    'Baby Delivery', 'Accident Injury', 'Surgery', 'Others'
  ];
  final List<String> _urgencyLevels = [
    'Urgent', 'Normal', 'Low'
  ];

  @override
  void dispose() {
    _patientNameController.dispose();
    _mobileNumberController.dispose();
    _hospitalNameController.dispose();
    _locationController.dispose();
    _requiredDateController.dispose();
    _bloodUnitsController.dispose();
    _additionalDetailsController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (_patientNameController.text.isEmpty ||
        _mobileNumberController.text.isEmpty ||
        _hospitalNameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _requiredDateController.text.isEmpty ||
        _bloodUnitsController.text.isEmpty ||
        _selectedBloodGroup == null ||
        _selectedCaseType == null ||
        _selectedUrgencyLevel == null) {

      _showSnackBar('Please fill in all required fields', isError: true);
      return false;
    }
    return true;
  }

  // FIXED SUBMIT FUNCTION WITH AUTHENTICATION
  Future<void> _submitBloodRequest() async {
    // AUTHENTICATION CHECK - ADDED
    if (!AuthService.isLoggedIn()) {
      _showSnackBar('Please login to submit a blood request', isError: true);
      // Navigate to login after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/signin');
      });
      return;
    }

    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> requestData = {
        'patient_name': _patientNameController.text.trim(),
        'blood_group': _selectedBloodGroup,
        'hospital_name': _hospitalNameController.text.trim(),
        'location': _locationController.text.trim(),
        'mobile_number': _mobileNumberController.text.trim(),
        'case_type': _selectedCaseType,
        'urgency_level': _selectedUrgencyLevel,
        'required_date': _requiredDateController.text.trim(),
        'blood_units': int.parse(_bloodUnitsController.text.trim()),
        'additional_details': _additionalDetailsController.text.trim(),
      };

      // Add location data if selected
      if (_selectedLatitude != null && _selectedLongitude != null) {
        requestData['latitude'] = _selectedLatitude;
        requestData['longitude'] = _selectedLongitude;
        requestData['map_address'] = _selectedAddress;
        requestData['place_name'] = _selectedPlaceName;
      }

      // THE FIX: Added includeAuth: true to the API call
      final response = await ApiService.post('/blood/requests', requestData, includeAuth: true);

      if (response['success'] == true) {
        _showSnackBar('Blood request submitted successfully! Please wait for admin approval.');

        // Navigate to blood requests list after 2 seconds
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/blood-requests-list');
        });
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
      } else if (errorMessage.contains('Network error')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }

      _showSnackBar('Error: $errorMessage', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }

  // Location picker methods
  Future<void> _showLocationPicker() async {
    // Request location permission
    PermissionStatus permission = await Permission.location.request();

    if (!permission.isGranted) {
      _showSnackBar('Location permission is required to select location', isError: true);
      return;
    }

    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Show map dialog
      showDialog(
        context: context,
        builder: (context) => _buildLocationPickerDialog(position),
      );
    } catch (e) {
      _showSnackBar('Error getting current location: ${e.toString()}', isError: true);
    }
  }

  Widget _buildLocationPickerDialog(Position currentPosition) {
    LatLng initialPosition = LatLng(currentPosition.latitude, currentPosition.longitude);
    LatLng selectedPosition = initialPosition;
    Set<Marker> markers = {};

    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Select Hospital Location'),
        content: Container(
          height: 400,
          width: 300,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onTap: (LatLng position) async {
              setState(() {
                selectedPosition = position;
                markers = {
                  Marker(
                    markerId: MarkerId('selected_location'),
                    position: position,
                    infoWindow: InfoWindow(title: 'Selected Location'),
                  ),
                };
              });

              // Get address from coordinates
              try {
                List<Placemark> placemarks = await placemarkFromCoordinates(
                  position.latitude,
                  position.longitude,
                );

                if (placemarks.isNotEmpty) {
                  Placemark place = placemarks[0];
                  String address = '${place.street}, ${place.locality}, ${place.country}';
                  String placeName = place.name ?? 'Selected Location';

                  setState(() {
                    _selectedAddress = address;
                    _selectedPlaceName = placeName;
                  });
                }
              } catch (e) {
                print('Error getting address: $e');
              }
            },
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedLatitude = selectedPosition.latitude;
                _selectedLongitude = selectedPosition.longitude;
              });
              Navigator.pop(context);
              _showSnackBar('Location selected successfully!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE01219)),
            child: Text('Select This Location', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: RichText(
            text: TextSpan(
              text: 'Request ',
              style: TextStyle(
                  fontSize: ResponsiveHelper.responsiveHeadingSize(context),
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              ),
              children: [
                TextSpan(
                  text: 'Blood',
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
          padding: ResponsiveHelper.responsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField(
                  "Patient Name",
                  "Enter Patient Name",
                  "assets/r-medical.png",
                  _patientNameController,
                  context
              ),
              buildTextField(
                  "Mobile Number",
                  "Enter Your Phone Number",
                  "assets/r-call.png",
                  _mobileNumberController,
                  context,
                  prefixText: "+92 "
              ),
              buildDropdownField(
                  "Required Blood Group",
                  _bloodGroups,
                  _selectedBloodGroup,
                      (value) {
                    setState(() {
                      _selectedBloodGroup = value;
                    });
                  },
                  "Select Blood Group",
                  "assets/r-blood-type.png",
                  context
              ),
              buildTextField(
                  "Hospital Name",
                  "e.g., City Hospital",
                  "assets/r-hospital.png",
                  _hospitalNameController,
                  context
              ),

              // Location Picker Field (NEW)
              buildLocationField(context),

              buildTextField(
                  "Location",
                  "e.g., Peshawar",
                  "assets/r-pin.png",
                  _locationController,
                  context
              ),
              buildDropdownField(
                  "Case Type",
                  _caseTypes,
                  _selectedCaseType,
                      (value) {
                    setState(() {
                      _selectedCaseType = value;
                    });
                  },
                  "Select Case Type",
                  "assets/r-medical-report.png",
                  context
              ),
              buildTextField(
                  "Required Date",
                  "Enter required date (e.g., 2025-06-20)",
                  "assets/r-calendar.png",
                  _requiredDateController,
                  context
              ),
              buildDropdownField(
                  "Urgency Level",
                  _urgencyLevels,
                  _selectedUrgencyLevel,
                      (value) {
                    setState(() {
                      _selectedUrgencyLevel = value;
                    });
                  },
                  "Select Option",
                  null,
                  context
              ),
              buildTextField(
                  "Blood Units Needed",
                  "e.g., 2 Units",
                  null,
                  _bloodUnitsController,
                  context
              ),
              buildTextField(
                  "Additional Details",
                  "Any additional information",
                  null,
                  _additionalDetailsController,
                  context
              ),
              SizedBox(height: 20),
              buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLocationField(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            "Hospital Location (Optional)",
            style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold
            )
        ),
        SizedBox(height: 5),
        GestureDetector(
          onTap: _showLocationPicker,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _selectedAddress ?? 'Tap to select hospital location on map',
                    style: TextStyle(
                      color: _selectedAddress != null ? Colors.black : Colors.grey.shade400,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
                Icon(Icons.map, color: Color(0xFFE01219)),
              ],
            ),
          ),
        ),
        if (_selectedAddress != null) ...[
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Location: ${_selectedPlaceName ?? "Selected"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedLatitude = null;
                    _selectedLongitude = null;
                    _selectedAddress = null;
                    _selectedPlaceName = null;
                  });
                },
                child: Text('Remove', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ],
          ),
        ],
        SizedBox(height: 15),
      ],
    );
  }

  Widget buildTextField(
      String label,
      String hintText,
      String? assetIcon,
      TextEditingController controller,
      BuildContext context,
      {String? prefixText}
      ) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

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
            prefixIcon: assetIcon != null
                ? Padding(
              padding: EdgeInsets.only(left: 0, right: 12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: Image.asset(
                  assetIcon,
                  fit: BoxFit.contain,
                  color: Colors.red,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.red),
                ),
              ),
            )
                : null,
            prefixIconConstraints: BoxConstraints(
              minWidth: 36,
              minHeight: 24,
            ),
            hintText: hintText,
            hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: isSmallScreen ? 12 : 14
            ),
            border: UnderlineInputBorder(),
            prefixText: prefixText,
            prefixStyle: TextStyle(
                color: Colors.black,
                fontSize: isSmallScreen ? 14 : 16
            ),
            contentPadding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 0
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget buildDropdownField(
      String label,
      List<String> items,
      String? selectedValue,
      Function(String?) onChanged,
      String hintText,
      String? assetIcon,
      BuildContext context
      ) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

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
        DropdownButtonFormField<String>(
          value: selectedValue,
          hint: Text(
              hintText,
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: isSmallScreen ? 12 : 14
              )
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: assetIcon != null
                ? Padding(
              padding: EdgeInsets.only(left: 0, right: 12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: Image.asset(
                  assetIcon,
                  fit: BoxFit.contain,
                  color: Colors.red,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.red),
                ),
              ),
            )
                : null,
            prefixIconConstraints: BoxConstraints(
              minWidth: 36,
              minHeight: 24,
            ),
            border: UnderlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          ),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, size: isSmallScreen ? 20 : 24),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitBloodRequest,
        child: _isLoading
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
            SizedBox(width: 10),
            Text("Submitting..."),
          ],
        )
            : Text(
            "Submit Request",
            style: TextStyle(
                fontSize: ResponsiveHelper.responsiveTextSize(context)
            )
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}