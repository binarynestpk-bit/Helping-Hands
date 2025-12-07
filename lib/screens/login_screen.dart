import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CreateAccountScreen(),
  ));
}

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _agreeToTerms = false;
  final TextEditingController phoneController = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'PK');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    "Create New Account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Sign up to get started",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF797979),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Full Name
                _buildInputField(
                  label: "Full Name",
                  hint: "Enter Your Full Name",
                  icon: Icons.person_outline,
                ),

                // Email Address
                _buildInputField(
                  label: "Email Address",
                  hint: "Enter Your Email",
                  icon: Icons.email_outlined,
                ),

                // Mobile Number
                const SizedBox(height: 16),
                const Text(
                  "Mobile Number",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFECECEC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      setState(() {
                        this.number = number;
                      });
                    },
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.DROPDOWN,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    initialValue: number,
                    textFieldController: phoneController,
                    inputDecoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Your Phone Number",
                      hintStyle: TextStyle(color: Color(0xFF797979)),
                    ),
                  ),
                ),

                // Password
                _buildPasswordField("Password", "Enter Your Password"),
                _buildPasswordField("Confirm Password", "Enter Your Password"),

                // City/Emirate Dropdown
                const SizedBox(height: 16),
                const Text(
                  "City/Emirate",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFECECEC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    items: ["Karachi", "Lahore", "Islamabad", "Peshawar"]
                        .map((city) => DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    ))
                        .toList(),
                    onChanged: (value) {},
                    hint: const Text(
                      "Select City",
                      style: TextStyle(color: Color(0xFF797979)),
                    ),
                  ),
                ),

                // Terms & Conditions
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      activeColor: const Color(0xFF2A9D8F),
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value!;
                        });
                      },
                    ),
                    const Text("I agree with "),
                    const Text(
                      "Terms & Conditions",
                      style: TextStyle(
                        color: Color(0xFF2A9D8F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A9D8F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "CONTINUE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Already have an account
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "Log in",
                          style: TextStyle(
                            color: Color(0xFF2A9D8F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      {required String label, required String hint, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF2A9D8F)),
            filled: true,
            fillColor: const Color(0xFFECECEC),
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF797979)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, String hint) {
    return _buildInputField(
      label: label,
      hint: hint,
      icon: Icons.lock_outline,
    );
  }
}
