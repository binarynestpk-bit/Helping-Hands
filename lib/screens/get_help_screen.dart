import 'package:flutter/material.dart';

class GetHelpScreen extends StatelessWidget {
  const GetHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const faqs = [
      {'q': 'How do I donate blood?', 'a': 'Go to the Blood Donation section, browse requests, and tap Donate on any request that matches your blood type.'},
      {'q': 'How do I request education support?', 'a': 'Go to Education Support, tap "Request Support", fill in your details and submit. Our team will review within 2-3 days.'},
      {'q': 'How do I request family support?', 'a': 'Go to Shuhada Family Support, tap "Submit Request", complete the form with required documents.'},
      {'q': 'Is my donation secure?', 'a': 'Yes. All payments are processed through Zindigi\'s secure payment gateway with full encryption.'},
      {'q': 'How long does payment processing take?', 'a': 'Payments are processed instantly. The recipient is notified as soon as your donation is confirmed.'},
      {'q': 'Can I cancel my support request?', 'a': 'Yes, go to "My Requests" in your profile and cancel any pending request.'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A4A),
        foregroundColor: Colors.white,
        title: const Text('Get Help'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          const Icon(Icons.help_outline, size: 56, color: Color(0xFFFFC107)),
          const SizedBox(height: 12),
          const Text('Frequently Asked Questions', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A3A4A))),
          const SizedBox(height: 20),
          ...faqs.map((faq) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: Text(faq['q']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              iconColor: const Color(0xFF2A9D8F),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(faq['a']!, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                )
              ],
            ),
          )),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/contact-us'),
            icon: const Icon(Icons.support_agent),
            label: const Text('Still need help? Contact Us'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2A9D8F),
              side: const BorderSide(color: Color(0xFF2A9D8F)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
