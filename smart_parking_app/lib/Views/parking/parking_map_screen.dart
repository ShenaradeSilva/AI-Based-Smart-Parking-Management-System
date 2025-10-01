import 'package:flutter/material.dart';
import 'parking_slot_card.dart';
import 'booking_screen.dart';
import '../location_search_screen.dart';
import '../../services/parking_service.dart';

class ParkingMapScreen extends StatefulWidget {
  final bool showAppBar;
  final Map<String, dynamic>? place;
  final String? selectedType; // 'car' | 'jeep' | 'van' | 'bike'
  const ParkingMapScreen({super.key, this.showAppBar = true, this.place, this.selectedType});

  @override
  _ParkingMapScreenState createState() => _ParkingMapScreenState();
}

class _TotalBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _TotalBox({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF6C63FF)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final String zone;
  final String number;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;
  const _SlotChip({required this.zone, required this.number, required this.color, required this.enabled, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final bg = color.withOpacity(enabled ? 0.15 : 0.08);
    final textColor = enabled ? color : Colors.grey;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(zone, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Text(number, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ParkingMapScreenState extends State<ParkingMapScreen>
    with TickerProviderStateMixin {
  late List<Map<String, dynamic>> _parkingSlots;

  List<Map<String, dynamic>> _filteredSlots = [];
  String _searchQuery = '';
  String _selectedFloor = '1st Floor';
  final List<String> _floors = const ['1st Floor', '2nd Floor'];
  late final AnimationController _pulseController;
  late final TabController _tabController;
  bool _loading = true;
  String? _error;
  String? _selectedType; // optional filter for a single vehicle type

  @override
  void initState() {
    super.initState();
    _parkingSlots = [];
    _filteredSlots = [];
    _selectedType = widget.selectedType; // carry over from navigation if provided
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _tabController = TabController(length: _floors.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _selectedFloor = _floors[_tabController.index];
        _loadSlots();
      });
    });

    // initial load
    _loadSlots();
  }
  
  Widget _buildTotalsRow() {
    final byFloor = _filteredSlots;
    final car = byFloor.where((s) => s['type'] == 'car').toList();
    final bike = byFloor.where((s) => s['type'] == 'bike').toList();
    int availableCount(List<Map<String, dynamic>> list) =>
        list.where((s) => s['status'] == 'available').length;

    // Totals based on place capacities if provided, otherwise derived from loaded data
    final int totalCar = (widget.place?['carSlots'] as int?) ??
        _parkingSlots.where((s) => s['type'] == 'car' && s['floor'] == _selectedFloor).length;
    final int totalBike = (widget.place?['bikeSlots'] as int?) ??
        _parkingSlots.where((s) => s['type'] == 'bike' && s['floor'] == _selectedFloor).length;
    final carText = '${availableCount(car)} / $totalCar';
    final bikeText = '${availableCount(bike)} / $totalBike';

    const carColor = Color(0xFF6366F1);  // indigo
    const bikeColor = Color(0xFF22C55E); // green

    return Row(
      children: [
        Expanded(child: _totalTile('Car', carText, carColor, icon: Icons.directions_car)),
        const SizedBox(width: 12),
        Expanded(child: _totalTile('Bike', bikeText, bikeColor, icon: Icons.pedal_bike)),
      ],
    );
  }

  Widget _totalTile(String label, String value, Color accent, {IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF9FAFB)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: Offset(0, 8)),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withOpacity(0.22), accent.withOpacity(0.12)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalCard(IconData icon, String label, String value) {
    const Color accent = Color(0xFF6366F1); // soft indigo like earlier look
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotWrap(String type) {
    final items = _filteredSlots.where((s) => s['type'] == type).toList();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((slot) {
        final status = slot['status'] as String;
        final color = status == 'available'
            ? const Color(0xFF10D417)
            : status == 'occupied'
                ? const Color(0xFFF82E20)
                : const Color(0xFF1C98FE);
        return _SlotChip(
          zone: slot['zone'],
          number: slot['number'],
          color: color,
          enabled: status == 'available',
          onTap: () {
            if (status == 'available') {
              // Merge place metadata (if provided) into the slot payload
              final enrichedSlot = {
                ...slot,
                if (widget.place != null) ...{
                  'placeName': widget.place!['placeName'] ?? widget.place!['name'],
                  'imageUrl': widget.place!['imageUrl'] ?? widget.place!['image'],
                  'address': widget.place!['address'],
                },
              };
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingScreen(slot: enrichedSlot),
                ),
              );
            }
          },
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _filterSlots(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      final byFloor = _parkingSlots.where((s) => s['floor'] == _selectedFloor);
      _filteredSlots = _searchQuery.isEmpty
          ? byFloor.toList()
          : byFloor
              .where((slot) =>
                  (slot['number']?.toString().toLowerCase() ?? '').contains(_searchQuery) ||
                  ((slot['zone'] as String?)?.toLowerCase() ?? '').contains(_searchQuery))
              .toList();
    });
  }

  void _onFloorChanged(String? floor) {
    if (floor == null) return;
    setState(() {
      _selectedFloor = floor;
      _loadSlots();
    });
  }

  // Generate slots that respect per-location capacities (Car & Bike only)
  List<Map<String, dynamic>> _generateSlots() {
    final List<Map<String, dynamic>> slots = [];
    final floors = _floors; // e.g., ['1st Floor','2nd Floor']
    final zones = ['A', 'B', 'C', 'D'];

    // Per-location capacities; if not provided, fall back to reasonable defaults
    final int totalCar = (widget.place?['carSlots'] as int?) ?? 60;
    final int totalBike = (widget.place?['bikeSlots'] as int?) ?? 30;

    // Distribute capacities evenly across floors (last floor gets the remainder)
    int perFloor(int total, int floorIndex, int floorCount) {
      final base = total ~/ floorCount;
      final rem = total % floorCount;
      return base + (floorIndex < rem ? 1 : 0);
    }

    // Seed pattern so availability differs by place
    final placeKey = (widget.place != null)
        ? (widget.place!['id']?.toString() ?? widget.place!['placeName'] ?? widget.place!['name'] ?? '')
        : '';
    final seed = placeKey.hashCode.abs();

    for (int fi = 0; fi < floors.length; fi++) {
      final floor = floors[fi];

      for (final type in ['car', 'bike']) {
        final totalForType = type == 'car' ? totalCar : totalBike;
        final countForFloor = perFloor(totalForType, fi, floors.length);

        int number = 101; // Slot number start per type per floor
        for (int i = 0; i < countForFloor; i++) {
          final idx = i + (seed % 7);
          String status;
          if (idx % 9 == 0) {
            status = 'maintenance';
          } else if (idx % 4 == 0) {
            status = 'occupied';
          } else {
            status = 'available';
          }
          final zone = zones[i % zones.length];
          slots.add({
            'floor': floor,
            'type': type,
            'zone': zone,
            'number': number.toString(),
            'status': status,
            'placeKey': placeKey,
          });
          number++;
        }
      }
    }

    return slots;
  }

  Future<void> _loadSlots() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lotId = widget.place != null
          ? (widget.place!['id']?.toString() ?? widget.place!['placeName'] ?? widget.place!['name'])
          : null;
      final resp = await ParkingService.fetchSlots(floor: _selectedFloor, lotId: lotId?.toString());
      if (resp['success'] == true && resp['data'] is List) {
        final List data = resp['data'];
        // ensure map<String,dynamic>
        _parkingSlots = data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
        _filterSlots(_searchQuery);
        _error = null;
      } else {
        // Fallback to local generator so UI still works offline
        _parkingSlots = _generateSlots();
        _filterSlots(_searchQuery);
        _error = null; // show fallback instead of error text
      }
    } catch (e) {
      // Network failure: fallback to local generator
      _error = null; // show fallback instead of error text
      _parkingSlots = _generateSlots();
      _filterSlots(_searchQuery);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.showAppBar
          ? AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 29, 9, 73),
        title: Text(
          widget.place != null
              ? 'Slots - ' + ((widget.place!['placeName'] ?? widget.place!['name'] ?? 'Parking Map').toString())
              : 'Parking Map',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationSearchScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: _floors.map((f) => Tab(text: f)).toList(),
        ),
      )
          : null,
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 46, 19, 108),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for parking spots... (e.g., A1, Zone B)',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 24,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: _filterSlots,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
          ),

          // Quick action to search locations
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.location_on, color: Color.fromARGB(255, 36, 8, 99)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationSearchScreen(),
                    ),
                  );
                },
              ),
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: const [
                _LegendDot(color: Color(0xFF10D417), label: 'Available'),
                SizedBox(width: 12),
                _LegendDot(color: Color(0xFFF82E20), label: 'Occupied'),
                SizedBox(width: 12),
                _LegendDot(color: Color(0xFF1C98FE), label: 'Maintenance'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Parking Slots Sections (Chips) like the mockup
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _filteredSlots.isEmpty
                        ? const Center(child: Text('No parking spots found'))
                        : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTotalsRow(),
                        const SizedBox(height: 12),
                        const Text('Available Car Slots', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _buildSlotWrap('car'),
                        const SizedBox(height: 16),
                        const Text('Available Bike Slots', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _buildSlotWrap('bike'),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 43, 19, 99).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 42, 13, 110).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color.fromARGB(255, 36, 15, 85),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color.fromARGB(255, 42, 18, 99),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDarkMapHero() {
    // Return an empty widget to prevent 'Null is not a subtype of Widget' if called
    return const SizedBox.shrink();
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
