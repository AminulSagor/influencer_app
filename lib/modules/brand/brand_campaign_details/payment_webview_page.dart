import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String initialUrl;
  final String successUrl;
  final String failUrl;
  final String? initialTranId;
  final Future<Map<String, dynamic>> Function(String tranId) checkPaymentStatus;
  final void Function(bool isSuccess)? onResult;

  const PaymentWebViewPage({
    super.key,
    required this.initialUrl,
    required this.successUrl,
    required this.failUrl,
    required this.checkPaymentStatus,
    this.initialTranId,
    this.onResult,
  });

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;

  bool _handled = false;
  bool _isVerifying = false;
  int _progress = 0;

  bool _isSuccessLikeUrl(String url) {
    return url.contains('payments/sslcommerz/success') ||
        url.contains('/payment/success');
  }

  bool _isFailLikeUrl(String url) {
    return url.contains('payments/sslcommerz/fail') ||
        url.contains('payments/sslcommerz/cancel') ||
        url.contains('/payment/fail') ||
        url.contains('/payment/cancel');
  }

  String? _extractTranIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);

      final tranId =
          uri.queryParameters['tranId'] ??
          uri.queryParameters['tran_id'] ??
          uri.queryParameters['tranID'];

      if (tranId != null && tranId.trim().isNotEmpty) {
        return tranId.trim();
      }
    } catch (_) {}

    return null;
  }

  Map<String, dynamic> _unwrapPayload(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return response;
  }

  String _readStatus(Map<String, dynamic> response) {
    final payload = _unwrapPayload(response);
    return (payload['status'] ?? '').toString().trim().toUpperCase();
  }

  String _readGatewayStatus(Map<String, dynamic> response) {
    final payload = _unwrapPayload(response);
    return (payload['gatewayStatus'] ?? '').toString().trim().toUpperCase();
  }

  bool _isTerminalFailure(String status, String gatewayStatus) {
    const failedStatuses = {
      'FAILED',
      'FAIL',
      'CANCELLED',
      'CANCELED',
      'INVALID',
      'DECLINED',
      'ABORTED',
      'ERROR',
    };

    return failedStatuses.contains(status) ||
        failedStatuses.contains(gatewayStatus);
  }

  Future<bool> _validatePaymentByStatus(String tranId) async {
    const maxAttempts = 6;
    const retryDelay = Duration(seconds: 2);

    for (int i = 0; i < maxAttempts; i++) {
      try {
        final response = await widget.checkPaymentStatus(tranId);
        final status = _readStatus(response);
        final gatewayStatus = _readGatewayStatus(response);

        if (status == 'VALIDATED') {
          return true;
        }

        if (_isTerminalFailure(status, gatewayStatus)) {
          return false;
        }
      } catch (_) {
        // ignore and retry
      }

      if (i < maxAttempts - 1) {
        await Future.delayed(retryDelay);
      }
    }

    return false;
  }

  Future<void> _finishWithResult(bool isSuccess) async {
    if (_handled || !mounted) return;

    _handled = true;
    widget.onResult?.call(isSuccess);
    Navigator.of(context).pop(isSuccess);
  }

  Future<void> _handleRedirect(String url) async {
    if (_handled || !mounted || _isVerifying) return;

    final isSuccessLike = _isSuccessLikeUrl(url);
    final isFailLike = _isFailLikeUrl(url);

    if (!isSuccessLike && !isFailLike) return;

    final tranId = _extractTranIdFromUrl(url) ?? widget.initialTranId;

    if (tranId == null || tranId.isEmpty) {
      await _finishWithResult(false);
      return;
    }

    _isVerifying = true;
    if (mounted) {
      setState(() {});
    }

    final isValidated = await _validatePaymentByStatus(tranId);

    _isVerifying = false;
    if (mounted) {
      setState(() {});
    }

    await _finishWithResult(isValidated);
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _progress = progress);
          },
          onPageStarted: (url) async {
            await _handleRedirect(url);
          },
          onPageFinished: (url) async {
            await _handleRedirect(url);
          },
          onNavigationRequest: (request) async {
            final url = request.url;

            await _handleRedirect(url);

            if (_handled) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint(
              'Payment WebView error: ${error.description} | url: ${error.url}',
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Stack(
        children: [
          Column(
            children: [
              if (_progress < 100)
                LinearProgressIndicator(value: _progress / 100),
              Expanded(child: WebViewWidget(controller: _controller)),
            ],
          ),
          if (_isVerifying)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
