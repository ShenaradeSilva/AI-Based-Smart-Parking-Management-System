import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class QrCodeScreen extends StatelessWidget {
  final Map<String, dynamic> reservation;

  const QrCodeScreen({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    // Build a robust QR payload
    final DateTime? date = reservation['date'] is DateTime
        ? reservation['date'] as DateTime
        : null;
    final formattedDate = date != null
        ? DateFormat.yMMMd().format(date)
        : (reservation['date']?.toString() ?? '');

    // Prefer backend-provided QR string if present
    String? backendQr = (reservation['qr'] ?? reservation['qr_code'])?.toString();
    String qrPayload;
    if (backendQr != null && backendQr.trim().isNotEmpty) {
      qrPayload = backendQr;
    } else {
      // Fallback: generate a JSON payload from reservation fields
      final payload = {
        'id': reservation['id']?.toString(),
        'slot': reservation['slotNumber']?.toString(),
        'zone': reservation['zone']?.toString(),
        'date': date?.toIso8601String() ?? reservation['date']?.toString(),
        'start': reservation['startTime']?.toString(),
        'end': reservation['endTime']?.toString(),
        'status': reservation['status']?.toString() ?? 'Confirmed',
      };
      qrPayload = json.encode(payload);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        title: const Text(
          'Booking Confirmed',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'Booking Confirmed!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Slot ${reservation['slotNumber']} on $formattedDate',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${reservation['startTime']} - ${reservation['endTime']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text(
                              'Your Code',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            // QR code image
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.white,
                              child: QrImageView(
                                data: qrPayload,
                                version: QrVersions.auto,
                                size: 220,
                                backgroundColor: Colors.white,
                                gapless: true,
                                errorStateBuilder: (c, err) => const SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: Center(child: Text('Failed to generate QR')),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Show this at the entrance',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Fixed bottom button within SafeArea
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    // Future: Share or save code
                  },
                  child: const Text('Share Code', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
