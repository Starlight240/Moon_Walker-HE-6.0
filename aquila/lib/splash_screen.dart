import 'dart:math';

import 'package:aquila/login.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _starCtrl;

  // Planet: scale in + float
  late AnimationController _planetCtrl;
  late Animation<double> _planetScale;
  late Animation<double> _planetFloat;

  // star: full rotation
  late AnimationController _orbitCtrl;

  // ring: fade in
  late AnimationController _ringCtrl;
  late Animation<double> _ringOpacity;

  // Comet trail on star
  late AnimationController _trailCtrl;

  // "AQUILA"
  late AnimationController _titleCtrl;
  late List<Animation<double>> _letterFades;
  late List<Animation<Offset>> _letterSlides;

  // fade
  late AnimationController _taglineCtrl;
  late Animation<double> _taglineFade;

  // Loading
  late AnimationController _dotsCtrl;

  // Exit
  late AnimationController _exitCtrl;
  late Animation<double> _exitFade;

  // bckground
  late AnimationController _nebulaPulse;

  late List<_Star> _stars;

  static const _totalDuration = 5.0;

  @override
  void initState() {
    super.initState();

    final rng = Random(99);
    final colors = [
      Colors.white,
      const Color(0xFFB8D4FF),
      const Color(0xFFFFE8C0),
      const Color(0xFFCCDDFF),
    ];
    _stars = List.generate(
        200,
        (_) => _Star(
              x: rng.nextDouble(),
              y: rng.nextDouble(),
              radius: rng.nextDouble() * 1.8 + 0.2,
              speed: rng.nextDouble() * 2.5 + 0.5,
              offset: rng.nextDouble() * pi * 2,
              color: colors[rng.nextInt(colors.length)],
            ));

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _nebulaPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _planetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _planetScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _planetCtrl, curve: Curves.elasticOut),
    );
    _planetFloat = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _planetCtrl, curve: Curves.easeInOut),
    );

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _ringOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
    );

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _trailCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    const letterCount = 6;
    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _letterFades = List.generate(letterCount, (i) {
      final start = i / letterCount * 0.7;
      final end = start + 0.5;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _titleCtrl,
          curve: Interval(start, end.clamp(0, 1), curve: Curves.easeOut),
        ),
      );
    });
    _letterSlides = List.generate(letterCount, (i) {
      final start = i / letterCount * 0.7;
      final end = start + 0.5;
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _titleCtrl,
          curve: Interval(start, end.clamp(0, 1), curve: Curves.easeOutCubic),
        ),
      );
    });

    _taglineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _taglineFade = CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut);

    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    _planetCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _ringCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 900));
    _titleCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    _taglineCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 2000));
    _exitCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginPage(),
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    _planetCtrl.dispose();
    _orbitCtrl.dispose();
    _ringCtrl.dispose();
    _trailCtrl.dispose();
    _titleCtrl.dispose();
    _taglineCtrl.dispose();
    _dotsCtrl.dispose();
    _exitCtrl.dispose();
    _nebulaPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF020810),
      body: FadeTransition(
        opacity: _exitFade,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _starCtrl,
              builder: (_, __) => CustomPaint(
                painter: _StarfieldPainter(_stars, _starCtrl.value * 2 * pi),
                size: size,
              ),
            ),
            AnimatedBuilder(
              animation: _nebulaPulse,
              builder: (_, __) {
                final p = _nebulaPulse.value;
                return Stack(children: [
                  _nebulaBlob(
                    size: 380 + p * 30,
                    color: const Color(0xFF0D2A55),
                    opacity: 0.35 + p * 0.1,
                    dx: -80,
                    dy: -100,
                  ),
                  _nebulaBlob(
                    size: 300 + p * 20,
                    color: const Color(0xFF2A0D55),
                    opacity: 0.25 + p * 0.08,
                    dx: size.width - 200,
                    dy: size.height * 0.15,
                  ),
                  _nebulaBlob(
                    size: 260,
                    color: const Color(0xFF0D3A40),
                    opacity: 0.2 + p * 0.06,
                    dx: size.width * 0.1,
                    dy: size.height * 0.7,
                  ),
                ]);
              },
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _planetCtrl,
                      _orbitCtrl,
                      _ringCtrl,
                      _trailCtrl,
                    ]),
                    builder: (_, __) {
                      return ScaleTransition(
                        scale: _planetScale,
                        child: SizedBox(
                          width: 180,
                          height: 180,
                          child: CustomPaint(
                            painter: _OrbitSystemPainter(
                              orbitAngle: _orbitCtrl.value * 2 * pi,
                              trailProgress: _trailCtrl.value,
                              ringOpacity: _ringOpacity.value,
                              floatOffset: sin(_planetFloat.value * pi) * 3,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 52),
                  AnimatedBuilder(
                    animation: _titleCtrl,
                    builder: (_, __) {
                      const letters = ['A', 'Q', 'U', 'I', 'L', 'A'];
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(letters.length, (i) {
                          return FadeTransition(
                            opacity: _letterFades[i],
                            child: SlideTransition(
                              position: _letterSlides[i],
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: i == 0 ? 0 : 1.5,
                                ),
                                child: Text(
                                  letters[i],
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 42,
                                    letterSpacing: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    shadows: [
                                      Shadow(
                                        color: const Color(0xFF7EB8F7)
                                            .withOpacity(0.6),
                                        blurRadius: 20,
                                      ),
                                      Shadow(
                                        color: const Color(0xFF7EB8F7)
                                            .withOpacity(0.3),
                                        blurRadius: 40,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: _taglineFade,
                    child: Text(
                      'stargazing whenever, wherever!',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        letterSpacing: 2.5,
                        color: const Color(0xFF7EB8F7).withOpacity(0.55),
                      ),
                    ),
                  ),
                  const SizedBox(height: 64),
                  FadeTransition(
                    opacity: _taglineFade,
                    child: AnimatedBuilder(
                      animation: _dotsCtrl,
                      builder: (_, __) =>
                          _LoadingDots(progress: _dotsCtrl.value),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _taglineFade,
                child: Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.12),
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nebulaBlob({
    required double size,
    required Color color,
    required double opacity,
    required double dx,
    required double dy,
  }) {
    return Positioned(
      left: dx,
      top: dy,
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
    );
  }
}

class _OrbitSystemPainter extends CustomPainter {
  final double orbitAngle;
  final double trailProgress;
  final double ringOpacity;
  final double floatOffset;

  _OrbitSystemPainter({
    required this.orbitAngle,
    required this.trailProgress,
    required this.ringOpacity,
    required this.floatOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + floatOffset);
    const planetR = 42.0;
    const orbitR = 78.0;

    canvas.drawCircle(
      center,
      planetR + 18,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF1A4A8A).withOpacity(0.0),
            const Color(0xFF7EB8F7).withOpacity(0.08),
            const Color(0xFF7EB8F7).withOpacity(0.18),
            const Color(0xFF3A8AEF).withOpacity(0.0),
          ],
          stops: const [0.0, 0.5, 0.75, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: planetR + 18)),
    );

    if (ringOpacity > 0) {
      final orbitPaint = Paint()
        ..color = const Color(0xFF7EB8F7).withOpacity(0.18 * ringOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(1.0, 0.38);
      canvas.drawCircle(Offset.zero, orbitR, orbitPaint);
      canvas.restore();

      final glowPaint = Paint()
        ..color = const Color(0xFF7EB8F7).withOpacity(0.06 * ringOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(1.0, 0.38);
      canvas.drawCircle(Offset.zero, orbitR, glowPaint);
      canvas.restore();
    }

    if (ringOpacity > 0.3) {
      const trailLength = pi * 0.65;
      const steps = 32;
      for (int i = 0; i < steps; i++) {
        final t = i / steps;
        final angle = orbitAngle - t * trailLength;
        final tx = center.dx + orbitR * cos(angle);
        final ty = center.dy + orbitR * 0.38 * sin(angle);
        final trailOpacity = (1 - t) * 0.55 * ringOpacity;
        final trailRadius = 2.5 * (1 - t * 0.7);
        canvas.drawCircle(
          Offset(tx, ty),
          trailRadius,
          Paint()
            ..color = const Color(0xFF7EB8F7).withOpacity(trailOpacity)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, trailRadius * 0.8),
        );
      }
    }

    canvas.drawCircle(
      center,
      planetR,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.4, -0.4),
          radius: 1.2,
          colors: [
            Color(0xFF1A3A70),
            Color(0xFF0A1E45),
            Color(0xFF040D20),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: planetR)),
    );

    final bandColors = [
      const Color(0xFF1E4A8A).withOpacity(0.4),
      const Color(0xFF2A5BA0).withOpacity(0.25),
      const Color(0xFF153570).withOpacity(0.35),
      const Color(0xFF1A4080).withOpacity(0.3),
    ];
    canvas.save();
    canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: planetR)));
    for (int i = 0; i < bandColors.length; i++) {
      final y =
          center.dy - planetR + (i + 0.5) * (planetR * 2 / bandColors.length);
      canvas.drawRect(
        Rect.fromLTRB(
          center.dx - planetR,
          y - planetR / (bandColors.length * 1.2),
          center.dx + planetR,
          y + planetR / (bandColors.length * 1.2),
        ),
        Paint()..color = bandColors[i],
      );
    }
    canvas.restore();

    canvas.drawCircle(
      center,
      planetR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.5, -0.55),
          radius: 0.9,
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: planetR)),
    );

    canvas.drawCircle(
      center,
      planetR,
      Paint()
        ..color = const Color(0xFF7EB8F7).withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1.0, 0.22);

    for (int r = 0; r < 3; r++) {
      final rr = planetR + 10.0 + r * 7;
      final rOpacity = (0.45 - r * 0.1) * ringOpacity;
      canvas.drawCircle(
        Offset.zero,
        rr,
        Paint()
          ..color = const Color(0xFF5A90D0).withOpacity(rOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r == 1 ? 5 : 3,
      );
    }
    canvas.restore();

    if (ringOpacity > 0.1) {
      final starX = center.dx + orbitR * cos(orbitAngle);
      final starY = center.dy + orbitR * 0.38 * sin(orbitAngle);
      final starPos = Offset(starX, starY);

      canvas.drawCircle(
        starPos,
        10,
        Paint()
          ..color = const Color(0xFFE8C87A).withOpacity(0.25 * ringOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawCircle(
        starPos,
        5,
        Paint()
          ..color = const Color(0xFFFFE4A0).withOpacity(0.5 * ringOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      canvas.drawCircle(
        starPos,
        3.5,
        Paint()..color = const Color(0xFFFFEEC0).withOpacity(ringOpacity),
      );

      _drawStarSpikes(canvas, starPos, 3.5, 9.0, ringOpacity);
    }
  }

  void _drawStarSpikes(Canvas canvas, Offset center, double innerR,
      double outerR, double opacity) {
    final paint = Paint()
      ..color = const Color(0xFFFFE8A0).withOpacity(opacity * 0.8)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2;
      canvas.drawLine(
        Offset(
            center.dx + cos(angle) * innerR, center.dy + sin(angle) * innerR),
        Offset(
            center.dx + cos(angle) * outerR, center.dy + sin(angle) * outerR),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitSystemPainter old) =>
      old.orbitAngle != orbitAngle ||
      old.ringOpacity != ringOpacity ||
      old.floatOffset != floatOffset;
}

class _LoadingDots extends StatelessWidget {
  final double progress;
  const _LoadingDots({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final phase = (progress - i * 0.25) % 1.0;
        final scale = 0.5 + 0.5 * sin(phase * pi).clamp(0.0, 1.0);
        final opacity = 0.2 + 0.6 * sin(phase * pi).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7EB8F7).withOpacity(opacity),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7EB8F7).withOpacity(opacity * 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
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
      final opacity = 0.25 + 0.75 * ((sin(phase * s.speed + s.offset) + 1) / 2);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.radius,
        Paint()
          ..color = s.color.withOpacity(opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.radius * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => old.phase != phase;
}
