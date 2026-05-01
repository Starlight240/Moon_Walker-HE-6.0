import 'dart:math';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

enum BortleClass { one, two, three, four }

enum _LocationStatus { idle, loading, granted, failed }

class DarkSkySpot {
  final String id;
  final String name;
  final String region;
  final String description;
  final LatLng position;
  final BortleClass bortle;
  final double elevationM;
  final List<String> bestFor;
  final String accessNote;

  const DarkSkySpot({
    required this.id, required this.name, required this.region,
    required this.description, required this.position, required this.bortle,
    required this.elevationM, required this.bestFor, required this.accessNote,
  });

  String get bortleLabel {
    switch (bortle) {
      case BortleClass.one:   return 'Bortle 1';
      case BortleClass.two:   return 'Bortle 2';
      case BortleClass.three: return 'Bortle 3';
      case BortleClass.four:  return 'Bortle 4';
    }
  }

  Color get bortleColor {
    switch (bortle) {
      case BortleClass.one:   return const Color(0xFF7EB8F7);
      case BortleClass.two:   return const Color(0xFF88E0B0);
      case BortleClass.three: return const Color(0xFFE8C87A);
      case BortleClass.four:  return const Color(0xFFFFAA66);
    }
  }

  String get bortleDescription {
    switch (bortle) {
      case BortleClass.one:   return 'Pristine dark sky — zodiacal light casts shadows';
      case BortleClass.two:   return 'Truly dark sky — Milky Way highly structured';
      case BortleClass.three: return 'Rural sky — Milky Way clearly visible';
      case BortleClass.four:  return 'Rural/suburban transition — good naked-eye sky';
    }
  }
}

class _County {
  final String name;
  final double lat;
  final double lng;
  const _County(this.name, this.lat, this.lng);
}

const List<_County> kRomanianCounties = [
  _County('Alba', 46.0697, 23.5805),
  _County('Arad', 46.1866, 21.3123),
  _County('Arges', 44.8565, 24.8700),
  _County('Bacau', 46.5670, 26.9146),
  _County('Bihor', 47.0469, 21.9189),
  _County('Bistrita-Nasaud', 47.1300, 24.4960),
  _County('Botosani', 47.7333, 26.6667),
  _County('Brasov', 45.6427, 25.5887),
  _County('Braila', 45.2692, 27.9574),
  _County('Bucuresti', 44.4268, 26.1025),
  _County('Buzau', 45.1500, 26.8167),
  _County('Caras-Severin', 45.2980, 21.9020),
  _County('Calarasi', 44.2070, 27.3310),
  _County('Cluj', 46.7712, 23.6236),
  _County('Constanta', 44.1598, 28.6348),
  _County('Covasna', 45.8500, 26.1833),
  _County('Dambovita', 44.9261, 25.4586),
  _County('Dolj', 44.3302, 23.7949),
  _County('Galati', 45.4353, 28.0080),
  _County('Giurgiu', 43.9037, 25.9699),
  _County('Gorj', 44.9520, 23.3340),
  _County('Harghita', 46.3500, 25.8000),
  _County('Hunedoara', 45.7155, 22.9156),
  _County('Ialomita', 44.6000, 27.3833),
  _County('Iasi', 47.1585, 27.6014),
  _County('Ilfov', 44.5000, 26.1167),
  _County('Maramures', 47.6597, 23.5687),
  _County('Mehedinti', 44.6333, 22.6500),
  _County('Mures', 46.5386, 24.5575),
  _County('Neamt', 46.9759, 26.3819),
  _County('Olt', 44.4333, 24.3667),
  _County('Prahova', 44.9451, 26.0131),
  _County('Satu Mare', 47.7931, 22.8866),
  _County('Salaj', 47.1867, 23.0581),
  _County('Sibiu', 45.7983, 24.1256),
  _County('Suceava', 47.6514, 26.2556),
  _County('Teleorman', 44.0000, 25.3833),
  _County('Timis', 45.7537, 21.2257),
  _County('Tulcea', 45.1787, 28.8018),
  _County('Vaslui', 46.6407, 27.7276),
  _County('Valcea', 45.1000, 24.3667),
  _County('Vrancea', 45.7000, 27.1833),
];

const List<DarkSkySpot> kRomanianDarkSkySpots = [
  DarkSkySpot(
    id: 'apuseni', name: 'Apuseni Natural Park', region: 'Bihor / Cluj',
    description: 'One of Romania\'s darkest accessible regions. The limestone plateaus above 1400 m offer panoramic 360° views with virtually no light pollution.',
    position: LatLng(46.630, 22.680), bortle: BortleClass.two, elevationM: 1420,
    bestFor: ['Milky Way', 'Deep-sky objects', 'Meteor showers'],
    accessNote: 'Accessible by 4x4 via Stana de Vale or Pietroasa roads. Camping at Cabana Padis.',
  ),
  DarkSkySpot(
    id: 'retezat', name: 'Retezat National Park', region: 'Hunedoara',
    description: 'The highest and most remote dark sky site in Romania. Above 2000 m, the air is exceptionally clear and the horizon stretches unbroken.',
    position: LatLng(45.360, 22.890), bortle: BortleClass.one, elevationM: 2150,
    bestFor: ['Milky Way core', 'Galaxies', 'Globular clusters', 'Astrophotography'],
    accessNote: 'Accessible via Campusel or Ranca. Requires 2-4 hr hike to prime spots.',
  ),
  DarkSkySpot(
    id: 'bucegi', name: 'Bucegi Plateau', region: 'Prahova / Dambovita',
    description: 'The high plateau above 2000 m is surprisingly dark for its proximity to Bucharest. Cable car access makes it uniquely convenient.',
    position: LatLng(45.405, 25.458), bortle: BortleClass.three, elevationM: 2060,
    bestFor: ['Milky Way', 'Planets', 'Conjunctions'],
    accessNote: 'Cable car from Busteni or Sinaia. Overnight stay required at plateau cabins.',
  ),
  DarkSkySpot(
    id: 'fagaras', name: 'Fagaras — Balea Lac', region: 'Sibiu',
    description: 'The glacial lake at 2034 m sits in a natural bowl blocking low-horizon light. The Transfagarasan road provides car access in summer.',
    position: LatLng(45.601, 24.617), bortle: BortleClass.two, elevationM: 2034,
    bestFor: ['Wide-field astrophotography', 'Milky Way', 'Aurora (rare)'],
    accessNote: 'Drive up Transfagarasan (open Jun-Oct). Cabin accommodation at Balea Lac.',
  ),
  DarkSkySpot(
    id: 'ceahlau', name: 'Ceahlau Massif', region: 'Neamt',
    description: 'The Holy Mountain of Moldova offers a dark sky window toward the east, away from larger cities. A truly spiritual stargazing experience.',
    position: LatLng(46.980, 25.950), bortle: BortleClass.two, elevationM: 1907,
    bestFor: ['Milky Way', 'Deep-sky', 'Wide-angle'],
    accessNote: 'Marked trails from Durau or Bicaz-Chei. Mountain cabins open year-round.',
  ),
  DarkSkySpot(
    id: 'delta', name: 'Danube Delta — Sfantu Gheorghe', region: 'Tulcea',
    description: 'Completely flat at sea level, with a 360° horizon over water and reeds. Stars appear to touch the water. UNESCO Biosphere Reserve.',
    position: LatLng(44.893, 29.600), bortle: BortleClass.two, elevationM: 2,
    bestFor: ['Horizon-grazing planets', 'Milky Way reflections', 'Meteor showers'],
    accessNote: 'By boat from Tulcea (2-3 hr). Village accommodation available.',
  ),
  DarkSkySpot(
    id: 'rarau', name: 'Rarau-Giumalau Massif', region: 'Suceava',
    description: 'Bortle 2 skies with easy car access to 1650 m. The Pietrele Doamnei rock formations create a dramatic foreground for astrophotography.',
    position: LatLng(47.440, 25.570), bortle: BortleClass.two, elevationM: 1651,
    bestFor: ['Milky Way', 'Star trails', 'Wide-angle landscape'],
    accessNote: 'Paved road to Cabana Rarau from Campulung Moldovenesc. Open year-round.',
  ),
  DarkSkySpot(
    id: 'domogled', name: 'Domogled – Cerna Valley', region: 'Caras-Severin',
    description: 'The Cerna gorge blocks light pollution while ridge tops give spectacular southern-sky views. Baile Herculane spa town is nearby.',
    position: LatLng(44.890, 22.580), bortle: BortleClass.two, elevationM: 1105,
    bestFor: ['Southern constellations', 'Scorpius', 'Sagittarius core'],
    accessNote: 'Trails from Baile Herculane. Summer recommended.',
  ),
  DarkSkySpot(
    id: 'semenic', name: 'Semenic Plateau', region: 'Caras-Severin',
    description: 'One of the lowest light pollution readings of any road-accessible site in Romania. A high plateau with superb westward views.',
    position: LatLng(45.186, 21.993), bortle: BortleClass.one, elevationM: 1446,
    bestFor: ['Pristine Milky Way', 'Faint nebulae', 'Zodiacal light'],
    accessNote: 'Forest road from Resita or Caransebes. Ski lodge accommodation.',
  ),
  DarkSkySpot(
    id: 'hasmas', name: 'Hasmas–Bicaz Gorges', region: 'Harghita / Neamt',
    description: 'Dramatic limestone gorges create natural dark corridors. Alpine meadows above 1400 m are among Transylvania\'s darkest road-accessible spots.',
    position: LatLng(46.780, 25.820), bortle: BortleClass.three, elevationM: 1408,
    bestFor: ['Milky Way', 'Meteor showers', 'Night landscape photography'],
    accessNote: 'Drive DN12C through Bicaz Gorges. Cabins near Lacul Rosu.',
  ),
];

double _haversineKm(LatLng a, LatLng b) {
  const r = 6371.0;
  final dLat = _rad(b.latitude - a.latitude);
  final dLon = _rad(b.longitude - a.longitude);
  final h = sin(dLat / 2) * sin(dLat / 2) +
      cos(_rad(a.latitude)) * cos(_rad(b.latitude)) *
          sin(dLon / 2) * sin(dLon / 2);
  return 2 * r * asin(sqrt(h));
}

double _rad(double d) => d * pi / 180;

String _fmtDist(double km) {
  if (km < 1)  return '${(km * 1000).round()} m';
  if (km < 10) return '${km.toStringAsFixed(1)} km';
  return '${km.round()} km';
}


class DarkSkyMapPage extends StatefulWidget {
  const DarkSkyMapPage({super.key});

  @override
  State<DarkSkyMapPage> createState() => _DarkSkyMapPageState();
}

class _DarkSkyMapPageState extends State<DarkSkyMapPage>
    with TickerProviderStateMixin {

  final MapController _mapController = MapController();

  _LocationStatus _locationStatus = _LocationStatus.idle;
  LatLng? _userLocation;
  LatLng? _referenceLocation;
  String? _referenceLabel;

  bool _showLocationFallback = false;

  DarkSkySpot? _selectedSpot;
  late AnimationController _sheetCtrl;
  late Animation<double> _sheetAnim;

  late AnimationController _fallbackCtrl;
  late Animation<double> _fallbackFade;
  late Animation<Offset> _fallbackSlide;

  List<DarkSkySpot> get _sortedSpots {
    if (_referenceLocation == null) return kRomanianDarkSkySpots;
    final s = [...kRomanianDarkSkySpots];
    s.sort((a, b) => _haversineKm(_referenceLocation!, a.position)
        .compareTo(_haversineKm(_referenceLocation!, b.position)));
    return s;
  }

  @override
  void initState() {
    super.initState();

    _sheetCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _sheetAnim = CurvedAnimation(parent: _sheetCtrl,
        curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

    _fallbackCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fallbackFade = CurvedAnimation(
        parent: _fallbackCtrl, curve: Curves.easeOut);
    _fallbackSlide = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _fallbackCtrl, curve: Curves.easeOutCubic));

    _tryGetLocation();
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    _fallbackCtrl.dispose();
    super.dispose();
  }


  Future<void> _tryGetLocation() async {
    setState(() => _locationStatus = _LocationStatus.loading);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _onLocationFailed();
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _onLocationFailed();
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (!pos.latitude.isFinite || !pos.longitude.isFinite) {
        _onLocationFailed();
        return;
      }

      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _userLocation      = loc;
        _referenceLocation = loc;
        _referenceLabel    = null;
        _locationStatus    = _LocationStatus.granted;
        _showLocationFallback = false;
      });
      _mapController.move(loc, 7.5);
    } catch (_) {
      _onLocationFailed();
    }
  }

  void _onLocationFailed() {
    setState(() {
      _locationStatus       = _LocationStatus.failed;
      _showLocationFallback = true;
    });
    _fallbackCtrl.forward(from: 0);
  }

  void _onCountySelected(_County county) {
    final loc = LatLng(county.lat, county.lng);
    setState(() {
      _referenceLocation    = loc;
      _referenceLabel       = county.name;
      _showLocationFallback = false;
      _locationStatus       = _LocationStatus.granted;
    });
    _mapController.move(loc, 8.0);
  }

  void _onMapPinSelected(LatLng loc) {
    setState(() {
      _referenceLocation    = loc;
      _referenceLabel       = 'Custom pin';
      _showLocationFallback = false;
      _locationStatus       = _LocationStatus.granted;
    });
    _mapController.move(loc, 8.0);
  }


  void _selectSpot(DarkSkySpot spot) {
    setState(() => _selectedSpot = spot);
    _sheetCtrl.forward();
    _mapController.move(spot.position, 10.0);
  }

  void _dismissSpot() {
    _sheetCtrl.reverse().then((_) {
      if (mounted) setState(() => _selectedSpot = null);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020810),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(45.9432, 24.9668),
              initialZoom: 6.5,
              minZoom: 5.0,
              maxZoom: 16.0,
              onTap: (_, pos) {
                if (_showLocationFallback) return;
                _dismissSpot();
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.aquila.stargazing',
              ),

              MarkerLayer(
                markers: kRomanianDarkSkySpots.map((spot) {
                  final isSelected = _selectedSpot?.id == spot.id;
                  return Marker(
                    point: spot.position,
                    width: isSelected ? 56 : 44,
                    height: isSelected ? 56 : 44,
                    child: GestureDetector(
                      onTap: () {
                        if (!_showLocationFallback) _selectSpot(spot);
                      },
                      child: _SpotMarker(spot: spot, isSelected: isSelected),
                    ),
                  );
                }).toList(),
              ),

              if (_userLocation != null)
                MarkerLayer(markers: [
                  Marker(
                    point: _userLocation!,
                    width: 48, height: 48,
                    child: const _PulsingLocationMarker(),
                  ),
                ]),

              if (_referenceLocation != null &&
                  _referenceLabel != null &&
                  _userLocation == null)
                MarkerLayer(markers: [
                  Marker(
                    point: _referenceLocation!,
                    width: 120, height: 60,
                    child: _ReferencePinMarker(label: _referenceLabel!),
                  ),
                ]),
            ],
          ),

          _buildTopBar(),

          if (!_showLocationFallback) _buildLegend(),

          if (!_showLocationFallback && _selectedSpot == null)
            _buildNearestList(),

          if (!_showLocationFallback && _selectedSpot != null)
            _buildDetailSheet(),

          if (_showLocationFallback) _buildLocationFallback(),

          if (_locationStatus == _LocationStatus.loading)
            _buildLoadingIndicator(),
        ],
      ),
    );
  }


  Widget _buildTopBar() {
    final subtitle = _referenceLabel != null
        ? 'Spots near $_referenceLabel'
        : _locationStatus == _LocationStatus.granted
            ? 'Sorted by distance from you'
            : 'Romania — ${kRomanianDarkSkySpots.length} verified spots';

    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF020810).withOpacity(0.97),
              Colors.transparent,
            ],
            stops: const [0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0A1628).withOpacity(0.9),
                      border: Border.all(
                          color: const Color(0xFF7EB8F7).withOpacity(0.25)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF7EB8F7), size: 16),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DARK SKY FINDER',
                          style: TextStyle(
                              color: Color(0xFF7EB8F7), fontSize: 10,
                              letterSpacing: 3.5, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11, fontFamily: 'Georgia',
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                if (_locationStatus == _LocationStatus.granted ||
                    _locationStatus == _LocationStatus.failed)
                  GestureDetector(
                    onTap: () {
                      setState(() => _showLocationFallback = true);
                      _fallbackCtrl.forward(from: 0);
                    },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0A1628).withOpacity(0.9),
                        border: Border.all(
                            color: const Color(0xFF7EB8F7).withOpacity(0.2)),
                      ),
                      child: Icon(Icons.edit_location_alt_rounded,
                          color: const Color(0xFF7EB8F7).withOpacity(0.7),
                          size: 18),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLoadingIndicator() {
    return Positioned(
      top: 100, right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628).withOpacity(0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF7EB8F7).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: Color(0xFF7EB8F7)),
            ),
            const SizedBox(width: 8),
            Text('Finding you…',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      top: 110, right: 14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628).withOpacity(0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFF7EB8F7).withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SKY QUALITY',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 8, letterSpacing: 2)),
            const SizedBox(height: 8),
            ...BortleClass.values.map((b) {
              final spot =
                  kRomanianDarkSkySpots.firstWhere((s) => s.bortle == b);
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: spot.bortleColor,
                        boxShadow: [BoxShadow(
                            color: spot.bortleColor.withOpacity(0.6),
                            blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(spot.bortleLabel,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7), fontSize: 10)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNearestList() {
    final spots = _sortedSpots;
    final label = _referenceLabel != null
        ? 'NEAREST TO ${_referenceLabel!.toUpperCase()}'
        : _referenceLocation != null
            ? 'NEAREST TO YOU'
            : 'ALL LOCATIONS';

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              const Color(0xFF020810),
              const Color(0xFF020810).withOpacity(0.97),
              const Color(0xFF020810).withOpacity(0.0),
            ],
            stops: const [0.0, 0.65, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 28, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Container(width: 3, height: 14,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: const Color(0xFFE8C87A))),
                    const SizedBox(width: 10),
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10,
                            letterSpacing: 3)),
                  ],
                ),
              ),
              SizedBox(
                height: 112,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: spots.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (ctx, i) {
                    final spot = spots[i];
                    final dist = _referenceLocation != null
                        ? _haversineKm(_referenceLocation!, spot.position)
                        : null;
                    return _NearestCard(
                      spot: spot, distance: dist,
                      rank: _referenceLocation != null ? i + 1 : null,
                      onTap: () => _selectSpot(spot),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDetailSheet() {
    final spot = _selectedSpot!;
    final dist = _referenceLocation != null
        ? _haversineKm(_referenceLocation!, spot.position)
        : null;

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: AnimatedBuilder(
        animation: _sheetAnim,
        builder: (_, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(_sheetAnim),
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF08111F),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: spot.bortleColor.withOpacity(0.2)),
            boxShadow: [BoxShadow(
                color: spot.bortleColor.withOpacity(0.06),
                blurRadius: 40, spreadRadius: 10)],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(width: 36, height: 3,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(2))),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(spot.region.toUpperCase(),
                                    style: TextStyle(
                                        color: spot.bortleColor.withOpacity(0.7),
                                        fontSize: 10, letterSpacing: 2.5)),
                                const SizedBox(height: 4),
                                Text(spot.name,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 22,
                                        fontFamily: 'Georgia',
                                        fontStyle: FontStyle.italic,
                                        height: 1.15)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _dismissSpot,
                            child: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.06)),
                              child: Icon(Icons.close_rounded,
                                  color: Colors.white.withOpacity(0.4),
                                  size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        _StatChip(label: spot.bortleLabel,
                            sublabel: 'Sky Quality', color: spot.bortleColor),
                        const SizedBox(width: 10),
                        _StatChip(label: '${spot.elevationM.round()} m',
                            sublabel: 'Elevation',
                            color: const Color(0xFF88E0B0)),
                        if (dist != null) ...[
                          const SizedBox(width: 10),
                          _StatChip(
                              label: _fmtDist(dist),
                              sublabel: _referenceLabel != null
                                  ? 'From ${_referenceLabel!.split(' ').first}'
                                  : 'From you',
                              color: const Color(0xFFE8C87A)),
                        ],
                      ]),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: spot.bortleColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: spot.bortleColor.withOpacity(0.15)),
                        ),
                        child: Row(children: [
                          Icon(Icons.visibility_rounded,
                              color: spot.bortleColor, size: 15),
                          const SizedBox(width: 8),
                          Expanded(child: Text(spot.bortleDescription,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11.5, height: 1.4))),
                        ]),
                      ),
                      const SizedBox(height: 14),
                      Text(spot.description,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13, height: 1.65,
                              fontFamily: 'Georgia',
                              fontStyle: FontStyle.italic)),
                      const SizedBox(height: 16),
                      Text('BEST FOR',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 9, letterSpacing: 2.5)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8,
                          children: spot.bestFor.map((t) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7EB8F7).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF7EB8F7)
                                  .withOpacity(0.2)),
                            ),
                            child: Text(t, style: const TextStyle(
                                color: Color(0xFF7EB8F7), fontSize: 11)),
                          )).toList()),
                      const SizedBox(height: 16),
                      Row(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.directions_car_rounded,
                                color: const Color(0xFFE8C87A).withOpacity(0.7),
                                size: 14),
                            const SizedBox(width: 8),
                            Expanded(child: Text(spot.accessNote,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.45),
                                    fontSize: 11.5, height: 1.5))),
                          ]),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: const Color(0xFF0A1628),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            content: Text(
                                'Opening navigation to ${spot.name}...',
                                style: TextStyle(color: spot.bortleColor)),
                          ));
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(colors: [
                              spot.bortleColor.withOpacity(0.25),
                              spot.bortleColor.withOpacity(0.1),
                            ]),
                            border: Border.all(
                                color: spot.bortleColor.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.navigation_rounded,
                                  color: spot.bortleColor, size: 17),
                              const SizedBox(width: 8),
                              Text('Navigate to this spot',
                                  style: TextStyle(color: spot.bortleColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLocationFallback() {
    return FadeTransition(
      opacity: _fallbackFade,
      child: SlideTransition(
        position: _fallbackSlide,
        child: Container(
          color: const Color(0xFF020810).withOpacity(0.92),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_referenceLocation != null) {
                            _fallbackCtrl.reverse().then((_) {
                              if (mounted) {
                                setState(() => _showLocationFallback = false);
                              }
                            });
                          } else {
                            Navigator.of(context).maybePop();
                          }
                        },
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0A1628).withOpacity(0.9),
                            border: Border.all(
                                color: const Color(0xFF7EB8F7).withOpacity(0.2)),
                          ),
                          child: Icon(
                            _referenceLocation != null
                                ? Icons.close_rounded
                                : Icons.arrow_back_ios_new_rounded,
                            color: const Color(0xFF7EB8F7), size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),

                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF7EB8F7).withOpacity(0.08),
                            border: Border.all(
                                color: const Color(0xFF7EB8F7).withOpacity(0.2),
                                width: 1.5),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.location_searching_rounded,
                                  color: Color(0xFF7EB8F7), size: 28),
                              Positioned(
                                right: 10, bottom: 10,
                                child: Container(
                                  width: 18, height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFE8C87A),
                                    border: Border.all(
                                        color: const Color(0xFF020810),
                                        width: 2),
                                  ),
                                  child: const Icon(Icons.question_mark_rounded,
                                      color: Color(0xFF020810), size: 10),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'We\'re having a little trouble\nfinding your location.',
                          style: TextStyle(
                            color: Colors.white, fontSize: 24,
                            fontFamily: 'Georgia', fontStyle: FontStyle.italic,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No worries — just tell us where you are and we\'ll '
                          'find the nearest dark sky spots for you.',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 14, height: 1.55),
                        ),

                        const SizedBox(height: 8),

                        GestureDetector(
                          onTap: () async {
                            _fallbackCtrl.reverse().then((_) {
                              if (mounted) {
                                setState(() => _showLocationFallback = false);
                              }
                            });
                            await _tryGetLocation();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded,
                                  color: const Color(0xFF7EB8F7).withOpacity(0.6),
                                  size: 14),
                              const SizedBox(width: 6),
                              Text('Try enabling location and retry',
                                  style: TextStyle(
                                    color: const Color(0xFF7EB8F7)
                                        .withOpacity(0.6),
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    decorationColor: const Color(0xFF7EB8F7)
                                        .withOpacity(0.3),
                                  )),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        Row(children: [
                          const Text('OPTION 1',
                              style: TextStyle(
                                  color: Color(0xFF7EB8F7), fontSize: 9,
                                  letterSpacing: 3)),
                          const SizedBox(width: 12),
                          Expanded(child: Divider(
                              color: Colors.white.withOpacity(0.08))),
                        ]),
                        const SizedBox(height: 14),

                        Text('Choose your county',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16, fontFamily: 'Georgia',
                                fontStyle: FontStyle.italic)),
                        const SizedBox(height: 4),
                        Text('Select the county you\'re currently in',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 12)),
                        const SizedBox(height: 14),

                        _CountyDropdown(
                          onSelected: (county) {
                            _fallbackCtrl.reverse().then((_) {
                              if (mounted) _onCountySelected(county);
                            });
                          },
                        ),

                        const SizedBox(height: 36),

                        Row(children: [
                          const Text('OPTION 2',
                              style: TextStyle(
                                  color: Color(0xFF88E0B0), fontSize: 9,
                                  letterSpacing: 3)),
                          const SizedBox(width: 12),
                          Expanded(child: Divider(
                              color: Colors.white.withOpacity(0.08))),
                        ]),
                        const SizedBox(height: 14),

                        Text('Pin your location on the map',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16, fontFamily: 'Georgia',
                                fontStyle: FontStyle.italic)),
                        const SizedBox(height: 4),
                        Text('Tap anywhere on the map below to set your position',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 12)),
                        const SizedBox(height: 14),

                        _MiniMapPicker(
                          onLocationSelected: (loc) {
                            _fallbackCtrl.reverse().then((_) {
                              if (mounted) _onMapPinSelected(loc);
                            });
                          },
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _CountyDropdown extends StatefulWidget {
  final void Function(_County county) onSelected;
  const _CountyDropdown({required this.onSelected});

  @override
  State<_CountyDropdown> createState() => _CountyDropdownState();
}

class _CountyDropdownState extends State<_CountyDropdown> {
  _County? _selected;
  String _search = '';
  bool _open = false;
  final _searchCtrl = TextEditingController();

  List<_County> get _filtered => kRomanianCounties
      .where((c) => c.name.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1628),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(_open ? 0 : 16),
                bottomRight: Radius.circular(_open ? 0 : 16),
              ),
              border: Border.all(
                color: _open
                    ? const Color(0xFF7EB8F7).withOpacity(0.4)
                    : const Color(0xFF7EB8F7).withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_rounded,
                    color: const Color(0xFF7EB8F7).withOpacity(0.5), size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selected?.name ?? 'Select your county…',
                    style: TextStyle(
                      color: _selected != null
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      fontSize: 14,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF7EB8F7).withOpacity(0.5),
                      size: 20),
                ),
              ],
            ),
          ),
        ),

        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _open
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0C1A2E),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                  color: const Color(0xFF7EB8F7).withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          color: const Color(0xFF7EB8F7).withOpacity(0.4),
                          size: 15),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _search = v),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          cursorColor: const Color(0xFF7EB8F7),
                          decoration: InputDecoration(
                            hintText: 'Search county…',
                            hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.25),
                                fontSize: 12),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_search.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                          },
                          child: Icon(Icons.close_rounded,
                              color: Colors.white.withOpacity(0.25), size: 14),
                        ),
                    ],
                  ),
                ),

                Divider(height: 1, color: Colors.white.withOpacity(0.05)),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: _filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text('No county found',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic)),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) {
                            final county = _filtered[i];
                            final isSel = _selected?.name == county.name;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selected = county;
                                  _open = false;
                                  _search = '';
                                  _searchCtrl.clear();
                                });
                                widget.onSelected(county);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                color: isSel
                                    ? const Color(0xFF7EB8F7).withOpacity(0.08)
                                    : Colors.transparent,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 7, height: 7,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSel
                                            ? const Color(0xFF7EB8F7)
                                            : Colors.white.withOpacity(0.12),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(county.name,
                                          style: TextStyle(
                                            color: isSel
                                                ? const Color(0xFF7EB8F7)
                                                : Colors.white.withOpacity(0.7),
                                            fontSize: 13,
                                          )),
                                    ),
                                    if (isSel)
                                      const Icon(Icons.check_rounded,
                                          color: Color(0xFF7EB8F7), size: 14),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),

        if (_selected != null && !_open) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => widget.onSelected(_selected!),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A4A8A), Color(0xFF0D2A55)],
                ),
                border: Border.all(
                    color: const Color(0xFF7EB8F7).withOpacity(0.4)),
                boxShadow: [BoxShadow(
                    color: const Color(0xFF7EB8F7).withOpacity(0.1),
                    blurRadius: 16)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFF7EB8F7), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Show dark sky spots near ${_selected!.name}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13,
                        fontFamily: 'Georgia', fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}


class _MiniMapPicker extends StatefulWidget {
  final void Function(LatLng location) onLocationSelected;
  const _MiniMapPicker({required this.onLocationSelected});

  @override
  State<_MiniMapPicker> createState() => _MiniMapPickerState();
}

class _MiniMapPickerState extends State<_MiniMapPicker> {
  LatLng? _pin;
  final _miniMapCtrl = MapController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              border: Border.all(
                  color: _pin != null
                      ? const Color(0xFF88E0B0).withOpacity(0.4)
                      : const Color(0xFF7EB8F7).withOpacity(0.15)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _miniMapCtrl,
                  options: MapOptions(
                    initialCenter: const LatLng(45.9432, 24.9668),
                    initialZoom: 6.0,
                    minZoom: 5.0,
                    maxZoom: 12.0,
                    onTap: (_, latLng) {
                      setState(() => _pin = latLng);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.aquila.stargazing',
                    ),
                    MarkerLayer(
                      markers: kRomanianDarkSkySpots.map((spot) => Marker(
                        point: spot.position,
                        width: 10, height: 10,
                        child: Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: spot.bortleColor.withOpacity(0.8),
                            boxShadow: [BoxShadow(
                                color: spot.bortleColor.withOpacity(0.5),
                                blurRadius: 4)],
                          ),
                        ),
                      )).toList(),
                    ),
                    if (_pin != null)
                      MarkerLayer(markers: [
                        Marker(
                          point: _pin!,
                          width: 40, height: 50,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFE8C87A),
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                  boxShadow: const [BoxShadow(
                                      color: Color(0x88E8C87A),
                                      blurRadius: 10)],
                                ),
                                child: const Icon(Icons.person_pin_rounded,
                                    color: Color(0xFF020810), size: 12),
                              ),
                              CustomPaint(
                                size: const Size(2, 10),
                                painter: _PinTailPainter(),
                              ),
                            ],
                          ),
                        ),
                      ]),
                  ],
                ),

                if (_pin == null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF7EB8F7).withOpacity(0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.touch_app_rounded,
                                  color: const Color(0xFF7EB8F7).withOpacity(0.7),
                                  size: 14),
                              const SizedBox(width: 7),
                              Text('Tap to pin your location',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                if (_pin != null)
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF88E0B0).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF88E0B0).withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF88E0B0), size: 12),
                          const SizedBox(width: 5),
                          Text(
                            '${_pin!.latitude.toStringAsFixed(3)}, '
                            '${_pin!.longitude.toStringAsFixed(3)}',
                            style: const TextStyle(
                                color: Color(0xFF88E0B0), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        if (_pin != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _pin = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withOpacity(0.04),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close_rounded,
                            color: Colors.white.withOpacity(0.35), size: 14),
                        const SizedBox(width: 6),
                        Text('Clear pin',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => widget.onLocationSelected(_pin!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                          colors: [Color(0xFF1A4A8A), Color(0xFF0D2A55)]),
                      border: Border.all(
                          color: const Color(0xFF7EB8F7).withOpacity(0.4)),
                      boxShadow: [BoxShadow(
                          color: const Color(0xFF7EB8F7).withOpacity(0.1),
                          blurRadius: 16)],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                            color: Color(0xFF7EB8F7), size: 15),
                        SizedBox(width: 7),
                        Text('Use this location',
                            style: TextStyle(
                                color: Colors.white, fontSize: 13,
                                fontFamily: 'Georgia',
                                fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      Paint()
        ..color = const Color(0xFFE8C87A)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}


class _SpotMarker extends StatelessWidget {
  final DarkSkySpot spot;
  final bool isSelected;
  const _SpotMarker({required this.spot, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isSelected)
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: spot.bortleColor.withOpacity(0.15),
              border: Border.all(
                  color: spot.bortleColor.withOpacity(0.4), width: 1),
            ),
          ),
        Container(
          width: isSelected ? 20 : 14,
          height: isSelected ? 20 : 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: spot.bortleColor,
            boxShadow: [BoxShadow(
              color: spot.bortleColor.withOpacity(isSelected ? 0.9 : 0.5),
              blurRadius: isSelected ? 16 : 8,
              spreadRadius: isSelected ? 2 : 0,
            )],
          ),
          child: isSelected
              ? const Icon(Icons.star_rounded, color: Colors.white, size: 11)
              : null,
        ),
      ],
    );
  }
}


class _PulsingLocationMarker extends StatefulWidget {
  const _PulsingLocationMarker();
  @override
  State<_PulsingLocationMarker> createState() =>
      _PulsingLocationMarkerState();
}

class _PulsingLocationMarkerState extends State<_PulsingLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))..repeat();
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Container(
            width: 48 * _pulse.value,
            height: 48 * _pulse.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF7EB8F7).withOpacity(1 - _pulse.value),
                width: 2,
              ),
            ),
          ),
        ),
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF7EB8F7),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [BoxShadow(
                color: Color(0x887EB8F7), blurRadius: 12)],
          ),
        ),
      ],
    );
  }
}

class _ReferencePinMarker extends StatelessWidget {
  final String label;
  const _ReferencePinMarker({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1A2E).withOpacity(0.95),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: const Color(0xFFE8C87A).withOpacity(0.5)),
          ),
          child: Text(label.split(' ').first,
              style: const TextStyle(
                  color: Color(0xFFE8C87A), fontSize: 10)),
        ),
        const SizedBox(height: 2),
        Container(
          width: 10, height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE8C87A),
            boxShadow: [BoxShadow(
                color: Color(0x88E8C87A), blurRadius: 8)],
          ),
        ),
      ],
    );
  }
}

class _NearestCard extends StatelessWidget {
  final DarkSkySpot spot;
  final double? distance;
  final int? rank;
  final VoidCallback onTap;
  const _NearestCard({
    required this.spot, required this.onTap,
    this.distance, this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 185,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFF0A1220),
          border: Border.all(
              color: spot.bortleColor.withOpacity(0.22), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, color: spot.bortleColor,
                    boxShadow: [BoxShadow(
                        color: spot.bortleColor.withOpacity(0.6),
                        blurRadius: 6)],
                  ),
                ),
                if (rank != null && rank! <= 3)
                  Text('#$rank nearest',
                      style: TextStyle(
                          color: const Color(0xFFE8C87A).withOpacity(0.6),
                          fontSize: 9, letterSpacing: 0.5)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(spot.name,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13,
                        fontFamily: 'Georgia', fontStyle: FontStyle.italic,
                        height: 1.2)),
                const SizedBox(height: 4),
                Row(children: [
                  Text(spot.bortleLabel,
                      style: TextStyle(
                          color: spot.bortleColor, fontSize: 10)),
                  if (distance != null) ...[
                    Text('  ·  ',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.2),
                            fontSize: 10)),
                    Text(_fmtDist(distance!),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 10)),
                  ],
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, sublabel;
  final Color color;
  const _StatChip({
    required this.label, required this.sublabel, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Text(label, style: TextStyle(
            color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 1),
        Text(sublabel, style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 9, letterSpacing: 0.5)),
      ]),
    );
  }
}