import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanQr extends StatefulWidget {
  const ScanQr({super.key});

  @override
  State<ScanQr> createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  String? _qrCodeData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchQrCodeData();
  }

  Future<void> _fetchQrCodeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://wondrous-bull-enhanced.ngrok-free.app/apk-qrcode-data'),
      );

      if (response.statusCode == 200) {
        // Pretty print the JSON for better readability
        final prettyJson = const JsonEncoder.withIndent('  ')
            .convert(json.decode(response.body));

        // Print to console for verification
        print('Fetched QR Code Data:');
        print(prettyJson);

        setState(() {
          _qrCodeData = response.body;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load QR code data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching QR code data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _errorMessage != null
                ? Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  )
                : _qrCodeData != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // QR Code
                          QrImageView(
                            data: _qrCodeData!,
                            version: QrVersions.auto,
                            size: 300.0,
                          ),
                          const SizedBox(height: 20),
                          // Data Verification Section
                          Text(
                            'Verification Data:',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          // Make the text scrollable if it's long
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Text(
                              _qrCodeData!,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Text('No QR code data available'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchQrCodeData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
