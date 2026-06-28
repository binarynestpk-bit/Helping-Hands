import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:helpinghand/screens/email_verification_screen.dart';

class VerifyPhoneScreen extends StatefulWidget {
  final String mode; // 'signup' or 'reset_password'
  final String phone;
  final String email;
  final String userName;

  const VerifyPhoneScreen({
    Key? key,
    this.mode = 'signup',
    this.phone = '',
    this.email = '',
    this.userName = '',
  }) : super(key: key);

  @override
  _VerifyPhoneScreenState createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  bool _canResend = false;
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _sendOTP();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() { _canResend = false; _resendCountdown = 60; });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
        }
      });
      return _resendCountdown > 0;
    });
  }

  Future<void> _sendOTP() async {
    try {
      await ApiService.post('/auth/send-phone-otp', {'phone': widget.phone});
    } catch (_) {
      // silently ignore on first send — user can retry with resend button
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend || _isResending) return;
    setState(() => _isResending = true);
    try {
      await ApiService.post('/auth/send-phone-otp', {'phone': widget.phone});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('OTP resent to your phone'),
        backgroundColor: Colors.green,
      ));
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to resend: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _verifyCode() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter the 6-digit OTP'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    setState(() => _isVerifying = true);
    try {
      final response = await ApiService.post('/auth/verify-phone-otp', {
        'phone': widget.phone,
        'otp': otp,
      });

      if (!mounted) return;

      if (response['success'] == true) {
        if (widget.mode == 'reset_password') {
          Navigator.pushNamed(context, '/create-new-password');
        } else {
          // Proceed to email verification
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => EmailVerificationScreen(
                email: widget.email,
                userName: widget.userName,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      _controllers[index].text = value[value.length - 1];
      if (index < 5) FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
  }

  void _onKeyDown(RawKeyEvent event, int index) {
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        index > 0 &&
        _controllers[index].text.isEmpty) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    final otpFieldSize = isSmallScreen ? 45.0 : 50.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,
              size: isSmallScreen ? 22 : 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: screenHeight * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Verify ',
                style: TextStyle(
                    fontSize: isSmallScreen ? 20.0 : 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                children: const [
                  TextSpan(
                      text: 'Phone',
                      style: TextStyle(color: Color(0xFF2A9D8F))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Code sent to ${widget.phone}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: isSmallScreen ? 14.0 : 16.0,
                  color: Colors.black54),
            ),
            SizedBox(height: screenHeight * 0.03),

            // OTP fields
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  width: otpFieldSize,
                  height: otpFieldSize,
                  margin: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 3 : 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black54),
                  ),
                  alignment: Alignment.center,
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (e) => _onKeyDown(e, index),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: TextStyle(
                          fontSize: isSmallScreen ? 18.0 : 22.0,
                          fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                          counterText: '', border: InputBorder.none),
                      onChanged: (v) => _onChanged(v, index),
                      onTap: () {
                        _controllers[index].selection =
                            TextSelection.fromPosition(TextPosition(
                                offset: _controllers[index].text.length));
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Resend
            GestureDetector(
              onTap: _canResend ? _resendOTP : null,
              child: _isResending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Didn't receive code? ",
                        style: TextStyle(
                            fontSize: isSmallScreen ? 14.0 : 16.0,
                            color: Colors.black),
                        children: [
                          TextSpan(
                            text: _canResend
                                ? 'Request Again'
                                : 'Resend in ${_resendCountdown}s',
                            style: TextStyle(
                              color: _canResend
                                  ? const Color(0xFF2A9D8F)
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Verify button
            SizedBox(
              width: double.infinity,
              height: isSmallScreen ? 45.0 : 50.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A9D8F),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isVerifying ? null : _verifyCode,
                child: _isVerifying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Verify And Next',
                        style: TextStyle(
                            fontSize: isSmallScreen ? 16.0 : 18.0,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
