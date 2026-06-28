import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:helpinghand/services/api_service.dart';

class ZindigiPaymentScreen extends StatefulWidget {
  const ZindigiPaymentScreen({super.key});

  @override
  State<ZindigiPaymentScreen> createState() => _ZindigiPaymentScreenState();
}

class _ZindigiPaymentScreenState extends State<ZindigiPaymentScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _basketId; // captured at initiate; used to confirm payment server-side
  bool _confirming = false;
  bool _sessionReady = false;
  String? _errorMessage;
  int _loadingStep = 0;

  static const _loadingSteps = [
    'Connecting to payment gateway...',
    'Verifying merchant credentials...',
    'Securing your transaction...',
    'Preparing checkout session...',
    'Almost ready...',
  ];

  // Args passed via Navigator
  late double amount;
  late String donorMobile;
  late String donorEmail;
  String donorName = '';
  late String donationType;
  late String requestId;

  Timer? _stepTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      amount = (args['amount'] as num).toDouble();
      donorMobile = args['donor_mobile'] ?? '';
      donorEmail = args['donor_email'] ?? '';
      donorName = args['donor_name'] ?? '';
      donationType = args['donation_type'] ?? 'blood';
      requestId = args['request_id']?.toString() ?? '0';
      _startStepTimer();
      _initPaymentSession();
    } else {
      setState(() => _errorMessage = 'Missing payment details.');
    }
  }

  void _startStepTimer() {
    _stepTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted && !_sessionReady) {
        setState(() {
          _loadingStep = (_loadingStep + 1) % _loadingSteps.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  Future<void> _initPaymentSession() async {
    try {
      // Step 1: Get session params from our backend (no Zindigi call server-side)
      final response = await ApiService.post(
        '/payment/zindigi/initiate',
        {
          'amount': amount,
          'donor_mobile': donorMobile,
          'donor_email': donorEmail,
          'donor_name': donorName,
          'donation_type': donationType,
          'request_id': requestId,
        },
        includeAuth: true,
      );

      if (response['success'] != true) {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to start payment.';
          _isLoading = false;
        });
        return;
      }

      final data = response['data'] as Map<String, dynamic>;
      _basketId = data['basket_id']?.toString();

      // Step 2: Call Zindigi's GetAccessToken directly from the phone (Pakistani IP)
      final tokenRes = await http.post(
        Uri.parse(data['get_token_url'] as String),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'MERCHANT_ID': data['merchant_id'].toString(),
          'SECURED_KEY': data['secured_key'].toString(),
          'BASKET_ID': data['basket_id'].toString(),
          'TXNAMT': data['txn_amount'].toString(),
        },
      ).timeout(const Duration(seconds: 20));

      final tokenBody = jsonDecode(tokenRes.body) as Map<String, dynamic>;
      final accessToken = tokenBody['ACCESS_TOKEN'] as String?;

      if (accessToken == null || accessToken.isEmpty) {
        setState(() {
          _errorMessage = 'Could not get payment token from Zindigi. Please try again.';
          _isLoading = false;
        });
        return;
      }

      // Step 3: Build checkout payload and show WebView
      final payload = <String, dynamic>{
        'MERCHANT_ID': data['merchant_id'].toString(),
        'MERCHANT_NAME': data['merchant_name'].toString(),
        'TOKEN': accessToken,
        'PROCCODE': '00',
        'TXNAMT': data['txn_amount'].toString(),
        'CUSTOMER_MOBILE_NO': data['customer_mobile'].toString(),
        'CUSTOMER_EMAIL_ADDRESS': data['customer_email'].toString(),
        'CUSTOMER_NAME': data['customer_name'].toString(),
        'SIGNATURE': _randomHex(),
        'VERSION': 'HELPINGHAND-1.0',
        'TXNDESC': data['txn_desc'].toString(),
        'SUCCESS_URL': data['success_url'].toString(),
        'FAILURE_URL': data['failure_url'].toString(),
        'CHECKOUT_URL': data['ipn_url'].toString(),
        'BASKET_ID': data['basket_id'].toString(),
        'ORDER_DATE': data['order_date'].toString(),
        'CURRENCY_CODE': 'PKR',
        'TRAN_TYPE': 'ECOMM_PURCHASE',
      };

      _setupWebView(data['checkout_url'] as String, payload);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  String _randomHex() {
    final rand = Random.secure();
    return List.generate(32, (_) => rand.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  void _setupWebView(String checkoutUrl, Map<String, dynamic> payload) {
    // Build an HTML form that auto-submits to Zindigi
    final formFields = payload.entries.map((e) {
      final key = _escapeHtml(e.key);
      final val = _escapeHtml(e.value?.toString() ?? '');
      return '<input type="hidden" name="$key" value="$val">';
    }).join('\n');

    final html = '''
<!DOCTYPE html>
<html>
<body onload="document.forms[0].submit()">
<form method="POST" action="${_escapeHtml(checkoutUrl)}">
$formFields
</form>
<p style="font-family:sans-serif;text-align:center;margin-top:40px;color:#666;">
  Redirecting to secure payment...</p>
</body>
</html>''';

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onNavigationRequest: (req) => _handleNavigation(req),
        onWebResourceError: (err) {
          setState(() => _errorMessage = 'Page error: ${err.description}');
        },
      ))
      ..loadHtmlString(html);

    setState(() {
      _controller = controller;
      _sessionReady = true;
    });
  }

  NavigationDecision _handleNavigation(NavigationRequest req) {
    final url = req.url.toLowerCase();

    // Intercept SUCCESS_URL — the gateway reports success, but we confirm with
    // OUR backend (which verifies the Zindigi signature and records the
    // donation) before reporting success to the caller.
    if (url.contains('/payment/zindigi/callback') && url.contains('status=success')) {
      final uri = Uri.parse(req.url);
      final basketId = uri.queryParameters['basket_id'] ?? _basketId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confirmPaymentWithBackend(
          callbackUrl: req.url,
          basketId: basketId,
          transactionId: uri.queryParameters['transaction_id'],
          transactionAmount: uri.queryParameters['transaction_amount'],
        );
      });
      return NavigationDecision.prevent;
    }

    // Intercept FAILURE_URL — contains ?status=failure
    if (url.contains('/payment/zindigi/callback') && url.contains('status=failure')) {
      final uri = Uri.parse(req.url);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop({
          'success': false,
          'err_code': uri.queryParameters['err_code'] ?? 'failed',
          'basket_id': uri.queryParameters['basket_id'],
        });
      });
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  // Poll our backend for the authoritative payment status. The donation is
  // recorded server-side once Zindigi confirms the payment (via IPN/callback),
  // so we wait for it to settle before telling the caller it succeeded.
  Future<void> _confirmPaymentWithBackend({
    String? callbackUrl,
    String? basketId,
    String? transactionId,
    String? transactionAmount,
  }) async {
    if (_confirming) return;
    _confirming = true;

    // Hit our backend's callback URL (it carries Zindigi's signed params) so
    // the server finalizes the payment now, without waiting on the IPN.
    if (callbackUrl != null && callbackUrl.isNotEmpty) {
      try {
        await http.get(Uri.parse(callbackUrl)).timeout(const Duration(seconds: 15));
      } catch (_) {
        // best-effort; verify polling below is the source of truth
      }
    }

    String status = 'pending';
    if (basketId != null && basketId.isNotEmpty) {
      // Poll up to ~8 times (≈16s) to give the IPN/callback time to land.
      for (int i = 0; i < 8; i++) {
        try {
          final res = await ApiService.get('/payment/zindigi/verify/$basketId');
          status = (res['data']?['status'] ?? 'pending').toString();
          if (status == 'completed' || status == 'failed') break;
        } catch (_) {
          // ignore transient errors and retry
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop({
      'success': status == 'completed',
      'status': status,
      'basket_id': basketId,
      'transaction_id': transactionId,
      'transaction_amount': transactionAmount,
    });
  }

  String _escapeHtml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('"', '&quot;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A4A),
        foregroundColor: Colors.white,
        title: const Text('Secure Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop({'success': false, 'cancelled': true}),
        ),
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop({'success': false}),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3A4A),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            )
          else if (_sessionReady && _controller != null)
            WebViewWidget(controller: _controller!),

          if (_isLoading || (!_sessionReady && _errorMessage == null))
            Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF1A3A4A)),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          _loadingSteps[_loadingStep],
                          key: ValueKey(_loadingStep),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF1A3A4A), fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Please wait, do not close this screen', style: TextStyle(color: Colors.black38, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
