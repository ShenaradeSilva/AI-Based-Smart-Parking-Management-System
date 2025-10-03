import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'parking/parking_place_detail_screen.dart';
// import removed: vehicle-specific navigation not used in the earlier version

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _savedLocations = [];
  bool _isSearching = false;

  final List<Map<String, dynamic>> _allLocations = [
    {
      'name': 'One Galle Mall',
      'address': 'Galle road, colombo 03, Sri Lanka',
      'distance': '2.5 km',
      'price': '\\Rs: 700',
      'availableSlots': 15,
      'rating': 4.5,
      'image': 'assets/locations/OGF.jpg',
      'isBookmarked': false,
      'lat': 6.9050,
      'lng': 79.8530,
      'carSlots': 72,
      'bikeSlots': 36,
    },
    {
      'name': 'Colombo City Centre',
      'address': 'Gangaramaya Temple Rd, Colombo 02, Sri Lanka',
      'distance': '2.8 km',
      'price': '\\Rs: 650',
      'availableSlots': 8,
      'rating': 4.2,
      'image': 'assets/locations/CCC.jpg',
      'isBookmarked': false,
      'lat': 6.9205,
      'lng': 79.8568,
      'carSlots': 54,
      'bikeSlots': 28,
    },
    {
      'name': 'Havelock City Mall',
      'address': 'Havelock Rd, Colombo 05, Sri Lanka',
      'distance': '3.2 km',
      'price': '\\Rs: 800',
      'availableSlots': 22,
      'rating': 4.3,
      'image': 'assets/locations/HC.jpg',
      'isBookmarked': true,
      'lat': 6.8779,
      'lng': 79.8654,
      'carSlots': 80,
      'bikeSlots': 40,
    },
    {
      'name': 'Crescat Colombo',
      'address': '81, Galle Rd, Colombo 03, Sri Lanka',
      'distance': '4.1 km',
      'price': '\\Rs: 900',
      'availableSlots': 12,
      'rating': 4.1,
      'image': 'assets/locations/CRC.jpg',
      'isBookmarked': true,
      'lat': 6.9260,
      'lng': 79.8440,
      'carSlots': 60,
      'bikeSlots': 24,
    },
    {
      'name': 'Independence Square',
      'address': '65, Independence Ave, Colombo 07, Sri Lanka',
      'distance': '5.5 km',
      'price': '\\Rs: 600',
      'availableSlots': 18,
      'rating': 4.4,
      'image': 'assets/locations/IS.jpg',
      'isBookmarked': true,
      'lat': 6.9022,
      'lng': 79.8707,
      'carSlots': 48,
      'bikeSlots': 20,
    },
    {
      'name': 'Majestic City',
      'address': '12, Sir James Pieris Mawatha, Colombo 02, Sri Lanka',
      'distance': '1.8 km',
      'price': '\\Rs: 550',
      'availableSlots': 6,
      'rating': 4.0,
      'image': 'assets/locations/MC.jpg',
      'isBookmarked': false,
      'lat': 6.8854,
      'lng': 79.8569,
      'carSlots': 52,
      'bikeSlots': 22,
    },
    {
      'name': 'Liberty Plaza',
      'address': '300, Galle Rd, Colombo 03, Sri Lanka',
      'distance': '2.9 km',
      'price': '\\Rs: 750',
      'availableSlots': 14,
      'rating': 4.6,
      'image': 'assets/locations/LP.jpg',
      'isBookmarked': true,
      'lat': 6.9146,
      'lng': 79.8480,
      'carSlots': 68,
      'bikeSlots': 32,
    },
    {
      'name': 'Hilton Colombo',
      'address':
          '2, Sir Chittampalam A Gardiner Mawatha, Colombo 02, Sri Lanka',
      'distance': '6.2 km',
      'price': '\\Rs: 500.00',
      'availableSlots': 25,
      'rating': 3.9,
      'image': 'assets/locations/HC.jpg',
      'isBookmarked': false,
      'lat': 6.9327,
      'lng': 79.8429,
      'carSlots': 44,
      'bikeSlots': 18,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
    _searchController.addListener(_onSearchChanged);
  }

  // Map UI label to asset file names you provided
  String _vehicleAssetFor(String label) {
    final key = label.trim().toUpperCase();
    switch (key) {
      case 'CAR':
        return 'assets/CARR.jpg'; // per user's filename
      case 'BIKE':
        return 'assets/BIKE.jpg';
      case 'VAN':
        return 'assets/VAN.jpg';
      case 'JEEP':
        return 'assets/JEEP.jpg';
      default:
        return '';
    }
  }

  Widget _vehicleTypeChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: ClipOval(
              child: Builder(
                builder: (_) {
                  final asset = _vehicleAssetFor(label);
                  if (asset.isEmpty) {
                    return Icon(icon, size: 18, color: color);
                  }
                  return Image.asset(
                    asset,
                    width: 26,
                    height: 26,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(icon, size: 18, color: color),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1F2A60),
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // removed vehicle-specific selectors for earlier version

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSavedLocations() {
    setState(() {
      _savedLocations =
          _allLocations.where((location) => location['isBookmarked']).toList();
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _allLocations.where((location) {
        return location['name'].toLowerCase().contains(query) ||
            location['address'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleBookmark(Map<String, dynamic> location) {
    setState(() {
      location['isBookmarked'] = !location['isBookmarked'];
      _loadSavedLocations();
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(location['isBookmarked']
            ? 'Added to bookmarks'
            : 'Removed from bookmarks'),
        backgroundColor: const Color.fromARGB(255, 91, 117, 233),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _bookParking(Map<String, dynamic> location) {
    // Navigate to parking place details first
    final priceStr = (location['price']?.toString() ?? '')
        .replaceAll(RegExp(r'[^0-9\.]'), '');
    final price = double.tryParse(priceStr);
    final distanceStr = (location['distance']?.toString() ?? '')
        .replaceAll(RegExp(r'[^0-9\.]'), '');
    final distanceKm = double.tryParse(distanceStr);

    final slot = <String, dynamic>{
      'placeName': location['name'],
      'address': location['address'],
      'price': price ?? 0.0,
      'rating': location['rating'],
      'distanceKm': distanceKm ?? 0.0,
      'imageUrl': location['image'],
      // optional coordinates if you have them in your data
      'lat': location['lat'],
      'lng': location['lng'],
      // optional reviews
      'reviews': location['reviews'] ?? const [],
      // slot capacities for this place
      'carSlots': location['carSlots'],
      'bikeSlots': location['bikeSlots'],
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParkingPlaceDetailScreen(slot: slot),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 22, 3, 68),
        title: const Text(
          'Find Parking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.white),
            onPressed: () {
              // Show saved locations
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildSavedLocationsSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 21, 5, 59),
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
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for parking locations...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 24,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[400],
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
          ),

          // earlier version had no vehicle selector grid here

          // Vehicle type bar (bigger, colorful)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _vehicleTypeChip('Car', Icons.directions_car, const Color(0xFFEF4444)),
                const SizedBox(width: 10),
                _vehicleTypeChip('Bike', Icons.pedal_bike, const Color(0xFF22C55E)),
                const SizedBox(width: 10),
                _vehicleTypeChip('Van', Icons.local_shipping, const Color(0xFF06B6D4)),
                const SizedBox(width: 10),
                _vehicleTypeChip('Jeep', Icons.directions_car_filled, const Color(0xFF6366F1)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.filter_list,
                      color: Color.fromARGB(255, 35, 11, 91)),
                  onPressed: () {
                    // Show filter options
                    _showFilterOptions();
                  },
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _isSearching ? _buildSearchResults() : _buildLocationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 33, 12, 82).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 34, 12, 86).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color.fromARGB(255, 21, 4, 60),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color.fromARGB(255, 27, 11, 64),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Color.fromARGB(255, 28, 11, 67),
            ),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final location = _searchResults[index];
        return _buildLocationCard(location);
      },
    );
  }

  Widget _buildLocationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allLocations.length,
      itemBuilder: (context, index) {
        final location = _allLocations[index];
        return _buildLocationCard(location);
      },
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _bookParking(location),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Location Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: _buildLocationImage(location['image']),
                  ),
                ),
                const SizedBox(width: 16),
                // Location Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location['address'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location['distance'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location['rating'].toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Price and Actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      location['price'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 37, 12, 94),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            location['isBookmarked']
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: location['isBookmarked']
                                ? const Color.fromARGB(255, 32, 15, 72)
                                : Colors.grey[400],
                          ),
                          onPressed: () => _toggleBookmark(location),
                        ),
                        ElevatedButton(
                          onPressed: () => _bookParking(location),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 33, 16, 72),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedLocationsSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saved Locations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _savedLocations.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 64,
                          color: Color.fromARGB(255, 38, 16, 89),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No saved locations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Bookmark locations to save them here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _savedLocations.length,
                    itemBuilder: (context, index) {
                      final location = _savedLocations[index];
                      return _buildLocationCard(location);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Price Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            // Add price range slider here
            const Text(
              'Distance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            // Add distance slider here
            const Text(
              'Availability',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            // Add availability options here
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Apply filters
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationImage(dynamic src) {
    final value = src?.toString() ?? '';
    if (value.isNotEmpty && value.startsWith('assets/')) {
      // Try the provided asset path first
      return Image.asset(
        value,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          // If it fails, try an alternate path using just the file name under assets/
          final parts = value.split('/');
          final fileName = parts.isNotEmpty ? parts.last : value;
          final altPath = 'assets/$fileName';
          // Print a debug line to help identify missing assets on web
          // ignore: avoid_print
          print('Image not found at "$value". Trying fallback "$altPath"');
          return Image.asset(
            altPath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              // ignore: avoid_print
              print('Image also not found at "$altPath". Showing placeholder.');
              return _fallbackThumb();
            },
          );
        },
      );
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Image.network(
        value,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackThumb(),
      );
    }
    return _fallbackThumb();
  }

  Widget _fallbackThumb() {
    return Container(
      color: const Color(0xFFEAEAF4),
      child: const Center(
        child: Icon(Icons.image, color: Color(0xFF9AA1B1)),
      ),
    );
  }
}
