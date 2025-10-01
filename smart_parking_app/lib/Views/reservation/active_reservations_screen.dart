import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../qr_code_screen.dart';

class ActiveReservationsScreen extends StatefulWidget {
  const ActiveReservationsScreen({super.key});

  @override
  _ActiveReservationsScreenState createState() =>
      _ActiveReservationsScreenState();
}

class _ActiveReservationsScreenState extends State<ActiveReservationsScreen> {
  final List<Map<String, dynamic>> _reservations = [
    {
      'id': '1',
      'slotNumber': 'A1',
      'date': DateTime(2023, 8, 25),
      'startTime': '10:00',
      'endTime': '14:00',
      'price': 20.0,
      'status': 'Active',
      'zone': 'A',
    },
    {
      'id': '2',
      'slotNumber': 'B3',
      'date': DateTime(2023, 8, 26),
      'startTime': '13:00',
      'endTime': '17:00',
      'price': 20.0,
      'status': 'Active',
      'zone': 'B',
    },
  ];
  bool _isLoading = false;

  void _cancelReservation(String reservationId) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _reservations.removeWhere((r) => r['id'] == reservationId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reservation cancelled successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Reservations')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _reservations.isEmpty
              ? const Center(
                  child: Text('No active reservations'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = _reservations[index];
                    return ReservationCard(
                      reservation: reservation,
                      onCancel: () => _cancelReservation(reservation['id']),
                      onView: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QrCodeScreen(reservation: reservation),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class ReservationCard extends StatelessWidget {
  final Map<String, dynamic> reservation;
  final VoidCallback onCancel;
  final VoidCallback onView;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onCancel,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMd().format(reservation['date']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                const Icon(Icons.qr_code, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 10),
            Text('Date: $formattedDate'),
            const SizedBox(height: 5),
            Text(
                'Time: ${reservation['startTime']} - ${reservation['endTime']}'),
            const SizedBox(height: 5),
            Text('Price: RS ${reservation['price'].toStringAsFixed(2)}'),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text('Status: '),
                Chip(
                  label: Text(
                    reservation['status'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: const Text('Cancel Reservation'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onView,
                    child: const Text('View QR Code'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
