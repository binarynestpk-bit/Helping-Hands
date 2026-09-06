// lib/screens/manual_donation_screen.dart
//
// Manual bank-transfer donation flow (replaces the in-app payment gateway).
// Flow: the donor copies an account, sends the money from their OWN banking
// app, then uploads a screenshot of the transaction here. The admin verifies
// the screenshot and the cause's raised amount updates. No payment is processed
// inside the app.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:helpinghand/services/auth_service.dart';
import 'package:helpinghand/widgets/guest_access.dart';

class ManualDonationScreen extends StatefulWidget {
  const ManualDonationScreen({Key? key}) : super(key: key);

  @override
  State<ManualDonationScreen> createState() => _ManualDonationScreenState();
}

class _ManualDonationScreenState extends State<ManualDonationScreen> {
  static const Color _teal = Color(0xFF2A9D8F);

  final TextEditingController _amountController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _screenshot;

  bool _loadingAccounts = true;
  bool _submitting = false;
  List<dynamic> _accounts = [];
  String? _accountsError;

  // Route arguments
  String _donationType = 'general';
  String? _requestId;
  String _causeTitle = '';
  String _donorName = '';
  String _donorEmail = '';
  String _donorMobile = '';
  bool _argsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    _argsLoaded = true;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['amount'] != null) _amountController.text = _fmtAmount(args['amount']);
      _donationType = (args['donation_type'] ?? 'general').toString();
      _requestId = args['request_id']?.toString();
      _causeTitle = (args['cause_title'] ?? '').toString();
      _donorName = (args['donor_name'] ?? '').toString();
      _donorEmail = (args['donor_email'] ?? '').toString();
      _donorMobile = (args['donor_mobile'] ?? '').toString();
    }
    _fetchAccounts();
  }

  String _fmtAmount(dynamic v) {
    final d = (v is num) ? v.toDouble() : (double.tryParse(v.toString()) ?? 0);
    return d == d.roundToDouble() ? d.round().toString() : d.toString();
  }

  Future<void> _fetchAccounts() async {
    try {
      final res = await ApiService.get('/donations/accounts', includeAuth: false);
      if (!mounted) return;
      setState(() {
        _accounts = (res['data'] as List?) ?? [];
        _loadingAccounts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _accountsError = 'Could not load account details. Please check your connection and try again.';
        _loadingAccounts = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _copy(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label copied'), duration: const Duration(milliseconds: 1200)));
  }

  Future<void> _pickScreenshot() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 60, maxWidth: 1400);
      if (picked != null) setState(() => _screenshot = File(picked.path));
    } catch (_) {
      _snack('Could not open the gallery.');
    }
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _snack('Please enter the amount you sent.');
      return;
    }
    if (_screenshot == null) {
      _snack('Please upload a screenshot of your transaction.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final fields = <String, String>{
        'amount': amount.toString(),
        'donation_type': _donationType,
        'donor_name': _donorName,
        'donor_email': _donorEmail,
        'donor_mobile': _donorMobile,
      };
      if (_donationType != 'general' && _requestId != null) fields['request_id'] = _requestId!;

      final res = await ApiService.postMultipart(
        '/donations/proof',
        fields,
        files: {'proof': _screenshot!},
        includeAuth: true,
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      if (res['success'] == true) {
        _showThankYou();
      } else {
        _snack(res['message']?.toString() ?? 'Submission failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showThankYou() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Expanded(child: Text('Thank you!')),
          ],
        ),
        content: const Text(
          'Your donation has been submitted and is pending verification by our team. '
          'Once verified, it will be reflected on the cause. Jazak Allah for your generosity.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (AuthService.isGuest()) {
      return const GuestLockedScaffold(title: 'Donate');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Donate', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_causeTitle.isNotEmpty) ...[
              Text('Donating to', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              Text(_causeTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
            ],

            // How it works
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('How to donate', style: TextStyle(fontWeight: FontWeight.bold, color: _teal)),
                  SizedBox(height: 6),
                  Text('1.  Copy one of the accounts below.\n'
                      '2.  Send the amount from your own banking / wallet app.\n'
                      '3.  Take a screenshot of the transaction.\n'
                      '4.  Enter the amount and upload the screenshot here.\n\n'
                      'Our team verifies every donation before it is added to the cause.',
                      style: TextStyle(fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Amount
            const Text('Amount you are sending', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'PKR ',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _teal)),
              ),
            ),
            const SizedBox(height: 20),

            // Accounts
            const Text('Send to any of these accounts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            if (_loadingAccounts)
              const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: _teal)))
            else if (_accountsError != null)
              _errorBox(_accountsError!)
            else if (_accounts.isEmpty)
              _errorBox('No donation accounts are available right now. Please try again later.')
            else
              ..._accounts.map((a) => _accountCard(a as Map<String, dynamic>)).toList(),
            const SizedBox(height: 20),

            // Screenshot
            const Text('Upload transaction screenshot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            _screenshotPicker(),
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _submitting
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Submit Donation', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _errorBox(String msg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFFFF3F2), borderRadius: BorderRadius.circular(10)),
      child: Text(msg, style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _accountCard(Map<String, dynamic> a) {
    final label = (a['label'] ?? '').toString();
    final title = (a['account_title'] ?? '').toString();
    final number = (a['account_number'] ?? '').toString();
    final iban = (a['iban'] ?? '').toString();
    final bank = (a['bank_name'] ?? '').toString();
    final currency = (a['currency'] ?? '').toString();
    final instructions = (a['instructions'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              if (currency.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFEAF5F4), borderRadius: BorderRadius.circular(20)),
                  child: Text(currency, style: const TextStyle(color: _teal, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          if (bank.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(bank, style: TextStyle(color: Colors.grey.shade700, fontSize: 13))),
          const SizedBox(height: 8),
          if (title.isNotEmpty) _copyRow('Title', title),
          if (number.isNotEmpty) _copyRow('Account', number),
          if (iban.isNotEmpty) _copyRow('IBAN', iban),
          if (instructions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(instructions, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontStyle: FontStyle.italic)),
            ),
        ],
      ),
    );
  }

  Widget _copyRow(String label, String value) {
    return InkWell(
      onTap: () => _copy(label, value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            SizedBox(width: 62, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
            const Icon(Icons.copy, size: 18, color: _teal),
          ],
        ),
      ),
    );
  }

  Widget _screenshotPicker() {
    if (_screenshot != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(_screenshot!, height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _pickScreenshot,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: const Text('Change', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ),
        ],
      );
    }
    return InkWell(
      onTap: _pickScreenshot,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload_outlined, size: 36, color: _teal),
            const SizedBox(height: 8),
            Text('Tap to upload screenshot', style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}
