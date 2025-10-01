import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../qr_code_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> slot;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const BookingConfirmationScreen({
    super.key,
    required this.slot,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  double _calculatePrice() {
    final start = DateTime(
        date.year, date.month, date.day, startTime.hour, startTime.minute);
    final end =
        DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
    final duration = end.difference(start);
    final hours = duration.inHours + (duration.inMinutes % 60 > 0 ? 1 : 0);

    return hours * 150.0;
  }
  @override
  Widget build(BuildContext context) {
    final price = _calculatePrice();
    final formattedDate = DateFormat.yMMMd().format(date);

    final placeName = (slot['placeName'] as String?) ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(placeName.isNotEmpty ? 'Booking - $placeName' : 'Booking Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review Your Booking',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (placeName.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Place', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(placeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Parking Slot',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(slot['number'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Date'),
                        Text(formattedDate),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Time'),
                        Text(
                            '${startTime.format(context)} - ${endTime.format(context)}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Duration'),
                        Text('${endTime.hour - startTime.hour} hours'),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Price',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('RS ${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Credit/Debit Card'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.paypal),
                title: const Text('PayPal'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Process payment and generate QR code
                  final reservation = {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'slotNumber': slot['number'],
                    'date': date,
                    'startTime': startTime.format(context),
                    'endTime': endTime.format(context),
                    'price': price,
                    'status': 'Confirmed',
                    'zone': slot['zone'],
                  };

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QrCodeScreen(reservation: reservation),
                    ),
                  );
                },
                child: const Text('Confirm and Pay',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
