import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  _BookingHistoryScreenState createState() => _BookingHistoryScreenState();
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2D3748) : const Color(0xFFF0F3F8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF2D3748) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF2D3748),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final List<Map<String, dynamic>> _reservations = [
    {
      'id': '3',
      'slotNumber': 'A4',
      'date': DateTime(2023, 8, 20),
      'startTime': '09:00',
      'endTime': '12:00',
      'price': 15.0,
      'status': 'Completed',
      'zone': 'A',
    },
    {
      'id': '4',
      'slotNumber': 'B2',
      'date': DateTime(2023, 8, 18),
      'startTime': '14:00',
      'endTime': '18:00',
      'price': 20.0,
      'status': 'Completed',
      'zone': 'B',
    },
    {
      'id': '5',
      'slotNumber': 'A1',
      'date': DateTime(2023, 8, 15),
      'startTime': '10:00',
      'endTime': '13:00',
      'price': 15.0,
      'status': 'Completed',
      'zone': 'A',
    },
    {
      'id': '6',
      'slotNumber': 'C3',
      'date': DateTime(2023, 8, 10),
      'startTime': '11:00',
      'endTime': '15:00',
      'price': 20.0,
      'status': 'Completed',
      'zone': 'C',
    },
    {
      'id': '7',
      'slotNumber': 'B4',
      'date': DateTime(2023, 8, 5),
      'startTime': '09:00',
      'endTime': '17:00',
      'price': 40.0,
      'status': 'Completed',
      'zone': 'B',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        title: const Text(
          'Booking History',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _reservations.isEmpty
          ? const Center(child: Text('No booking history'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _reservations.length,
              itemBuilder: (context, index) {
                final reservation = _reservations[index];
                return HistoryCard(reservation: reservation);
              },
            ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> reservation;

  const HistoryCard({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMd().format(reservation['date']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Slot ${reservation['slotNumber']} (Zone ${reservation['zone']})',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'RS ${reservation['price'].toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Date: $formattedDate', style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 5),
            Text('Time: ${reservation['startTime']} - ${reservation['endTime']}',
                style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Status: '),
                Chip(
                  label: Text(
                    reservation['status'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: reservation['status'] == 'Completed'
                      ? Colors.green
                      : Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  await _downloadReceipt(context, reservation);
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download Receipt'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _downloadReceipt(BuildContext context, Map<String, dynamic> reservation) async {
  try {
    final bytes = await _generateReceiptPdf(reservation);
    final filename = 'receipt_${reservation['id']}.pdf';

    if (kIsWeb) {
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..download = filename
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      await Printing.sharePdf(bytes: bytes, filename: filename);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt download started'), backgroundColor: Colors.green),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate receipt: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

Future<Uint8List> _generateReceiptPdf(Map<String, dynamic> reservation) async {
  final doc = pw.Document();

  final date = reservation['date'] as DateTime?;
  final formattedDate = date != null ? DateFormat.yMMMMd().format(date) : '';

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Parking Flow', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('Payment Receipt', style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
              pw.SizedBox(height: 16),

              pw.Divider(),
              pw.SizedBox(height: 12),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Receipt ID: ${reservation['id']}', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text(formattedDate, style: const pw.TextStyle(fontSize: 12)),
                ],
              ),

              pw.SizedBox(height: 16),

              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                padding: const pw.EdgeInsets.all(12),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Reservation Details', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    _kv('Slot', ' ${reservation['slotNumber']} (Zone ${reservation['zone']})'),
                    _kv('Date', ' $formattedDate'),
                    _kv('Time', ' ${reservation['startTime']} - ${reservation['endTime']}'),
                    _kv('Status', ' ${reservation['status']}'),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text('Total: ', style: pw.TextStyle(fontSize: 14, color: PdfColors.green900)),
                      pw.Text('RS ${reservation['price'].toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 24),
              pw.Text('Thank you for choosing Parking Flow!', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
            ],
          ),
        );
      },
    ),
  );

  return doc.save();
}

pw.Widget _kv(String k, String v) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      children: [
        pw.SizedBox(width: 80, child: pw.Text(k, style: pw.TextStyle(color: PdfColors.grey700))),
        pw.Expanded(child: pw.Text(v, style: const pw.TextStyle(color: PdfColors.black))),
      ],
    ),
  );
}
