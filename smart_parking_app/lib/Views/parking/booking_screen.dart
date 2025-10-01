import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'booking_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> slot;

  const BookingScreen({super.key, required this.slot});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1))),
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _proceedToConfirmation() async {
    if (_selectedDate != null && _startTime != null && _endTime != null) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _isLoading = false;
      });
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationScreen(
            slot: widget.slot,
            date: _selectedDate!,
            startTime: _startTime!,
            endTime: _endTime!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final placeName = (widget.slot['placeName'] as String?) ?? '';
    final address = (widget.slot['address'] as String?) ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          placeName.isNotEmpty
              ? 'Book ${widget.slot['number']}'
              : 'Book ${widget.slot['number']}',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildHeaderImage(widget.slot['imageUrl']),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black26],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      (widget.slot['status'] ?? 'unknown') == 'available' ? Icons.local_parking : Icons.block,
                      size: 40,
                      color: (widget.slot['status'] ?? 'unknown') == 'available' ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Slot ${widget.slot['number']}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (placeName.isNotEmpty)
                          Text(placeName, style: const TextStyle(color: Colors.black87)),
                        if (address.isNotEmpty)
                          Text(address, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        Text(
                          (widget.slot['status'] ?? 'unknown') == 'available' ? 'Available' : 'Occupied',
                          style: TextStyle(
                            color: (widget.slot['status'] ?? 'unknown') == 'available' ? Colors.green : Colors.red,
                          ),
                        ),
                        if ((widget.slot['status'] ?? 'unknown') == 'maintenance')
                          const Text('Maintenance', style: TextStyle(color: Colors.blue)),
                      ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Date and Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      _selectedDate == null
                          ? 'Select Date'
                          : DateFormat.yMMMd().format(_selectedDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectStartTime(context),
                    child: Text(
                      _startTime == null
                          ? 'Start Time'
                          : _startTime!.format(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _selectEndTime(context),
              child: Text(
                _endTime == null
                    ? 'End Time'
                    : _endTime!.format(context),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _proceedToConfirmation,
                child: _isLoading 
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : const Text('Continue to Payment', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage(dynamic src) {
    final value = src?.toString() ?? '';
    if (value.startsWith('assets/')) {
      return Image.asset(
        value,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackHeader(),
      );
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Image.network(
        value,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackHeader(),
      );
    }
    return _fallbackHeader();
  }

  Widget _fallbackHeader() {
    return Image.network(
      'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?q=80&w=1600&auto=format&fit=crop',
      fit: BoxFit.cover,
    );
  }
}