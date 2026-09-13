import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Shows a one-time delivery-loop token as a scannable QR — the merchant's
/// pickup QR (handed to the driver in person) and the driver's delivery QR
/// (handed to the customer) both render through this same screen. The token
/// is encoded bare, matching TokenScanScreen's own bare-token reading.
class TokenQrScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String token;

  const TokenQrScreen({super.key, required this.title, required this.subtitle, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(subtitle, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: QrImageView(data: token, size: 240, backgroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
