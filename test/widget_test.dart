import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const StargazingApp());
}

class StargazingApp extends StatelessWidget {
  const StargazingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Georgia',
        scaffoldBackgroundColor: const Color(0xFF020810),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7EB8F7),
          secondary: Color(0xFFE8C87A),
          surface: Color(0xFF0A1628),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ─────────────────────────────────────────────
//  Starfield painter
// ─────────────────────────────────────────────
class StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double twinklePhase;

  StarfieldPainter(this.stars, this.twinklePhase);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final opacity =
          0.4 + 0.6 * ((sin(twinklePhase * star.speed + star.offset) + 1) / 2);
      final paint = Paint()
        ..color = star.color.withOpacity(opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.radius * 0.8);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter oldDelegate) =>
      oldDelegate.twinklePhase != twinklePhase;
}

class _Star {
  final double x, y, radius, speed, offset;
  final Color color;
  _Star(
      {required this.x,
      required this.y,
      required this.radius,
      required this.speed,
      required this.offset,
      required this.color});
}

// ─────────────────────────────────────────────
//  Home Page
// ─────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _twinkleController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late List<_Star> _stars;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // Generate stars
    final rng = Random(42);
    _stars = List.generate(180, (_) {
      final baseColors = [
        Colors.white,
        const Color(0xFFB8D4FF),
        const Color(0xFFFFE8C0),
        const Color(0xFFFFCCCC),
      ];
      return _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: rng.nextDouble() * 1.8 + 0.3,
        speed: rng.nextDouble() * 2 + 0.5,
        offset: rng.nextDouble() * pi * 2,
        color: baseColors[rng.nextInt(baseColors.length)],
      );
    });

    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // ── Starfield background ──
          AnimatedBuilder(
            animation: _twinkleController,
            builder: (_, __) => CustomPaint(
              painter: StarfieldPainter(
                  _stars, _twinkleController.value * 2 * pi),
              size: MediaQuery.of(context).size,
            ),
          ),

          // ── Nebula gradient overlays ──
          Positioned(
            top: -120,
            left: -80,
            child: _nebulaBlob(320, const Color(0xFF1A3A6B), 0.45),
          ),
          Positioned(
            top: 80,
            right: -60,
            child: _nebulaBlob(260, const Color(0xFF3B1A5E), 0.35),
          ),
          Positioned(
            bottom: 100,
            left: 40,
            child: _nebulaBlob(200, const Color(0xFF0D3050), 0.3),
          ),

          // ── Main content ──
          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildSkyViewCard()),
                  SliverToBoxAdapter(child: _buildSectionTitle('Tonight\'s Events')),
                  SliverToBoxAdapter(child: _buildEventsList()),
                  SliverToBoxAdapter(child: _buildSectionTitle('Dark Sky Spots Near You')),
                  SliverToBoxAdapter(child: _buildMapPreview()),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Nav ──
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── Nebula helper ───
  Widget _nebulaBlob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent],
        ),
      ),
    );
  }

  // ─── Header ───
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ASTRA',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 11,
                  letterSpacing: 6,
                  color: const Color(0xFF7EB8F7).withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Good Evening,\nAlex.',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 28,
                  height: 1.15,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF7EB8F7).withOpacity(0.4), width: 1.5),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A2F50), Color(0xFF0D1B33)],
                ),
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    color: Color(0xFF7EB8F7),
                    fontSize: 17,
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sky View CTA Card ───
  Widget _buildSkyViewCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: const Color(0xFF7EB8F7).withOpacity(0.2), width: 1),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0E2040), Color(0xFF1A0D35)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7EB8F7).withOpacity(0.08),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // decorative rings
              Positioned(
                right: -30,
                top: -30,
                child: _decorativeRing(140, const Color(0xFF7EB8F7), 0.07),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: _decorativeRing(90, const Color(0xFF7EB8F7), 0.1),
              ),
              Positioned(
                right: 35,
                top: 35,
                child: _decorativeRing(40, const Color(0xFF7EB8F7), 0.18),
              ),
              // content
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFF7EB8F7).withOpacity(0.15),
                        border: Border.all(
                            color: const Color(0xFF7EB8F7).withOpacity(0.3)),
                      ),
                      child: const Text(
                        'LIVE SKY VIEW',
                        style: TextStyle(
                          color: Color(0xFF7EB8F7),
                          fontSize: 10,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Point at the sky\nto explore stars',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Open AR view',
                          style: TextStyle(
                            color: Color(0xFF7EB8F7),
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward,
                            color: const Color(0xFF7EB8F7).withOpacity(0.8),
                            size: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _decorativeRing(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(opacity), width: 1),
      ),
    );
  }

  // ─── Section Title ───
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: const Color(0xFFE8C87A),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              letterSpacing: 3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Events List ───
  Widget _buildEventsList() {
    final events = [
      const _EventData(
        icon: '☽',
        title: 'Lunar Eclipse',
        subtitle: 'Penumbral · Full visibility',
        date: 'Tonight  23:14',
        color: Color(0xFFE8C87A),
      ),
      const _EventData(
        icon: '★',
        title: 'Perseid Meteor Shower',
        subtitle: 'Peak activity · 90/hr',
        date: 'Aug 12  22:00',
        color: Color(0xFF7EB8F7),
      ),
      const _EventData(
        icon: '♃',
        title: 'Jupiter at Opposition',
        subtitle: 'Closest approach of 2026',
        date: 'Aug 19  21:30',
        color: Color(0xFFFFBB88),
      ),
    ];

    return SizedBox(
      height: 136,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) => _EventCard(event: events[i]),
      ),
    );
  }

  // ─── Map Preview ───
  Widget _buildMapPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF7EB8F7).withOpacity(0.15), width: 1),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF071520), Color(0xFF0C1E38)],
            ),
          ),
          child: Stack(
            children: [
              // fake map grid lines
              CustomPaint(
                painter: _MapGridPainter(),
                size: const Size(double.infinity, 150),
              ),
              // location pins
              Positioned(
                left: 110,
                top: 55,
                child: _mapPin(const Color(0xFF7EB8F7), 'Best spot\n32 km'),
              ),
              Positioned(
                left: 220,
                top: 80,
                child: _mapPin(const Color(0xFFE8C87A), ''),
              ),
              // overlay gradient
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF071520).withOpacity(0.6),
                      Colors.transparent,
                      const Color(0xFF0C1E38).withOpacity(0.5),
                    ],
                  ),
                ),
              ),
              // label
              Positioned(
                bottom: 16,
                right: 20,
                child: Row(
                  children: [
                    const Text(
                      'Open full map',
                      style: TextStyle(
                        color: Color(0xFF7EB8F7),
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.open_in_new,
                        color: const Color(0xFF7EB8F7).withOpacity(0.7),
                        size: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapPin(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.6), blurRadius: 8),
            ],
          ),
        ),
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 9,
                height: 1.3,
              ),
            ),
          ),
      ],
    );
  }

  // ─── Bottom Nav ───
  Widget _buildBottomNav() {
    const items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.auto_awesome, 'label': 'Sky'},
      {'icon': Icons.event_rounded, 'label': 'Events'},
      {'icon': Icons.map_rounded, 'label': 'Map'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
              color: const Color(0xFF7EB8F7).withOpacity(0.1), width: 1),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC020810), Color(0xFF020810)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == _selectedIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selected
                        ? const Color(0xFF7EB8F7).withOpacity(0.12)
                        : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        size: 22,
                        color: selected
                            ? const Color(0xFF7EB8F7)
                            : Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 9.5,
                          letterSpacing: 0.5,
                          color: selected
                              ? const Color(0xFF7EB8F7)
                              : Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Event Card widget
// ─────────────────────────────────────────────
class _EventData {
  final String icon, title, subtitle, date;
  final Color color;
  const _EventData(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.date,
      required this.color});
}

class _EventCard extends StatelessWidget {
  final _EventData event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: event.color.withOpacity(0.2), width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            event.color.withOpacity(0.08),
            const Color(0xFF0A1220),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(event.icon, style: const TextStyle(fontSize: 22)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: event.color.withOpacity(0.12),
                ),
                child: Text(
                  event.date,
                  style: TextStyle(
                    color: event.color,
                    fontSize: 9,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                event.subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Map Grid Painter (decorative)
// ─────────────────────────────────────────────
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7EB8F7).withOpacity(0.06)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // curved "road" lines
    final roadPaint = Paint()
      ..color = const Color(0xFF7EB8F7).withOpacity(0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..cubicTo(size.width * 0.3, size.height * 0.4, size.width * 0.6,
          size.height * 0.8, size.width, size.height * 0.5);
    canvas.drawPath(path, roadPaint);

    final path2 = Path()
      ..moveTo(0, size.height * 0.3)
      ..cubicTo(size.width * 0.4, size.height * 0.6, size.width * 0.7,
          size.height * 0.2, size.width, size.height * 0.4);
    canvas.drawPath(path2, roadPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}