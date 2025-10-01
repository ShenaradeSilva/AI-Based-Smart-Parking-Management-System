import 'package:flutter/material.dart';

class ParkingSlotCard extends StatelessWidget {
  final Map<String, dynamic> slot;
  final VoidCallback onTap;

  const ParkingSlotCard({
    super.key,
    required this.slot,
    required this.onTap,
  });

  Color _bgColor() {
    switch (slot['status'] ?? 'unknown') {
      case 'available':
        return Colors.green.withOpacity(0.12);
      case 'occupied':
        return Colors.red.withOpacity(0.12);
      case 'maintenance':
        return Colors.blue.withOpacity(0.12);
      default:
        return Colors.grey.withOpacity(0.12);
    }
  }

  Color _accent() {
    switch (slot['status'] ?? 'unknown') {
      case 'available':
        return Colors.green;
      case 'occupied':
        return Colors.red;
      case 'maintenance':
        return Colors.blue;
      default:
        return const Color.fromARGB(255, 158, 158, 158);
    }
  }

  String _label() {
    switch (slot['status'] ?? 'unknown') {
      case 'available':
        return 'Available';
      case 'occupied':
        return 'Occupied';
      case 'maintenance':
        return 'Maintenance';
      default:
        return 'Unknown';
    }
  }

  IconData _icon() {
    switch (slot['status'] ?? 'unknown') {
      case 'available':
        return Icons.local_parking;
      case 'occupied':
        return Icons.block;
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.help_outline;
    }
  }

  bool get _enabled => (slot['status'] ?? 'unknown') == 'available';

  @override
  Widget build(BuildContext context) {
    final bg = _bgColor();
    final accent = _accent();

    return Card(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_icon(), size: 28, color: accent),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                slot['number'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _label(),
                style: TextStyle(color: accent, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
