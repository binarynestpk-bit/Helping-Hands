// lib/widgets/phone_input_field.dart
// Reusable worldwide phone input: a country-code dropdown (flag + dial code)
// followed by the local number field. Emits the full E.164 number (e.g.
// "+923001234567") via [onChanged] so every form sends a consistent value
// to the backend.

import 'package:flutter/material.dart';
import 'country_codes.dart';

class PhoneInputField extends StatefulWidget {
  /// Controller holding the LOCAL number digits (without the dial code).
  final TextEditingController controller;

  /// Initial dial code, e.g. "+92". Defaults to Pakistan.
  final String initialDialCode;

  /// Called with the full E.164 number whenever the code or number changes.
  final ValueChanged<String>? onChanged;

  final String label;
  final String hintText;
  final bool isSmallScreen;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.initialDialCode = kDefaultDialCode,
    this.onChanged,
    this.label = 'Mobile Number',
    this.hintText = 'Phone number',
    this.isSmallScreen = false,
  });

  /// Splits a stored E.164 number into (dialCode, localNumber) using the known
  /// country list. Falls back to the default dial code when unknown.
  static (String dialCode, String number) split(String? e164) {
    final value = (e164 ?? '').trim();
    if (value.isEmpty) return (kDefaultDialCode, '');
    if (!value.startsWith('+')) return (kDefaultDialCode, value.replaceAll(RegExp(r'\D'), ''));
    // Match the longest dial code first so "+1" doesn't shadow "+92" etc.
    final codes = kCountryCodes.map((c) => c.code).toSet().toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final code in codes) {
      if (value.startsWith(code)) {
        return (code, value.substring(code.length).replaceAll(RegExp(r'\D'), ''));
      }
    }
    return (kDefaultDialCode, value.replaceAll(RegExp(r'[^\d]'), ''));
  }

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late String _dialCode;
  late String _flag;

  @override
  void initState() {
    super.initState();
    final match = kCountryCodes.firstWhere(
      (c) => c.code == widget.initialDialCode,
      orElse: () => kCountryCodes.first,
    );
    _dialCode = match.code;
    _flag = match.flag;
    widget.controller.addListener(_emit);
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_emit);
    super.dispose();
  }

  void _emit() {
    var digits = widget.controller.text.trim().replaceAll(RegExp(r'\D'), '');
    // Drop the national trunk prefix (e.g. 0300... -> 300...) because the
    // country code is now explicit. Without this, "+92" + "0300..." would be
    // an invalid number and fail backend validation.
    digits = digits.replaceFirst(RegExp(r'^0+'), '');
    widget.onChanged?.call('$_dialCode$digits');
  }

  @override
  Widget build(BuildContext context) {
    final small = widget.isSmallScreen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: small ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: _showCountryPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFECECEC))),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_flag, style: TextStyle(fontSize: small ? 18 : 22)),
                    const SizedBox(width: 4),
                    Text(_dialCode,
                        style: TextStyle(
                            fontSize: small ? 13 : 15,
                            fontWeight: FontWeight.w600)),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: widget.controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: const Color(0xFF9C9C9C),
                    fontSize: small ? 12 : 14,
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFECECEC)),
                  ),
                ),
              ),
            ),
          ],
        ),
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
              ? kCountryCodes
              : kCountryCodes
                  .where((c) =>
                      c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      c.code.contains(searchQuery))
                  .toList();
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                    width: 40,
                    height: 4,
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
                      final isSelected = c.code == _dialCode && c.flag == _flag;
                      return ListTile(
                        leading:
                            Text(c.flag, style: const TextStyle(fontSize: 24)),
                        title: Text(c.name),
                        trailing: Text(c.code,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2A9D8F))),
                        selected: isSelected,
                        selectedTileColor:
                            const Color(0xFF2A9D8F).withOpacity(0.08),
                        onTap: () {
                          setState(() {
                            _dialCode = c.code;
                            _flag = c.flag;
                          });
                          _emit();
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
