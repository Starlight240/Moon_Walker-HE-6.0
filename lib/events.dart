import 'dart:math';
import 'main.dart';
import 'package:flutter/material.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020810),
      ),
      home: const EventsPage(),
    );
  }
}

enum AstroEventType { eclipse, meteor, planet, conjunction, moon, comet }

class AstroEvent {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final AstroEventType type;
  final String description;
  final String visibility;
  final String peakTime;
  final String magnitude;
  final bool isTonight;

  const AstroEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.type,
    required this.description,
    required this.visibility,
    required this.peakTime,
    required this.magnitude,
    this.isTonight = false,
  });
}

class LocalEvent {
  final String id;
  final String title;
  final String organizer;
  final String city;
  final DateTime date;
  final String time;
  final String description;
  final String address;
  final String? ticketInfo;
  final bool isFree;
  final String category;
  final Color accentColor;

  const LocalEvent({
    required this.id,
    required this.title,
    required this.organizer,
    required this.city,
    required this.date,
    required this.time,
    required this.description,
    required this.address,
    this.ticketInfo,
    required this.isFree,
    required this.category,
    required this.accentColor,
  });
}

final List<AstroEvent> kAstroEvents = [
  AstroEvent(
    id: 'lunar-eclipse-may',
    title: 'Penumbral Lunar Eclipse',
    subtitle: 'Moon enters Earth\'s outer shadow',
    date: DateTime(2026, 5, 5, 23, 14),
    type: AstroEventType.eclipse,
    description:
        'The full Moon will pass through Earth\'s penumbral shadow, causing a subtle darkening of the lunar surface. Best viewed with binoculars from a dark location.',
    visibility: 'Fully visible from Romania',
    peakTime: '23:14 local time',
    magnitude: 'Penumbral magnitude 0.92',
    isTonight: false,
  ),
  AstroEvent(
    id: 'eta-aquariid',
    title: 'Eta Aquariid Meteor Shower',
    subtitle: 'Debris from Halley\'s Comet',
    date: DateTime(2026, 5, 6, 3, 0),
    type: AstroEventType.meteor,
    description:
        'The Eta Aquariids are active between April 19 and May 28, but peak around May 6. Produced by dust left by Halley\'s Comet, expect up to 50 meteors per hour from a dark sky site.',
    visibility: 'Best after midnight, southern horizon',
    peakTime: '03:00 – 05:30 local time',
    magnitude: '50 meteors/hr at peak',
    isTonight: false,
  ),
  AstroEvent(
    id: 'mars-saturn-conj',
    title: 'Mars–Saturn Conjunction',
    subtitle: 'Two planets meet in Pisces',
    date: DateTime(2026, 5, 20, 21, 30),
    type: AstroEventType.conjunction,
    description:
        'Mars and Saturn will appear just 0.4° apart in the constellation Pisces — close enough to fit in the same binocular field of view. A rare and photogenic pairing.',
    visibility: 'Visible low in the east after dusk',
    peakTime: '21:30 local time',
    magnitude: '0.4° separation',
    isTonight: false,
  ),
  AstroEvent(
    id: 'jupiter-opposition',
    title: 'Jupiter at Opposition',
    subtitle: 'Closest approach of 2026',
    date: DateTime(2026, 8, 19, 21, 0),
    type: AstroEventType.planet,
    description:
        'Jupiter reaches opposition, rising at sunset and remaining visible all night. At its largest and brightest in 2026, even a small telescope will reveal the cloud bands and Galilean moons.',
    visibility: 'Visible all night from Romania',
    peakTime: 'Rises at sunset, highest at midnight',
    magnitude: 'Magnitude -2.9',
    isTonight: false,
  ),
  AstroEvent(
    id: 'perseid-2026',
    title: 'Perseid Meteor Shower',
    subtitle: 'Peak of the summer\'s best show',
    date: DateTime(2026, 8, 12, 22, 0),
    type: AstroEventType.meteor,
    description:
        'The Perseids are the most beloved meteor shower of the year. Under a dark sky, expect 90–120 meteors per hour at peak. The Moon will be a thin crescent, leaving skies beautifully dark.',
    visibility: 'Excellent from Romanian highlands',
    peakTime: '22:00 – 04:00 local time',
    magnitude: '90–120 meteors/hr',
    isTonight: false,
  ),
  AstroEvent(
    id: 'total-lunar-sep',
    title: 'Total Lunar Eclipse',
    subtitle: 'Blood Moon — fully visible',
    date: DateTime(2026, 9, 7, 20, 44),
    type: AstroEventType.eclipse,
    description:
        'A total lunar eclipse where the Moon turns deep red as it enters Earth\'s umbral shadow. The totality phase lasts 1 hour 21 minutes — plenty of time to observe and photograph.',
    visibility: 'Fully visible from all of Romania',
    peakTime: 'Totality: 20:44 – 22:05 local time',
    magnitude: 'Umbral magnitude 1.36',
    isTonight: false,
  ),
  AstroEvent(
    id: 'comet-tsuchinshan',
    title: 'Comet C/2023 A3 Returns',
    subtitle: 'Second perihelion pass',
    date: DateTime(2026, 10, 3, 19, 30),
    type: AstroEventType.comet,
    description:
        'Following its spectacular 2024 appearance, Comet Tsuchinshan-ATLAS is predicted to return to the inner solar system. Visibility depends on outgassing activity — could reach naked-eye brightness.',
    visibility: 'Western horizon after sunset',
    peakTime: '19:30 – 21:00 local time (window)',
    magnitude: 'Predicted mag. 4–6 (uncertain)',
    isTonight: false,
  ),
];

final List<LocalEvent> kLocalEvents = [
  LocalEvent(
    id: 'ploiesti-museum-may',
    title: 'Telescope Watching Night',
    organizer: 'Muzeul de Științe Naturale Prahova',
    city: 'Ploiești',
    date: DateTime(2026, 5, 14, 21, 0),
    time: '21:00 – 24:00',
    description:
        'The local science museum invites families and astronomy enthusiasts for a guided night of telescope observation. Saturn\'s rings and the Moon will be the main targets. Astronomers from the Prahova Astro Club will be present to guide you through the constellations.',
    address: 'Str. Toma Caragiu nr. 10, Ploiești',
    ticketInfo: '25 lei / adult · 10 lei / child',
    isFree: false,
    category: 'Museum',
    accentColor: const Color(0xFF88E0B0),
  ),
  LocalEvent(
    id: 'bucharest-obs-june',
    title: 'Open Observatory Night',
    organizer: 'Observatorul Astronomic București',
    city: 'București',
    date: DateTime(2026, 6, 6, 20, 30),
    time: '20:30 – 23:30',
    description:
        'Bucharest\'s historic observatory opens its main 300mm refractor to the public. The focus this month is the Mars–Saturn conjunction still visible in the western sky. Prior registration required due to limited spots.',
    address: 'Str. Cutitul de Argint nr. 5, București',
    ticketInfo: 'Free — registration required',
    isFree: true,
    category: 'Observatory',
    accentColor: const Color(0xFF7EB8F7),
  ),
  LocalEvent(
    id: 'cluj-astro-picnic',
    title: 'Astro Picnic — Fânațele Clujului',
    organizer: 'Cluj Astronomers Society',
    city: 'Cluj-Napoca',
    date: DateTime(2026, 6, 21, 22, 0),
    time: '22:00 – 02:00',
    description:
        'A summer solstice stargazing gathering in the meadows east of Cluj. Bring a blanket and your binoculars — club members will have multiple telescopes set up. Summer Milky Way and noctilucent clouds expected.',
    address: 'Fânațele Clujului Nature Reserve, Cluj-Napoca',
    ticketInfo: null,
    isFree: true,
    category: 'Club',
    accentColor: const Color(0xFFE8C87A),
  ),
  LocalEvent(
    id: 'sinaia-perseid-camp',
    title: 'Perseid Dark Sky Camp',
    organizer: 'Carpathian Stargazers',
    city: 'Sinaia',
    date: DateTime(2026, 8, 11, 20, 0),
    time: '2 nights — Aug 11–12',
    description:
        'A 2-night camping event at 1800 m altitude near Sinaia, timed for the Perseid peak. Includes guided meteor counting sessions, astrophotography workshops, and a morning hike. Equipment rental available on site.',
    address: 'Cabana Vârful cu Dor, Munții Bucegi',
    ticketInfo: '180 lei / person (includes camping)',
    isFree: false,
    category: 'Camp',
    accentColor: const Color(0xFFFFAA66),
  ),
  LocalEvent(
    id: 'timisoara-planetarium',
    title: 'Total Eclipse Viewing Party',
    organizer: 'Planetariul Timișoara',
    city: 'Timișoara',
    date: DateTime(2026, 9, 7, 19, 0),
    time: '19:00 – 23:00',
    description:
        'Live projection of the total lunar eclipse on the planetarium dome, combined with rooftop telescope observation. Expert commentary throughout. Hot drinks served. All ages welcome.',
    address: 'Bd. Mihai Eminescu nr. 2, Timișoara',
    ticketInfo: '30 lei / adult · 15 lei / child',
    isFree: false,
    category: 'Planetarium',
    accentColor: const Color(0xFFCC88FF),
  ),
];

String _daysUntil(DateTime date) {
  final now = DateTime.now();
  final diff = date.difference(DateTime(now.year, now.month, now.day)).inDays;
  if (diff == 0) return 'Tonight';
  if (diff == 1) return 'Tomorrow';
  if (diff < 0) return 'Passed';
  if (diff < 30) return 'In $diff days';
  final months = (diff / 30.4).round();
  return 'In $months month${months > 1 ? 's' : ''}';
}

String _formatDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

Color _astroTypeColor(AstroEventType t) {
  switch (t) {
    case AstroEventType.eclipse:
      return const Color(0xFFFF8C66);
    case AstroEventType.meteor:
      return const Color(0xFF7EB8F7);
    case AstroEventType.planet:
      return const Color(0xFF88E0B0);
    case AstroEventType.conjunction:
      return const Color(0xFFE8C87A);
    case AstroEventType.moon:
      return const Color(0xFFCCDDFF);
    case AstroEventType.comet:
      return const Color(0xFFCC88FF);
  }
}

String _astroTypeIcon(AstroEventType t) {
  switch (t) {
    case AstroEventType.eclipse:
      return '🌑';
    case AstroEventType.meteor:
      return '☄';
    case AstroEventType.planet:
      return '♃';
    case AstroEventType.conjunction:
      return '✦';
    case AstroEventType.moon:
      return '☽';
    case AstroEventType.comet:
      return '🌠';
  }
}

String _categoryIcon(String category) {
  switch (category) {
    case 'Museum':
      return '🏛';
    case 'Observatory':
      return '🔭';
    case 'Club':
      return '⭐';
    case 'Camp':
      return '⛺';
    case 'Planetarium':
      return '🪐';
    default:
      return '📅';
  }
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

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double phase;
  _StarfieldPainter(this.stars, this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final opacity = 0.2 + 0.5 * ((sin(phase * s.speed + s.offset) + 1) / 2);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.radius,
        Paint()
          ..color = s.color.withOpacity(opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.radius * 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => old.phase != phase;
}

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with TickerProviderStateMixin {
  late AnimationController _starCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late List<_Star> _stars;

  String? _expandedAstroId;
  String? _expandedLocalId;

  @override
  void initState() {
    super.initState();
    final rng = Random(55);
    final colors = [
      Colors.white,
      const Color(0xFFB8D4FF),
      const Color(0xFFFFE8C0)
    ];
    _stars = List.generate(
        120,
        (_) => _Star(
              x: rng.nextDouble(),
              y: rng.nextDouble(),
              radius: rng.nextDouble() * 1.4 + 0.2,
              speed: rng.nextDouble() * 2 + 0.5,
              offset: rng.nextDouble() * pi * 2,
              color: colors[rng.nextInt(colors.length)],
            ));

    _starCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020810),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _starCtrl,
            builder: (_, __) => CustomPaint(
              painter: _StarfieldPainter(_stars, _starCtrl.value * 2 * pi),
              size: MediaQuery.of(context).size,
            ),
          ),
          _nebula(300, const Color(0xFF1A2A5E), 0.3, top: -80, right: -60),
          _nebula(220, const Color(0xFF2A1045), 0.25, bottom: 200, left: -40),
          FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildAppBar()),
                SliverToBoxAdapter(child: _buildTonightBanner()),
                SliverToBoxAdapter(
                    child: _buildSectionHeader(
                  icon: '✦',
                  title: 'Astronomical Events',
                  subtitle: 'Sky events visible from Romania in 2026',
                  color: const Color(0xFF7EB8F7),
                )),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _AstroEventCard(
                      event: kAstroEvents[i],
                      isExpanded: _expandedAstroId == kAstroEvents[i].id,
                      onTap: () => setState(() {
                        _expandedAstroId =
                            _expandedAstroId == kAstroEvents[i].id
                                ? null
                                : kAstroEvents[i].id;
                      }),
                    ),
                    childCount: kAstroEvents.length,
                  ),
                ),
                SliverToBoxAdapter(child: _buildDivider()),
                SliverToBoxAdapter(
                    child: _buildSectionHeader(
                  icon: '📍',
                  title: 'Local Events',
                  subtitle: 'Community stargazing events near you',
                  color: const Color(0xFF88E0B0),
                  isSponsored: true,
                )),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _LocalEventCard(
                      event: kLocalEvents[i],
                      isExpanded: _expandedLocalId == kLocalEvents[i].id,
                      onTap: () => setState(() {
                        _expandedLocalId =
                            _expandedLocalId == kLocalEvents[i].id
                                ? null
                                : kLocalEvents[i].id;
                      }),
                    ),
                    childCount: kLocalEvents.length,
                  ),
                ),
                SliverToBoxAdapter(child: _buildSubmitCTA()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF020810).withOpacity(0.98),
            const Color(0xFF020810).withOpacity(0.0),
          ],
          stops: const [0.6, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 40,
                  height: 40,
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
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EVENTS',
                    style: TextStyle(
                      color: Color(0xFF7EB8F7),
                      fontSize: 10,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sky calendar & local gatherings',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0A1628).withOpacity(0.9),
                  border: Border.all(
                      color: const Color(0xFF7EB8F7).withOpacity(0.2)),
                ),
                child: Icon(Icons.tune_rounded,
                    color: const Color(0xFF7EB8F7).withOpacity(0.6), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTonightBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0E2040), Color(0xFF1A0D35)],
          ),
          border: Border.all(color: const Color(0xFF7EB8F7).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7EB8F7).withOpacity(0.06),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7EB8F7).withOpacity(0.1),
                border:
                    Border.all(color: const Color(0xFF7EB8F7).withOpacity(0.3)),
              ),
              child: const Center(
                child: Text('☽', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFF7EB8F7).withOpacity(0.12),
                    ),
                    child: const Text(
                      'TONIGHT',
                      style: TextStyle(
                        color: Color(0xFF7EB8F7),
                        fontSize: 9,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Waning Gibbous Moon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Illumination 72% · Rises 23:08 · Seeing: Good',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    bool isSponsored = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isSponsored) ...[
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xFF88E0B0).withOpacity(0.12),
                    border: Border.all(
                        color: const Color(0xFF88E0B0).withOpacity(0.3)),
                  ),
                  child: const Text(
                    'COMMUNITY',
                    style: TextStyle(
                      color: Color(0xFF88E0B0),
                      fontSize: 8,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.38),
                fontSize: 12,
                fontFamily: 'Georgia',
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.white.withOpacity(0.06))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('✦',
                style: TextStyle(
                    color: const Color(0xFF7EB8F7).withOpacity(0.3),
                    fontSize: 12)),
          ),
          Expanded(child: Divider(color: Colors.white.withOpacity(0.06))),
        ],
      ),
    );
  }

  Widget _buildSubmitCTA() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF0A1220),
            border: Border.all(
              color: const Color(0xFF88E0B0).withOpacity(0.2),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF88E0B0).withOpacity(0.1),
                  border: Border.all(
                      color: const Color(0xFF88E0B0).withOpacity(0.3)),
                ),
                child: const Icon(Icons.add_rounded,
                    color: Color(0xFF88E0B0), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Host a stargazing event?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Submit your request for your event to appear here',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: const Color(0xFF88E0B0).withOpacity(0.5), size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nebula(double size, Color color, double opacity,
      {double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withOpacity(opacity), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}

class _AstroEventCard extends StatelessWidget {
  final AstroEvent event;
  final bool isExpanded;
  final VoidCallback onTap;

  const _AstroEventCard({
    required this.event,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _astroTypeColor(event.type);
    final daysLabel = _daysUntil(event.date);
    final isPassed = event.date.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF0A1220),
            border: Border.all(
              color:
                  isExpanded ? color.withOpacity(0.4) : color.withOpacity(0.15),
              width: isExpanded ? 1.2 : 1,
            ),
            boxShadow: isExpanded
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.1),
                        border: Border.all(color: color.withOpacity(0.25)),
                      ),
                      child: Center(
                        child: Text(
                          _astroTypeIcon(event.type),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Georgia',
                              fontStyle: FontStyle.italic,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            event.subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isPassed
                                ? Colors.white.withOpacity(0.05)
                                : color.withOpacity(0.12),
                          ),
                          child: Text(
                            daysLabel,
                            style: TextStyle(
                              color: isPassed
                                  ? Colors.white.withOpacity(0.25)
                                  : color,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(event.date),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Row(
                    children: [
                      _miniStat(
                          Icons.access_time_rounded, event.peakTime, color),
                      const SizedBox(width: 16),
                      _miniStat(
                          Icons.visibility_rounded, event.magnitude, color),
                    ],
                  ),
                ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 13,
                          height: 1.65,
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: color.withOpacity(0.05),
                          border: Border.all(color: color.withOpacity(0.12)),
                        ),
                        child: Column(
                          children: [
                            _infoRow(Icons.location_on_rounded,
                                event.visibility, color),
                            const SizedBox(height: 10),
                            _infoRow(Icons.access_time_rounded, event.peakTime,
                                color),
                            const SizedBox(height: 10),
                            _infoRow(Icons.auto_awesome_rounded,
                                event.magnitude, color),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Reminder set for ${event.title}',
                                style: TextStyle(color: color),
                              ),
                              backgroundColor: const Color(0xFF0A1628),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(colors: [
                              color.withOpacity(0.2),
                              color.withOpacity(0.08),
                            ]),
                            border: Border.all(color: color.withOpacity(0.35)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_outlined,
                                  color: color, size: 16),
                              const SizedBox(width: 8),
                              Text('Set Reminder',
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: color.withOpacity(0.4),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color.withOpacity(0.5), size: 12),
        const SizedBox(width: 5),
        Text(text,
            style: TextStyle(
                color: Colors.white.withOpacity(0.35), fontSize: 10.5)),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color.withOpacity(0.6), size: 14),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  height: 1.4)),
        ),
      ],
    );
  }
}

class _LocalEventCard extends StatelessWidget {
  final LocalEvent event;
  final bool isExpanded;
  final VoidCallback onTap;

  const _LocalEventCard({
    required this.event,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = event.accentColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF0A1220),
            border: Border.all(
              color: isExpanded
                  ? color.withOpacity(0.45)
                  : color.withOpacity(0.18),
              width: isExpanded ? 1.2 : 1,
            ),
            boxShadow: isExpanded
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: color.withOpacity(0.07),
                ),
                child: Row(
                  children: [
                    Text(
                      _categoryIcon(event.category),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.category.toUpperCase(),
                      style: TextStyle(
                        color: color.withOpacity(0.7),
                        fontSize: 9,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white.withOpacity(0.04),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Text(
                        'LOCAL EVENT',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 8,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
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
                              Text(
                                event.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Georgia',
                                  fontStyle: FontStyle.italic,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.organizer,
                                style: TextStyle(
                                  color: color.withOpacity(0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: color.withOpacity(0.12),
                              ),
                              child: Text(
                                _daysUntil(event.date),
                                style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(event.date),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _pill(Icons.access_time_rounded, event.time, color),
                        const SizedBox(width: 8),
                        _pill(Icons.location_city_rounded, event.city, color),
                        if (event.isFree) ...[
                          const SizedBox(width: 8),
                          _pill(Icons.check_circle_rounded, 'Free',
                              const Color(0xFF88E0B0)),
                        ],
                      ],
                    ),
                    if (isExpanded) ...[
                      const SizedBox(height: 16),
                      Text(
                        event.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                          height: 1.65,
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: color.withOpacity(0.05),
                          border: Border.all(color: color.withOpacity(0.12)),
                        ),
                        child: Column(
                          children: [
                            _infoRow(Icons.place_rounded, event.address, color),
                            if (event.ticketInfo != null) ...[
                              const SizedBox(height: 10),
                              _infoRow(Icons.confirmation_number_rounded,
                                  event.ticketInfo!, color),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Opening directions…',
                                        style: TextStyle(color: color)),
                                    backgroundColor: const Color(0xFF0A1628),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                );
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13),
                                  color: Colors.white.withOpacity(0.05),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.directions_rounded,
                                        color: Colors.white.withOpacity(0.5),
                                        size: 15),
                                    const SizedBox(width: 6),
                                    Text('Directions',
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.5),
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
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        event.isFree
                                            ? 'Registered for ${event.title}!'
                                            : 'Opening ticket purchase…',
                                        style: TextStyle(color: color)),
                                    backgroundColor: const Color(0xFF0A1628),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                );
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13),
                                  gradient: LinearGradient(colors: [
                                    color.withOpacity(0.25),
                                    color.withOpacity(0.1),
                                  ]),
                                  border:
                                      Border.all(color: color.withOpacity(0.4)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      event.isFree
                                          ? Icons.how_to_reg_rounded
                                          : Icons.confirmation_number_rounded,
                                      color: color,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      event.isFree ? 'Register' : 'Get Tickets',
                                      style: TextStyle(
                                          color: color,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: color.withOpacity(0.35),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 11),
          const SizedBox(width: 5),
          Text(text,
              style: TextStyle(color: color.withOpacity(0.85), fontSize: 10.5)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color.withOpacity(0.6), size: 14),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  height: 1.4)),
        ),
      ],
    );
  }
}
