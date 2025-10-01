import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'booking_screen.dart';
import 'parking_map_screen.dart';

class ParkingPlaceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> slot;
  const ParkingPlaceDetailScreen({super.key, required this.slot});
  @override
  Widget build(BuildContext context) {
    final imageUrl = slot['imageUrl'] as String?;
    final placeName = (slot['placeName'] as String?) ?? 'Metro Shopping Complex';
    final price = (slot['price'] as num?)?.toStringAsFixed(2) ?? '10.00';
    final rating = (slot['rating'] as num?)?.toDouble() ?? 4.0;
    final distanceKm = (slot['distanceKm'] as num?)?.toStringAsFixed(2) ?? '0.56';
    final address = (slot['address'] as String?) ?? 'Metro Shopping Complex, Divaka';
    final List<dynamic> reviews = (slot['reviews'] as List<dynamic>?) ?? const [];
    final priceText = 'RS $price';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: const Color(0xFF5B45D6),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border_rounded),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'place-image-${placeName.hashCode}',
                    child: _HeaderImage(imageUrl: imageUrl),
                  ),
                  // Gradient overlay for readability
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          placeName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      Text(
                        priceText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF5B45D6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating and meta
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        final full = rating.floor();
                        if (i < full) {
                          return const Icon(Icons.star, color: Color(0xFFFFB020), size: 18);
                        }
                        return const Icon(Icons.star_border, color: Color(0xFFFFB020), size: 18);
                      }),
                      const SizedBox(width: 8),
                      Text(rating.toStringAsFixed(1), style: const TextStyle(color: Color(0xFF6B7280))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Color(0xFF6B7280), size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$address • $distanceKm Km Away',
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),

                  // Feedback header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Feedback (10)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Feedback items
                  if (reviews.isEmpty) ...[
                    const Text('No feedback yet', style: TextStyle(color: Color(0xFF6B7280))),
                  ] else ...[
                    ...reviews.take(2).map((r) => _FeedbackTile(
                          name: (r['name'] as String?) ?? 'User',
                          comment: (r['comment'] as String?) ?? '',
                        )),
                  ],
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See all Feedbacks'),
                  ),

                  const SizedBox(height: 8),
                  const Text('Around this parking',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          if (slot['lat'] != null && slot['lng'] != null)
                            FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng((slot['lat'] as num).toDouble(), (slot['lng'] as num).toDouble()),
                                initialZoom: 15,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'smart_parking_app',
                                ),
                                MarkerLayer(markers: [
                                  Marker(
                                    point: LatLng((slot['lat'] as num).toDouble(), (slot['lng'] as num).toDouble()),
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.topCenter,
                                    child: const Icon(Icons.location_pin, size: 40, color: Color(0xFFE53935)),
                                  ),
                                ]),
                              ],
                            )
                          else
                            Image.asset(
                              'assets/images/map_placeholder.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE5E7EB)),
                            ),

                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final num? lat = slot['lat'] as num?;
                                final num? lng = slot['lng'] as num?;
                                final String? placeId = slot['placeId'] as String?;
                                final encodedAddress = Uri.encodeComponent(address);

                                Uri uri;
                                if (lat != null && lng != null) {
                                  final dest = '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}';
                                  uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$dest&travelmode=driving&dir_action=navigate');
                                } else if (placeId != null && placeId.isNotEmpty) {
                                  uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination_place_id=$placeId&travelmode=driving&dir_action=navigate');
                                } else {
                                  uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$encodedAddress&travelmode=driving&dir_action=navigate');
                                }

                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53935),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                elevation: 4,
                                shadowColor: const Color(0xFFE53935).withOpacity(0.4),
                              ),
                              icon: const Icon(Icons.directions_rounded, size: 18),
                              label: const Text('Get Direction', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80), // space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
            ],
          ),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B45D6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Go to the slot selection screen for this place instead of
                // directly opening BookingScreen with an incomplete "slot" map.
                // This avoids "Book null / Slot null" issues and matches the
                // flow: Location -> Place details -> Choose a slot -> Book.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ParkingMapScreen(showAppBar: true, place: slot),
                  ),
                );
              },
              child: const Text('Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  final String? imageUrl;
  const _HeaderImage({required this.imageUrl});

  bool get _isAsset => imageUrl != null && imageUrl!.startsWith('assets/');
  bool get _isNet => imageUrl != null && (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_isAsset) {
      child = Image.asset(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else if (_isNet) {
      child = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else {
      child = _fallback();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        // subtle top gradient for status bar readability
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black12, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallback() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?q=80&w=1600&auto=format&fit=crop',
          fit: BoxFit.cover,
        ),
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
    );
  }
}

class _FeedbackTile extends StatelessWidget {
  final String name;
  final String comment;
  const _FeedbackTile({required this.name, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 16, backgroundColor: Color(0xFFCBCBEA), child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.star, color: Color(0xFFFFB020), size: 16),
                    Icon(Icons.star, color: Color(0xFFFFB020), size: 16),
                    Icon(Icons.star, color: Color(0xFFFFB020), size: 16),
                    Icon(Icons.star, color: Color(0xFFFFB020), size: 16),
                    Icon(Icons.star_border, color: Color(0xFFFFB020), size: 16),
                  ],
                ),
                const SizedBox(height: 6),
                Text(comment, style: const TextStyle(color: Color(0xFF6B7280))),
              ],
            ),
          )
        ],
      ),
    );
  }
}
