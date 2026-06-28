import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A4A),
        foregroundColor: Colors.white,
        title: const Text('Contact Us'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          const Icon(Icons.support_agent, size: 64, color: Color(0xFF2A9D8F)),
          const SizedBox(height: 16),
          const Text('Get in Touch', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A3A4A))),
          const SizedBox(height: 8),
          const Text('We\'re here to help you. Reach out through any channel below.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 14)),
          const SizedBox(height: 32),
          _ContactTile(icon: Icons.email, label: 'Email Us', value: 'support@helpinghand.pk',
              onTap: () => _launch('mailto:support@helpinghand.pk')),
          _ContactTile(icon: Icons.phone, label: 'Call Us', value: '+92 300 0000000',
              onTap: () => _launch('tel:+923000000000')),
          _ContactTile(icon: Icons.chat, label: 'WhatsApp', value: '+92 300 0000000',
              onTap: () => _launch('https://wa.me/923000000000')),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactTile({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFF2A9D8F).withAlpha(30),
            child: Icon(icon, color: const Color(0xFF2A9D8F))),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
