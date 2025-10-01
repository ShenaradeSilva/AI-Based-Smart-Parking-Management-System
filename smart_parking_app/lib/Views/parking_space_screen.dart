import 'package:flutter/material.dart';

class ParkingSpaceScreen extends StatefulWidget {
  const ParkingSpaceScreen({super.key});

  @override
  _ParkingSpaceScreenState createState() => _ParkingSpaceScreenState();
}

class _ParkingSpaceScreenState extends State<ParkingSpaceScreen> {
  int _selectedTabIndex = 0;
  final List<Map<String, dynamic>> _parkingSpaces = [
    {
      'name': 'One Galle Face Mall',
      'address': 'Galle Road, Colombo 03, Sri Lanka',
      'image': 'assets/images/OGF.jpg',
      'amenities': [
        'Near you',
        'Security',
        'Lighting',
        'Emergency Services',
        'CC Camera'
      ],
      'rating': 4.5,
      'price': '\Rs: 100',
      'distance': '0.5 km',
      'availableSlots': 8,
    },
    {
      'name': 'Colombo City Center',
      'address': '45, Main Street, Colombo',
      'image': 'assets/images/CCC.jpg',
      'amenities': ['Security', 'Lighting', 'Emergency Services'],
      'rating': 4.2,
      'price': '\Rs: 200',
      'distance': '1.2 km',
      'availableSlots': 12,
    },
    {
      'name': 'Havelock City',
      'address': 'Havelock Road, Colombo',
      'image': 'assets/images/HC.jpg',
      'amenities': ['Near you', 'Security', 'Lighting', 'CC Camera'],
      'rating': 4.7,
      'price': '\Rs: 800',
      'distance': '0.8 km',
      'availableSlots': 15,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E3A8A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Space Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/parking_garage.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: const Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Central Parking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1F2937), // Dark background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Parking Name and Address
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Central Parking',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  const Expanded(
                                    child: Text(
                                      '17, South central road, Khulna',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.bookmark_border,
                                      color: Color(0xFF10B981),
                                    ),
                                    onPressed: () {
                                      // Bookmark functionality
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Amenities Section
                    const Text(
                      'Amenities',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Near you',
                        'Security',
                        'Lighting',
                        'Emergency Services',
                        'CC Camera',
                      ]
                          .map((amenity) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF374151),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  amenity,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),

                    const SizedBox(height: 24),

                    // Tabs
                    Row(
                      children: [
                        _buildTab('About', 0),
                        const SizedBox(width: 20),
                        _buildTab('Gallery', 1),
                        const SizedBox(width: 20),
                        _buildTab('Review', 2),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Tab Content
                    _buildTabContent(),

                    const SizedBox(height: 30),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/payment-method');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Central Parking is the best choice for your parking needs in the city. It is a convenient and secure parking facility located in the heart of the city. With 24/7 security, CCTV surveillance, and emergency services, you can park your vehicle with complete peace of mind.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• 24/7 Security\n• CCTV Surveillance\n• Emergency Services\n• Well-lit Parking\n• Easy Access\n• Affordable Rates',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.white70,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.white70,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.white70,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            _buildReviewItem('John Doe', 5,
                'Great parking facility with excellent security.'),
            const SizedBox(height: 12),
            _buildReviewItem(
                'Jane Smith', 4, 'Convenient location and reasonable prices.'),
            const SizedBox(height: 12),
            _buildReviewItem(
                'Mike Johnson', 5, 'Clean and well-maintained parking area.'),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildReviewItem(String name, int rating, String comment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF10B981),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(
                          5,
                          (index) => Icon(
                                Icons.star,
                                size: 16,
                                color: index < rating
                                    ? const Color(0xFF10B981)
                                    : Colors.white30,
                              )),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
