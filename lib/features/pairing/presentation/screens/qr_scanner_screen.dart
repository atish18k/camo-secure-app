// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../domain/services/qr_payload_parser.dart';

// ---------------------------------------------------------------------------
// QR Scanner Screen
// ---------------------------------------------------------------------------

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({
    super.key,
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();

  bool _isProcessing = false;

  // ---------------------------------------------------------------------------
  // QR Detection
  // ---------------------------------------------------------------------------

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final Barcode? barcode = capture.barcodes.firstOrNull;

    if (barcode == null) return;

    final String? value = barcode.rawValue;

    if (value == null || value.isEmpty) return;


    _isProcessing = true;

    try {
      final QrPayload payload = QrPayloadParser().parse(value);

      await _controller.stop();

      if (!mounted) return;

      Navigator.pop(
        context,
        payload,
      );
    } on FormatException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );

      _isProcessing = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan CAMO QR'),
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
      ),
    );
  }
}