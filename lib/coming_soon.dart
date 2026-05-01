import 'dart:math';
import 'package:flutter/material.dart';
import 'main.dart';

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
      home: const ComingSoonPage(),
    );
  }
}

class _Star {
  final double x, y, radius, speed, offset;
  final Color color;

  _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.offset,
    required this.color,
  });
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double phase;

  _StarfieldPainter(this.stars, this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final opacity =
          0.2 + 0.6 * ((sin(phase * s.speed + s.offset) + 1) / 2);

      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.radius,
        Paint()
          ..color = s.color.withOpacity(opacity)
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, s.radius * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => old.phase != phase;
}

class ComingSoonPage extends StatefulWidget {
  const ComingSoonPage({super.key});

  @override
  State<ComingSoonPage> createState() => _ComingSoonPageState();
}

class _ComingSoonPageState extends State<ComingSoonPage>
    with TickerProviderStateMixin {
  late AnimationController _starCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _fadeCtrl;

  late List<_Star> _stars;

  @override
  void initState() {
    super.initState();

    final rng = Random(42);
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
        radius: rng.nextDouble() * 1.5 + 0.3,
        speed: rng.nextDouble() * 2 + 0.5,
        offset: rng.nextDouble() * pi * 2,
        color: colors[rng.nextInt(colors.length)],
      ),
    );

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    _pulseCtrl.dispose();
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
              painter: _StarfieldPainter(
                  _stars, _starCtrl.value * 2 * pi),
              size: MediaQuery.of(context).size,
            ),
          ),

          _nebula(300, const Color(0xFF1A2A5E), 0.3,
              top: -80, right: -60),
          _nebula(240, const Color(0xFF2A1045), 0.25,
              bottom: 120, left: -40),

          FadeTransition(
            opacity: _fadeCtrl,
            child: Center(
              child: ScaleTransition(
                scale: _pulseCtrl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            const Color(0xFF7EB8F7).withOpacity(0.1),
                        border: Border.all(
                            color: const Color(0xFF7EB8F7)
                                .withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7EB8F7)
                                .withOpacity(0.25),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.rocket_launch_rounded,
                            color: Color(0xFF7EB8F7), size: 40),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'We’re preparing something stellar.\nStay tuned.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 30),

                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF7EB8F7)
                                  .withOpacity(0.25),
                              const Color(0xFF7EB8F7)
                                  .withOpacity(0.08),
                            ],
                          ),
                          border: Border.all(
                              color: const Color(0xFF7EB8F7)
                                  .withOpacity(0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_rounded,
                                color: Color(0xFF7EB8F7), size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Back to Home',
                              style: TextStyle(
                                color: Color(0xFF7EB8F7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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