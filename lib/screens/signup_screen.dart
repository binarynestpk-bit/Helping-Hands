// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
// import 'package:helpinghand/screens/verify_phone_screen.dart'; // TODO: re-enable with SMS
import 'package:helpinghand/screens/email_verification_screen.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:helpinghand/utils/responsive_helper.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isChecked = false;
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedCity;
  String _selectedCountryCode = '+92';
  String _selectedCountryFlag = '🇵🇰';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.post('/auth/register', {
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': '$_selectedCountryCode${_phoneController.text.trim()}',
        'password': _passwordController.text,
        'city': _selectedCity,
      });

      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        // TODO: Re-enable phone OTP when SMS is production-ready
        // VerifyPhoneScreen(mode: 'signup', phone: '$_selectedCountryCode${_phoneController.text.trim()}', ...)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(
              email: _emailController.text.trim(),
              userName: _nameController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = e.toString();
      if (errorMessage.contains('User already exists')) {
        errorMessage = 'An account with this email or phone already exists';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validateInputs() {
    // Basic validation
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return false;
    }

    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return false;
    }

    // Check terms acceptance
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please accept the Terms & Conditions')),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.04
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Create ',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A9D8F),
                    ),
                    children: [
                      TextSpan(
                        text: 'New Account',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 5),
              Center(
                child: Text(
                  'Sign up to get started',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Color(0xFF797979),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              buildTextField(
                'Full Name',
                'assets/user.png',
                controller: _nameController,
                isSmallScreen: isSmallScreen,
              ),
              buildTextField(
                'Email Address',
                'assets/sms-tracking.png',
                controller: _emailController,
                isSmallScreen: isSmallScreen,
              ),
              buildPhoneField(isSmallScreen: isSmallScreen),
              buildPasswordField(
                'Password',
                'assets/lock.png',
                isConfirmPassword: false,
                isSmallScreen: isSmallScreen,
              ),
              buildPasswordField(
                'Confirm Password',
                'assets/lock.png',
                isConfirmPassword: true,
                isSmallScreen: isSmallScreen,
              ),
              buildCountryField(isSmallScreen: isSmallScreen),
              SizedBox(height: 10),

              // Checkbox functionality
              Row(
                children: [
                  Transform.scale(
                    scale: isSmallScreen ? 0.9 : 1.0,
                    child: Checkbox(
                      value: _isChecked,
                      activeColor: Color(0xFF2A9D8F),
                      onChanged: (bool? value) {
                        setState(() {
                          _isChecked = value!;
                        });
                      },
                    ),
                  ),
                  Text(
                    'I agree with ',
                    style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Show terms & conditions
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Text(
                              'This is a sample terms and conditions text. In a real app, this would contain the actual terms and conditions of your service.',
                              style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Close',
                                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        color: Color(0xFF2A9D8F),
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2A9D8F),
                    minimumSize: Size(double.infinity, isSmallScreen ? 45 : 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: (_isChecked && !_isLoading) ? _handleSignUp : null,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Continue',
                          style: TextStyle(fontSize: isSmallScreen ? 16 : 18, color: Colors.white),
                        ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/signin');
                      },
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          color: Color(0xFF2A9D8F),
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const List<Map<String, String>> _countryCodes = [
    {'flag': '🇵🇰', 'code': '+92', 'name': 'Pakistan'},
    {'flag': '🇦🇪', 'code': '+971', 'name': 'UAE'},
    {'flag': '🇸🇦', 'code': '+966', 'name': 'Saudi Arabia'},
    {'flag': '🇺🇸', 'code': '+1', 'name': 'United States'},
    {'flag': '🇬🇧', 'code': '+44', 'name': 'United Kingdom'},
    {'flag': '🇮🇳', 'code': '+91', 'name': 'India'},
    {'flag': '🇧🇩', 'code': '+880', 'name': 'Bangladesh'},
    {'flag': '🇦🇫', 'code': '+93', 'name': 'Afghanistan'},
    {'flag': '🇦🇱', 'code': '+355', 'name': 'Albania'},
    {'flag': '🇩🇿', 'code': '+213', 'name': 'Algeria'},
    {'flag': '🇦🇴', 'code': '+244', 'name': 'Angola'},
    {'flag': '🇦🇷', 'code': '+54', 'name': 'Argentina'},
    {'flag': '🇦🇲', 'code': '+374', 'name': 'Armenia'},
    {'flag': '🇦🇺', 'code': '+61', 'name': 'Australia'},
    {'flag': '🇦🇹', 'code': '+43', 'name': 'Austria'},
    {'flag': '🇦🇿', 'code': '+994', 'name': 'Azerbaijan'},
    {'flag': '🇧🇭', 'code': '+973', 'name': 'Bahrain'},
    {'flag': '🇧🇾', 'code': '+375', 'name': 'Belarus'},
    {'flag': '🇧🇪', 'code': '+32', 'name': 'Belgium'},
    {'flag': '🇧🇷', 'code': '+55', 'name': 'Brazil'},
    {'flag': '🇧🇳', 'code': '+673', 'name': 'Brunei'},
    {'flag': '🇧🇬', 'code': '+359', 'name': 'Bulgaria'},
    {'flag': '🇨🇦', 'code': '+1', 'name': 'Canada'},
    {'flag': '🇨🇱', 'code': '+56', 'name': 'Chile'},
    {'flag': '🇨🇳', 'code': '+86', 'name': 'China'},
    {'flag': '🇨🇴', 'code': '+57', 'name': 'Colombia'},
    {'flag': '🇭🇷', 'code': '+385', 'name': 'Croatia'},
    {'flag': '🇨🇾', 'code': '+357', 'name': 'Cyprus'},
    {'flag': '🇨🇿', 'code': '+420', 'name': 'Czech Republic'},
    {'flag': '🇩🇰', 'code': '+45', 'name': 'Denmark'},
    {'flag': '🇪🇬', 'code': '+20', 'name': 'Egypt'},
    {'flag': '🇪🇹', 'code': '+251', 'name': 'Ethiopia'},
    {'flag': '🇫🇮', 'code': '+358', 'name': 'Finland'},
    {'flag': '🇫🇷', 'code': '+33', 'name': 'France'},
    {'flag': '🇩🇪', 'code': '+49', 'name': 'Germany'},
    {'flag': '🇬🇭', 'code': '+233', 'name': 'Ghana'},
    {'flag': '🇬🇷', 'code': '+30', 'name': 'Greece'},
    {'flag': '🇭🇰', 'code': '+852', 'name': 'Hong Kong'},
    {'flag': '🇭🇺', 'code': '+36', 'name': 'Hungary'},
    {'flag': '🇮🇩', 'code': '+62', 'name': 'Indonesia'},
    {'flag': '🇮🇷', 'code': '+98', 'name': 'Iran'},
    {'flag': '🇮🇶', 'code': '+964', 'name': 'Iraq'},
    {'flag': '🇮🇪', 'code': '+353', 'name': 'Ireland'},
    {'flag': '🇮🇱', 'code': '+972', 'name': 'Israel'},
    {'flag': '🇮🇹', 'code': '+39', 'name': 'Italy'},
    {'flag': '🇯🇵', 'code': '+81', 'name': 'Japan'},
    {'flag': '🇯🇴', 'code': '+962', 'name': 'Jordan'},
    {'flag': '🇰🇿', 'code': '+7', 'name': 'Kazakhstan'},
    {'flag': '🇰🇪', 'code': '+254', 'name': 'Kenya'},
    {'flag': '🇰🇼', 'code': '+965', 'name': 'Kuwait'},
    {'flag': '🇱🇧', 'code': '+961', 'name': 'Lebanon'},
    {'flag': '🇱🇾', 'code': '+218', 'name': 'Libya'},
    {'flag': '🇲🇾', 'code': '+60', 'name': 'Malaysia'},
    {'flag': '🇲🇻', 'code': '+960', 'name': 'Maldives'},
    {'flag': '🇲🇽', 'code': '+52', 'name': 'Mexico'},
    {'flag': '🇲🇦', 'code': '+212', 'name': 'Morocco'},
    {'flag': '🇳🇵', 'code': '+977', 'name': 'Nepal'},
    {'flag': '🇳🇱', 'code': '+31', 'name': 'Netherlands'},
    {'flag': '🇳🇿', 'code': '+64', 'name': 'New Zealand'},
    {'flag': '🇳🇬', 'code': '+234', 'name': 'Nigeria'},
    {'flag': '🇳🇴', 'code': '+47', 'name': 'Norway'},
    {'flag': '🇴🇲', 'code': '+968', 'name': 'Oman'},
    {'flag': '🇵🇭', 'code': '+63', 'name': 'Philippines'},
    {'flag': '🇵🇱', 'code': '+48', 'name': 'Poland'},
    {'flag': '🇵🇹', 'code': '+351', 'name': 'Portugal'},
    {'flag': '🇶🇦', 'code': '+974', 'name': 'Qatar'},
    {'flag': '🇷🇴', 'code': '+40', 'name': 'Romania'},
    {'flag': '🇷🇺', 'code': '+7', 'name': 'Russia'},
    {'flag': '🇷🇼', 'code': '+250', 'name': 'Rwanda'},
    {'flag': '🇸🇳', 'code': '+221', 'name': 'Senegal'},
    {'flag': '🇷🇸', 'code': '+381', 'name': 'Serbia'},
    {'flag': '🇸🇬', 'code': '+65', 'name': 'Singapore'},
    {'flag': '🇿🇦', 'code': '+27', 'name': 'South Africa'},
    {'flag': '🇰🇷', 'code': '+82', 'name': 'South Korea'},
    {'flag': '🇪🇸', 'code': '+34', 'name': 'Spain'},
    {'flag': '🇱🇰', 'code': '+94', 'name': 'Sri Lanka'},
    {'flag': '🇸🇩', 'code': '+249', 'name': 'Sudan'},
    {'flag': '🇸🇪', 'code': '+46', 'name': 'Sweden'},
    {'flag': '🇨🇭', 'code': '+41', 'name': 'Switzerland'},
    {'flag': '🇸🇾', 'code': '+963', 'name': 'Syria'},
    {'flag': '🇹🇼', 'code': '+886', 'name': 'Taiwan'},
    {'flag': '🇹🇿', 'code': '+255', 'name': 'Tanzania'},
    {'flag': '🇹🇭', 'code': '+66', 'name': 'Thailand'},
    {'flag': '🇹🇳', 'code': '+216', 'name': 'Tunisia'},
    {'flag': '🇹🇷', 'code': '+90', 'name': 'Turkey'},
    {'flag': '🇺🇬', 'code': '+256', 'name': 'Uganda'},
    {'flag': '🇺🇦', 'code': '+380', 'name': 'Ukraine'},
    {'flag': '🇬🇧', 'code': '+44', 'name': 'United Kingdom'},
    {'flag': '🇺🇿', 'code': '+998', 'name': 'Uzbekistan'},
    {'flag': '🇻🇳', 'code': '+84', 'name': 'Vietnam'},
    {'flag': '🇾🇪', 'code': '+967', 'name': 'Yemen'},
    {'flag': '🇿🇲', 'code': '+260', 'name': 'Zambia'},
    {'flag': '🇿🇼', 'code': '+263', 'name': 'Zimbabwe'},
  ];

  Widget buildPhoneField({required bool isSmallScreen}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Country code dropdown
            GestureDetector(
              onTap: () => _showCountryPicker(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFECECEC))),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_selectedCountryFlag,
                        style: TextStyle(fontSize: isSmallScreen ? 18 : 22)),
                    const SizedBox(width: 4),
                    Text(_selectedCountryCode,
                        style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 15,
                            fontWeight: FontWeight.w600)),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Phone number input
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone number',
                  hintStyle: TextStyle(
                    color: const Color(0xFF9C9C9C),
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFECECEC)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showCountryPicker() {
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          final filtered = searchQuery.isEmpty
              ? _countryCodes
              : _countryCodes
                  .where((c) =>
                      c['name']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      c['code']!.contains(searchQuery))
                  .toList();
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 12),
                const Text('Select Country Code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search country...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                    ),
                    onChanged: (v) => setModalState(() => searchQuery = v),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final c = filtered[i];
                      final isSelected = c['code'] == _selectedCountryCode &&
                          c['flag'] == _selectedCountryFlag;
                      return ListTile(
                        leading: Text(c['flag']!,
                            style: const TextStyle(fontSize: 24)),
                        title: Text(c['name']!),
                        trailing: Text(c['code']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2A9D8F))),
                        selected: isSelected,
                        selectedTileColor:
                            const Color(0xFF2A9D8F).withOpacity(0.08),
                        onTap: () {
                          setState(() {
                            _selectedCountryCode = c['code']!;
                            _selectedCountryFlag = c['flag']!;
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget buildTextField(
      String label,
      String iconPath, {
        required TextEditingController controller,
        bool isPassword = false,
        String prefixText = '',
        required bool isSmallScreen,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            prefixText: prefixText,
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.0),
              child: Image.asset(
                  iconPath,
                  width: isSmallScreen ? 18 : 20,
                  height: isSmallScreen ? 18 : 20
              ),
            ),
            hintText: 'Enter Your $label',
            hintStyle: TextStyle(
              color: Color(0xFF9C9C9C),
              fontSize: isSmallScreen ? 12 : 14,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFECECEC)),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildPasswordField(
      String label,
      String iconPath, {
        required bool isConfirmPassword,
        required bool isSmallScreen,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
        SizedBox(height: 5),
        TextField(
          controller: isConfirmPassword ? _confirmPasswordController : _passwordController,
          obscureText: isConfirmPassword ? _obscureConfirmPassword : _obscurePassword,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.0),
              child: Image.asset(
                  iconPath,
                  width: isSmallScreen ? 18 : 20,
                  height: isSmallScreen ? 18 : 20
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isConfirmPassword
                    ? (_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility)
                    : (_obscurePassword ? Icons.visibility_off : Icons.visibility),
                color: Color(0xFF9C9C9C),
                size: isSmallScreen ? 18 : 20,
              ),
              onPressed: () {
                setState(() {
                  if (isConfirmPassword) {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  } else {
                    _obscurePassword = !_obscurePassword;
                  }
                });
              },
            ),
            hintText: 'Enter Your $label',
            hintStyle: TextStyle(
              color: Color(0xFF9C9C9C),
              fontSize: isSmallScreen ? 12 : 14,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFECECEC)),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  static const List<String> _allCountries = [
    'Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola', 'Antigua and Barbuda',
    'Argentina', 'Armenia', 'Australia', 'Austria', 'Azerbaijan', 'Bahamas', 'Bahrain',
    'Bangladesh', 'Barbados', 'Belarus', 'Belgium', 'Belize', 'Benin', 'Bhutan',
    'Bolivia', 'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei', 'Bulgaria',
    'Burkina Faso', 'Burundi', 'Cabo Verde', 'Cambodia', 'Cameroon', 'Canada',
    'Central African Republic', 'Chad', 'Chile', 'China', 'Colombia', 'Comoros',
    'Congo', 'Costa Rica', 'Croatia', 'Cuba', 'Cyprus', 'Czech Republic', 'Denmark',
    'Djibouti', 'Dominica', 'Dominican Republic', 'Ecuador', 'Egypt', 'El Salvador',
    'Equatorial Guinea', 'Eritrea', 'Estonia', 'Eswatini', 'Ethiopia', 'Fiji',
    'Finland', 'France', 'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana', 'Greece',
    'Grenada', 'Guatemala', 'Guinea', 'Guinea-Bissau', 'Guyana', 'Haiti', 'Honduras',
    'Hungary', 'Iceland', 'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Israel',
    'Italy', 'Jamaica', 'Japan', 'Jordan', 'Kazakhstan', 'Kenya', 'Kiribati',
    'Kuwait', 'Kyrgyzstan', 'Laos', 'Latvia', 'Lebanon', 'Lesotho', 'Liberia',
    'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg', 'Madagascar', 'Malawi',
    'Malaysia', 'Maldives', 'Mali', 'Malta', 'Marshall Islands', 'Mauritania',
    'Mauritius', 'Mexico', 'Micronesia', 'Moldova', 'Monaco', 'Mongolia', 'Montenegro',
    'Morocco', 'Mozambique', 'Myanmar', 'Namibia', 'Nauru', 'Nepal', 'Netherlands',
    'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'North Korea', 'North Macedonia',
    'Norway', 'Oman', 'Pakistan', 'Palau', 'Palestine', 'Panama', 'Papua New Guinea',
    'Paraguay', 'Peru', 'Philippines', 'Poland', 'Portugal', 'Qatar', 'Romania',
    'Russia', 'Rwanda', 'Saint Kitts and Nevis', 'Saint Lucia',
    'Saint Vincent and the Grenadines', 'Samoa', 'San Marino', 'Sao Tome and Principe',
    'Saudi Arabia', 'Senegal', 'Serbia', 'Seychelles', 'Sierra Leone', 'Singapore',
    'Slovakia', 'Slovenia', 'Solomon Islands', 'Somalia', 'South Africa', 'South Korea',
    'South Sudan', 'Spain', 'Sri Lanka', 'Sudan', 'Suriname', 'Sweden', 'Switzerland',
    'Syria', 'Taiwan', 'Tajikistan', 'Tanzania', 'Thailand', 'Timor-Leste', 'Togo',
    'Tonga', 'Trinidad and Tobago', 'Tunisia', 'Turkey', 'Turkmenistan', 'Tuvalu',
    'Uganda', 'Ukraine', 'United Arab Emirates', 'United Kingdom', 'United States',
    'Uruguay', 'Uzbekistan', 'Vanuatu', 'Vatican City', 'Venezuela', 'Vietnam',
    'Yemen', 'Zambia', 'Zimbabwe',
  ];

  Widget buildCountryField({required bool isSmallScreen}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: _showCountryDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFECECEC))),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Image.asset('assets/global-search.png',
                      width: isSmallScreen ? 18 : 20,
                      height: isSmallScreen ? 18 : 20),
                ),
                Expanded(
                  child: Text(
                    _selectedCity ?? 'Select Country',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: _selectedCity == null
                          ? const Color(0xFF9C9C9C)
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showCountryDropdown() {
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          final filtered = searchQuery.isEmpty
              ? _allCountries
              : _allCountries
                  .where((c) => c.toLowerCase().contains(searchQuery.toLowerCase()))
                  .toList();
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 12),
                const Text('Select Country',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search country...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                    ),
                    onChanged: (v) => setModalState(() => searchQuery = v),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final country = filtered[i];
                      final isSelected = country == _selectedCity;
                      return ListTile(
                        title: Text(country),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Color(0xFF2A9D8F))
                            : null,
                        selected: isSelected,
                        selectedTileColor:
                            const Color(0xFF2A9D8F).withOpacity(0.08),
                        onTap: () {
                          setState(() => _selectedCity = country);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}