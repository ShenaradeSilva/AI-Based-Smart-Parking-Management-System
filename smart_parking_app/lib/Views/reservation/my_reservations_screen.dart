import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../qr_code_screen.dart';
import '../parking/parking_map_screen.dart';

// Brand palette aligned with dashboard
const Color kPrimary = Color(0xFF1E3A8A); // Navy
const Color kBg = Color(0xFFF5F7FB); // Soft background
const Color kSuccess = Color(0xFF10B981); // Emerald
const Color kDanger = Color(0xFFDC2626); // Red
const Color kWarning = Color(0xFFF59E0B); // Amber

class MyReservationsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> activeReservations;
  const MyReservationsScreen({super.key, required this.activeReservations});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  late List<Map<String, dynamic>> _reservations;

  String _formatSlot(dynamic slot) {
    final s = (slot ?? '').toString().trim();
    return s.toUpperCase();
  }

  Future<String> _bestLocationImagePath(Map<String, dynamic> r) async {
    final loc = _parseLocation(r['location'], name: r['locationName'], area: r['locationArea']);
    final name = (loc['name'] ?? '').toLowerCase();
    String inferred = 'CCC.jpg';
    if (name.contains('one galle face')) inferred = 'OGF.jpg';
    if (name.contains('marino mall')) inferred = 'MC.jpg';

    final candidates = <String?>[
      (r['imageAsset'] ?? r['locationImage'])?.toString(),
      'assets/locations/$inferred',
      'assets/images/$inferred',
      'assets/$inferred',
      'assets/locations/CCC.jpg',
      'assets/images/CCC.jpg',
      'assets/CCC.jpg',
    ];
    for (final p in candidates) {
      if (p == null || p.isEmpty) continue;
      try {
        await rootBundle.load(p);
        return p;
      } catch (_) {}
    }
    return 'assets/locations/CCC.jpg';
  }

  ImageProvider _reservationImage(Map<String, dynamic> r) {
    final explicit = (r['imageAsset'] ?? r['locationImage'] ?? '').toString();
    if (explicit.isNotEmpty) return AssetImage(explicit);
    final loc = _parseLocation(r['location'], name: r['locationName'], area: r['locationArea']);
    final name = (loc['name'] ?? '').toLowerCase();
    if (name.contains('one galle face')) {
      return const AssetImage('assets/locations/OGF.jpg');
    }
    if (name.contains('marino mall')) {
      return const AssetImage('assets/locations/MC.jpg');
    }
    return const AssetImage('assets/locations/CCC.jpg');
  }

  String _formatZone(dynamic zone) {
    final z = (zone ?? '').toString().trim();
    if (z.isEmpty) return 'Unknown Zone';
    return 'Zone $z';
  }

  // Returns a tuple-like map with name and area derived from location fields
  Map<String, String> _parseLocation(dynamic location, {dynamic name, dynamic area}) {
    final explicitName = (name ?? '').toString().trim();
    final explicitArea = (area ?? '').toString().trim();
    if (explicitName.isNotEmpty || explicitArea.isNotEmpty) {
      return {
        'name': explicitName,
        'area': explicitArea,
      };
    }
    final raw = (location ?? '').toString().trim();
    if (raw.isEmpty) return {'name': '', 'area': ''};
    // Split by comma to extract name and area e.g., "One Galle Face, City Center"
    final parts = raw.split(',');
    final namePart = parts.isNotEmpty ? parts.first.trim() : '';
    final areaPart = parts.length > 1 ? parts.sublist(1).join(',').trim() : '';
    return {
      'name': namePart,
      'area': areaPart,
    };
  }

  @override
  void initState() {
    super.initState();
    _reservations = List.from(widget.activeReservations);
  }

  Future<void> _refresh() async {
    // TODO: hook up to backend. For now, simulate a short refresh.
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> get _currentReservations {
    final now = DateTime.now();
    return _reservations.where((r) {
      final d = r['date'] is DateTime
          ? (r['date'] as DateTime)
          : DateTime.tryParse(r['date']?.toString() ?? '') ?? now;
      return !d.isAfter(now); // today or past = current/ongoing
    }).toList();
  }

  List<Map<String, dynamic>> get _upcomingReservations {
    final now = DateTime.now();
    return _reservations.where((r) {
      final d = r['date'] is DateTime
          ? (r['date'] as DateTime)
          : DateTime.tryParse(r['date']?.toString() ?? '') ?? now;
      return d.isAfter(now);
    }).toList();
  }

  void _cancelReservation(Map<String, dynamic> r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel reservation?'),
        content: Text(
            'Spot ${r['slotNumber']} (Zone ${r['zone']}) on ${DateFormat.MMMd().format(r['date'])}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, cancel')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _reservations.remove(r));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation cancelled'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _modifyReservation(Map<String, dynamic> r) async {
    final start = await showTimePicker(
      context: context,
      initialTime: _parseTime(r['startTime']) ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (start == null) return;
    final end = await showTimePicker(
      context: context,
      initialTime: _parseTime(r['endTime']) ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (end == null) return;

    setState(() {
      r['startTime'] = start.format(context);
      r['endTime'] = end.format(context);
      r['updatedAt'] = DateTime.now().toIso8601String();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation updated'), backgroundColor: Colors.green),
      );
    }
  }

  TimeOfDay? _parseTime(dynamic val) {
    try {
      if (val is String && val.contains(':')) {
        final parts = val.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 360;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        title: const Text(
          'My Reservations',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_currentReservations.isNotEmpty) ...[
              const Text('Current', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              const Divider(height: 1),
              const SizedBox(height: 8),
              ..._currentReservations.map((r) => _buildDismissibleTile(r, isUpcoming: false, isCompact: isCompact)),
              const SizedBox(height: 16),
            ],
            const Text('Upcoming', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
            const SizedBox(height: 6),
            const Divider(height: 1),
            const SizedBox(height: 8),
            if (_upcomingReservations.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_parking_rounded, color: kPrimary, size: 40),
                    const SizedBox(height: 8),
                    const Text('No upcoming reservations', style: TextStyle(color: Color(0xFF64748B))),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ParkingMapScreen()),
                        );
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Find Parking'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._upcomingReservations.map((r) => _buildDismissibleTile(r, isUpcoming: true, isCompact: isCompact)),
          ],
        ),
      ),
    );
  }

  // Swipeable wrapper for modify/cancel actions
  Widget _buildDismissibleTile(Map<String, dynamic> r, {required bool isUpcoming, required bool isCompact}) {
    return Dismissible(
      key: ValueKey('res-${r['id']}-${r['slotNumber']}'),
      background: _buildSwipeBackground(Icons.edit_calendar_rounded, 'Modify', kPrimary, Alignment.centerLeft),
      secondaryBackground: _buildSwipeBackground(Icons.cancel_rounded, 'Cancel', kDanger, Alignment.centerRight),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _modifyReservation(r);
          return false; // don't dismiss
        } else {
          _cancelReservation(r);
          return false;
        }
      },
      child: _buildReservationTile(r, isUpcoming: isUpcoming, isCompact: isCompact),
    );
  }

  Widget _buildSwipeBackground(IconData icon, String label, Color color, Alignment alignment) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildReservationTile(Map<String, dynamic> r, {required bool isUpcoming, required bool isCompact}) {
    final date = r['date'] is DateTime ? (r['date'] as DateTime) : DateTime.tryParse(r['date']?.toString() ?? '');
    final formattedDate = date != null ? DateFormat.MMMd().format(date) : '';
    final updatedAt = DateTime.tryParse((r['updatedAt'] ?? '').toString());
    final isRecentlyUpdated = updatedAt != null && DateTime.now().difference(updatedAt) <= const Duration(minutes: 10);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRecentlyUpdated ? kSuccess.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))],
        border: isRecentlyUpdated ? Border.all(color: kSuccess.withOpacity(0.25)) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FutureBuilder<String>(
                  future: _bestLocationImagePath(r),
                  builder: (context, snap) {
                    final path = snap.data;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: path == null
                          ? Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey.withOpacity(0.1),
                              alignment: Alignment.center,
                              child: const Icon(Icons.location_on_rounded, color: Colors.grey, size: 20),
                            )
                          : Image.asset(
                              path,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey.withOpacity(0.1),
                                alignment: Alignment.center,
                                child: const Icon(Icons.location_on_rounded, color: Colors.grey, size: 20),
                              ),
                            ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location: Name and Area formatted like "One Galle Face, City Center"
                      Builder(
                        builder: (_) {
                          final loc = _parseLocation(
                            r['location'],
                            name: r['locationName'],
                            area: r['locationArea'],
                          );
                          final name = loc['name'] ?? '';
                          final area = loc['area'] ?? '';
                          if (name.isEmpty && area.isEmpty) {
                            // Fallback to Slot as title if no location
                            return Text(
                              'Slot ${_formatSlot(r['slotNumber'])}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                                fontSize: 16,
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Slot: ${_formatSlot(r['slotNumber'])}',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$formattedDate • ${r['startTime']} - ${r['endTime']}',
                        style: const TextStyle(color: Color(0xFF607D8B), fontSize: 13),
                      ),
                      if ((r['location'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.place_rounded, size: 18, color: Color(0xFF475569)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                r['location'].toString(),
                                style: const TextStyle(color: Color(0xFF475569), fontSize: 14, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: kWarning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    tooltip: 'QR Code',
                    icon: const Icon(Icons.qr_code_scanner_rounded, color: kWarning),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => QrCodeScreen(reservation: r)),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Status + Updated chips
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isUpcoming ? kPrimary : kSuccess).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: (isUpcoming ? kPrimary : kSuccess).withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isUpcoming ? Icons.schedule_rounded : Icons.check_circle_rounded,
                        size: 16, color: isUpcoming ? kPrimary : kSuccess),
                    const SizedBox(width: 6),
                    Text(isUpcoming ? 'Upcoming' : 'Active',
                        style: TextStyle(color: isUpcoming ? kPrimary : kSuccess, fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
              ),
            ),
            if (isRecentlyUpdated) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kSuccess.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: kSuccess.withOpacity(0.25)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.update_rounded, size: 16, color: kSuccess),
                      SizedBox(width: 6),
                      Text('Updated', style: TextStyle(color: kSuccess, fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _modifyReservation(r),
                  icon: Icon(Icons.edit_calendar_rounded, color: kPrimary, size: isCompact ? 18 : 20),
                  label: Text('Modify', style: TextStyle(color: kPrimary, fontSize: isCompact ? 12 : 14)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kPrimary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 14, vertical: isCompact ? 8 : 10),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _cancelReservation(r),
                  icon: Icon(Icons.cancel_rounded, size: isCompact ? 18 : 20),
                  label: Text('Cancel', style: TextStyle(fontSize: isCompact ? 12 : 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDanger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 14, vertical: isCompact ? 10 : 12),
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
