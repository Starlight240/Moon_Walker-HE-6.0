import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

const String _kApiKey = 'ANTHROPIC_API_KEY';

enum SkyVisibility { excellent, good, fair, poor, blocked }

class SkyScanResult {
  final List<StarIdentification> stars;
  final List<PlanetIdentification> planets;
  final List<ConstellationIdentification> constellations;
  final CloudAnalysis cloudAnalysis;
  final String overallCondition;
  final String observingRecommendation;
  final String rawAnalysis;
  final DateTime scannedAt;

  const SkyScanResult({
    required this.stars,
    required this.planets,
    required this.constellations,
    required this.cloudAnalysis,
    required this.overallCondition,
    required this.observingRecommendation,
    required this.rawAnalysis,
    required this.scannedAt,
  });
}

class StarIdentification {
  final String name;
  final String constellation;
  final String magnitude;
  final String color;
  final String description;
  const StarIdentification({
    required this.name,
    required this.constellation,
    required this.magnitude,
    required this.color,
    required this.description,
  });
}

class PlanetIdentification {
  final String name;
  final String symbol;
  final String brightness;
  final String description;
  const PlanetIdentification({
    required this.name,
    required this.symbol,
    required this.brightness,
    required this.description,
  });
}

class ConstellationIdentification {
  final String name;
  final String season;
  final String description;
  const ConstellationIdentification({
    required this.name,
    required this.season,
    required this.description,
  });
}

class CloudAnalysis {
  final int coveragePercent;
  final SkyVisibility visibility;
  final String cloudType;
  final String transparencyNote;
  const CloudAnalysis({
    required this.coveragePercent,
    required this.visibility,
    required this.cloudType,
    required this.transparencyNote,
  });

  Color get visibilityColor {
    switch (visibility) {
      case SkyVisibility.excellent:
        return const Color(0xFF7EB8F7);
      case SkyVisibility.good:
        return const Color(0xFF88E0B0);
      case SkyVisibility.fair:
        return const Color(0xFFE8C87A);
      case SkyVisibility.poor:
        return const Color(0xFFFFAA66);
      case SkyVisibility.blocked:
        return const Color(0xFFFF6666);
    }
  }

  String get visibilityLabel {
    switch (visibility) {
      case SkyVisibility.excellent:
        return 'Excellent';
      case SkyVisibility.good:
        return 'Good';
      case SkyVisibility.fair:
        return 'Fair';
      case SkyVisibility.poor:
        return 'Poor';
      case SkyVisibility.blocked:
        return 'Blocked';
    }
  }

  IconData get visibilityIcon {
    switch (visibility) {
      case SkyVisibility.excellent:
        return Icons.star_rounded;
      case SkyVisibility.good:
        return Icons.check_circle_rounded;
      case SkyVisibility.fair:
        return Icons.remove_circle_rounded;
      case SkyVisibility.poor:
        return Icons.cloud_rounded;
      case SkyVisibility.blocked:
        return Icons.cloud_off_rounded;
    }
  }
}

class _ClaudeVisionService {
  static const _endpoint = 'https://api.anthropic.com/v1/messages';

  static const _systemPrompt = '''
You are an expert astronomer and astrophotographer analyzing sky images for the Aquila stargazing app.
Your job is to carefully examine the provided image and identify celestial objects and sky conditions.

Always respond with ONLY a valid JSON object — no markdown, no backticks, no preamble.

The JSON must have exactly this structure:
{
  "stars": [
    {
      "name": "Star name or 'Unknown star'",
      "constellation": "Constellation name",
      "magnitude": "e.g. -1.46 or estimated",
      "color": "e.g. blue-white, orange, red",
      "description": "One sentence about this star"
    }
  ],
  "planets": [
    {
      "name": "Planet name",
      "symbol": "Astronomical symbol e.g. ♃ ♄ ♂ ♀ ☿",
      "brightness": "e.g. magnitude -2.8",
      "description": "One sentence about why this planet is identifiable"
    }
  ],
  "constellations": [
    {
      "name": "Constellation name",
      "season": "e.g. Winter, Summer, Autumn, Spring",
      "description": "One sentence about this constellation"
    }
  ],
  "cloudAnalysis": {
    "coveragePercent": 0,
    "visibility": "excellent|good|fair|poor|blocked",
    "cloudType": "e.g. Clear, Cirrus, Cumulus, Stratus, Overcast, or None",
    "transparencyNote": "One sentence about sky transparency and observing conditions"
  },
  "overallCondition": "One sentence overall assessment of the sky",
  "observingRecommendation": "One sentence practical recommendation for stargazers"
}

Rules:
- If you cannot identify specific stars, include an entry with name "Unidentified star" and describe what you see
- If the sky is overcast or no celestial objects are visible, set all arrays to empty and explain in cloudAnalysis
- Be honest — if this is not a sky image at all, set arrays empty and note it in overallCondition
- coveragePercent must be 0-100 integer
- visibility must be exactly one of: excellent, good, fair, poor, blocked
- Always include cloudAnalysis even for clear skies (coveragePercent: 0, cloudType: "Clear")
- Limit to the most prominent/certain identifications only (max 5 stars, 3 planets, 3 constellations)
''';

  static Future<SkyScanResult> analyzeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final ext = imageFile.path.split('.').last.toLowerCase();
    final mediaType = ext == 'png'
        ? 'image/png'
        : ext == 'webp'
            ? 'image/webp'
            : 'image/jpeg';

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _kApiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-sonnet-4-20250514',
        'max_tokens': 1500,
        'system': _systemPrompt,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': mediaType,
                  'data': base64Image,
                },
              },
              {
                'type': 'text',
                'text':
                    'Please analyze this sky image. Identify all visible stars, planets, and constellations. Also assess the cloud cover and sky visibility quality.',
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final rawText = (data['content'] as List)
        .where((c) => c['type'] == 'text')
        .map((c) => c['text'] as String)
        .join('');

    final cleaned =
        rawText.replaceAll('```json', '').replaceAll('```', '').trim();

    final json = jsonDecode(cleaned) as Map<String, dynamic>;
    return _parseResult(json, rawText);
  }

  static SkyScanResult _parseResult(Map<String, dynamic> json, String rawText) {
    final starsJson = (json['stars'] as List?) ?? [];
    final stars = starsJson
        .map((s) => StarIdentification(
              name: s['name'] ?? 'Unknown',
              constellation: s['constellation'] ?? '',
              magnitude: s['magnitude'] ?? '',
              color: s['color'] ?? '',
              description: s['description'] ?? '',
            ))
        .toList();

    final planetsJson = (json['planets'] as List?) ?? [];
    final planets = planetsJson
        .map((p) => PlanetIdentification(
              name: p['name'] ?? 'Unknown',
              symbol: p['symbol'] ?? '●',
              brightness: p['brightness'] ?? '',
              description: p['description'] ?? '',
            ))
        .toList();

    final constJson = (json['constellations'] as List?) ?? [];
    final constellations = constJson
        .map((c) => ConstellationIdentification(
              name: c['name'] ?? 'Unknown',
              season: c['season'] ?? '',
              description: c['description'] ?? '',
            ))
        .toList();

    final ca = json['cloudAnalysis'] as Map<String, dynamic>? ?? {};
    final visStr = ca['visibility'] as String? ?? 'fair';
    final vis = SkyVisibility.values.firstWhere(
      (v) => v.name == visStr,
      orElse: () => SkyVisibility.fair,
    );
    final cloud = CloudAnalysis(
      coveragePercent: (ca['coveragePercent'] as num?)?.toInt() ?? 0,
      visibility: vis,
      cloudType: ca['cloudType'] ?? 'Unknown',
      transparencyNote: ca['transparencyNote'] ?? '',
    );

    return SkyScanResult(
      stars: stars,
      planets: planets,
      constellations: constellations,
      cloudAnalysis: cloud,
      overallCondition: json['overallCondition'] ?? '',
      observingRecommendation: json['observingRecommendation'] ?? '',
      rawAnalysis: rawText,
      scannedAt: DateTime.now(),
    );
  }
}

class _BgStar {
  final double x, y, r, speed, offset;
  final Color color;
  _BgStar(
      {required this.x,
      required this.y,
      required this.r,
      required this.speed,
      required this.offset,
      required this.color});
}

class _StarfieldPainter extends CustomPainter {
  final List<_BgStar> stars;
  final double phase;
  _StarfieldPainter(this.stars, this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final opacity = 0.15 + 0.4 * ((sin(phase * s.speed + s.offset) + 1) / 2);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.r,
        Paint()
          ..color = s.color.withOpacity(opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.r * 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter o) => o.phase != phase;
}

class SkyScannerPage extends StatefulWidget {
  const SkyScannerPage({super.key});

  @override
  State<SkyScannerPage> createState() => _SkyScannerPageState();
}

class _SkyScannerPageState extends State<SkyScannerPage>
    with TickerProviderStateMixin {
  CameraController? _cameraCtrl;
  List<CameraDescription> _cameras = [];
  bool _cameraReady = false;
  bool _cameraError = false;
  String _cameraErrorMsg = '';
  int _currentCameraIndex = 0;

  bool _scanning = false;
  bool _hasResult = false;
  File? _capturedImage;
  SkyScanResult? _result;
  String? _scanError;

  late AnimationController _starCtrl;
  late AnimationController _scanPulseCtrl;
  late AnimationController _resultSlideCtrl;
  late Animation<double> _scanPulse;
  late Animation<Offset> _resultSlide;
  late List<_BgStar> _bgStars;

  int _scanStep = 0;
  static const _scanSteps = [
    'Capturing image…',
    'Sending to AI…',
    'Identifying celestial objects…',
    'Analysing sky conditions…',
    'Finalising results…',
  ];
  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();

    final rng = Random(77);
    final colors = [
      Colors.white,
      const Color(0xFFB8D4FF),
      const Color(0xFFFFE8C0)
    ];
    _bgStars = List.generate(
        80,
        (_) => _BgStar(
              x: rng.nextDouble(),
              y: rng.nextDouble(),
              r: rng.nextDouble() * 1.2 + 0.2,
              speed: rng.nextDouble() * 2 + 0.5,
              offset: rng.nextDouble() * pi * 2,
              color: colors[rng.nextInt(colors.length)],
            ));

    _starCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

    _scanPulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _scanPulse = Tween<double>(begin: 0.85, end: 1.15).animate(
        CurvedAnimation(parent: _scanPulseCtrl, curve: Curves.easeInOut));

    _resultSlideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _resultSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _resultSlideCtrl, curve: Curves.easeOutCubic));

    if (!kIsWeb) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    _cameraCtrl?.dispose();
    _starCtrl.dispose();
    _scanPulseCtrl.dispose();
    _resultSlideCtrl.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _cameraError = true;
          _cameraErrorMsg = 'No camera found on this device.';
        });
        return;
      }
      await _startCamera(_cameras[_currentCameraIndex]);
    } catch (e) {
      setState(() {
        _cameraError = true;
        _cameraErrorMsg = 'Could not access camera: $e';
      });
    }
  }

  Future<void> _startCamera(CameraDescription cam) async {
    final ctrl = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await ctrl.initialize();
      if (!mounted) return;
      _cameraCtrl?.dispose();
      setState(() {
        _cameraCtrl = ctrl;
        _cameraReady = true;
        _cameraError = false;
      });
    } catch (e) {
      setState(() {
        _cameraError = true;
        _cameraErrorMsg = 'Camera error: $e';
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    setState(() => _cameraReady = false);
    await _startCamera(_cameras[_currentCameraIndex]);
  }

  Future<void> _captureAndScan() async {
    if (_scanning) return;

    setState(() {
      _scanning = true;
      _hasResult = false;
      _scanError = null;
      _scanStep = 0;
      _capturedImage = null;
      _result = null;
    });

    _stepTimer = Timer.periodic(const Duration(milliseconds: 1800), (t) {
      if (_scanStep < _scanSteps.length - 1) {
        setState(() => _scanStep++);
      } else {
        t.cancel();
      }
    });

    try {
      File imageFile;

      if (!kIsWeb && _cameraReady && _cameraCtrl != null) {
        final xFile = await _cameraCtrl!.takePicture();
        imageFile = File(xFile.path);
      } else {
        throw Exception('Camera capture is not available on web. '
            'Please run this feature on an Android or iOS device.');
      }

      setState(() {
        _capturedImage = imageFile;
        _scanStep = 2;
      });

      final result = await _ClaudeVisionService.analyzeImage(imageFile);

      _stepTimer?.cancel();
      setState(() {
        _result = result;
        _hasResult = true;
        _scanning = false;
        _scanStep = 0;
      });

      _resultSlideCtrl.forward(from: 0);
    } catch (e) {
      _stepTimer?.cancel();
      setState(() {
        _scanning = false;
        _scanError = e.toString().replaceFirst('Exception: ', '');
        _scanStep = 0;
      });
    }
  }

  void _resetScan() {
    _resultSlideCtrl.reverse().then((_) {
      if (mounted) {
        setState(() {
          _hasResult = false;
          _result = null;
          _capturedImage = null;
          _scanError = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildCameraLayer(),
          if (_scanning) _buildScanningOverlay(),
          _buildTopBar(),
          if (!_scanning && !_hasResult) _buildCameraControls(),
          if (_scanError != null && !_scanning) _buildErrorBanner(),
          if (_hasResult && _result != null) _buildResultsSheet(),
        ],
      ),
    );
  }

  Widget _buildCameraLayer() {
    if (kIsWeb) {
      return Stack(
        children: [
          Container(color: const Color(0xFF020810)),
          AnimatedBuilder(
            animation: _starCtrl,
            builder: (_, __) => CustomPaint(
              painter: _StarfieldPainter(_bgStars, _starCtrl.value * 2 * pi),
              size: MediaQuery.of(context).size,
            ),
          ),
          _nebula(300, const Color(0xFF1A2A5E), 0.35, top: -80, left: -60),
          _nebula(220, const Color(0xFF2A1045), 0.25, bottom: 100, right: -40),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt_rounded,
                    color: const Color(0xFF7EB8F7).withOpacity(0.3), size: 64),
                const SizedBox(height: 16),
                Text('Camera not available on web',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 15,
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
                Text('Run on Android or iOS for full functionality',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.25), fontSize: 12)),
              ],
            ),
          ),
        ],
      );
    }

    if (_cameraError) {
      return Container(
        color: const Color(0xFF020810),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.no_photography_rounded,
                  color: const Color(0xFFFF6666).withOpacity(0.5), size: 56),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(_cameraErrorMsg,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 13,
                        height: 1.5)),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _initCamera,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFF7EB8F7).withOpacity(0.3)),
                  ),
                  child: const Text('Retry',
                      style: TextStyle(color: Color(0xFF7EB8F7))),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_cameraReady || _cameraCtrl == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Color(0xFF7EB8F7)),
        ),
      );
    }

    return SizedBox.expand(
      child: CameraPreview(_cameraCtrl!),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.75),
              Colors.transparent,
            ],
            stops: const [0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                      border: Border.all(
                          color: const Color(0xFF7EB8F7).withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF7EB8F7), size: 16),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI SKY SCANNER',
                        style: TextStyle(
                            color: Color(0xFF7EB8F7),
                            fontSize: 10,
                            letterSpacing: 3.5,
                            fontWeight: FontWeight.w500)),
                    Text('Point camera at the sky & scan',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Georgia')),
                  ],
                ),
                const Spacer(),
                if (!kIsWeb && _cameras.length > 1 && !_scanning && !_hasResult)
                  GestureDetector(
                    onTap: _switchCamera,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Icon(Icons.flip_camera_ios_rounded,
                          color: Colors.white.withOpacity(0.6), size: 18),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.85),
              Colors.transparent,
            ],
            stops: const [0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF7EB8F7).withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: const Color(0xFF7EB8F7).withOpacity(0.6),
                          size: 13),
                      const SizedBox(width: 8),
                      Text(
                        kIsWeb
                            ? 'Camera requires Android or iOS device'
                            : 'Point at the night sky, then tap scan',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: kIsWeb ? null : _captureAndScan,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: kIsWeb
                                ? Colors.white.withOpacity(0.1)
                                : const Color(0xFF7EB8F7).withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                      ),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kIsWeb
                              ? Colors.white.withOpacity(0.08)
                              : Colors.white,
                          boxShadow: kIsWeb
                              ? []
                              : [
                                  const BoxShadow(
                                      color: Color(0x447EB8F7),
                                      blurRadius: 20,
                                      spreadRadius: 4),
                                ],
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: kIsWeb
                              ? Colors.white.withOpacity(0.2)
                              : const Color(0xFF0A1628),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  kIsWeb ? 'Not available on web' : 'TAP TO SCAN',
                  style: TextStyle(
                    color: Colors.white.withOpacity(kIsWeb ? 0.2 : 0.5),
                    fontSize: 10,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _scanPulse,
              builder: (_, __) => Transform.scale(
                scale: _scanPulse.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF7EB8F7).withOpacity(0.1),
                    border: Border.all(
                        color: const Color(0xFF7EB8F7).withOpacity(0.4),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF7EB8F7).withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Color(0xFF7EB8F7), size: 44),
                ),
              ),
            ),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _scanSteps[_scanStep],
                key: ValueKey(_scanStep),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_scanSteps.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _scanStep ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: i == _scanStep
                        ? const Color(0xFF7EB8F7)
                        : const Color(0xFF7EB8F7).withOpacity(0.25),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Text('Claude AI is analysing your sky image',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.35), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Positioned(
      bottom: 120,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0808),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF6666).withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Color(0xFFFF9999), size: 16),
                const SizedBox(width: 8),
                const Text('Scan failed',
                    style: TextStyle(
                        color: Color(0xFFFF9999),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _scanError = null),
                  child: Icon(Icons.close_rounded,
                      color: Colors.white.withOpacity(0.3), size: 16),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(_scanError!,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11.5,
                    height: 1.4)),
            if (_scanError!.contains('API key') ||
                _scanError!.contains('YOUR_ANTHROPIC')) ...[
              const SizedBox(height: 8),
              Text(
                'Set your Anthropic API key in sky_scanner.dart → _kApiKey',
                style: TextStyle(
                    color: const Color(0xFFE8C87A).withOpacity(0.7),
                    fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSheet() {
    final r = _result!;

    return SlideTransition(
      position: _resultSlide,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.80,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF060D1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: Color(0xFF1A3A6B), width: 1),
              left: BorderSide(color: Color(0xFF1A3A6B), width: 1),
              right: BorderSide(color: Color(0xFF1A3A6B), width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    const Spacer(),
                    Container(
                      width: 36,
                      height: 3,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _resetScan,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                        child: Icon(Icons.close_rounded,
                            color: Colors.white.withOpacity(0.4), size: 15),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF7EB8F7).withOpacity(0.1),
                              border: Border.all(
                                  color:
                                      const Color(0xFF7EB8F7).withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.auto_awesome_rounded,
                                color: Color(0xFF7EB8F7), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Scan Complete',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'Georgia',
                                        fontStyle: FontStyle.italic)),
                                Text(
                                  _formatTime(r.scannedAt),
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.35),
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _resetScan,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFF7EB8F7).withOpacity(0.1),
                                border: Border.all(
                                    color: const Color(0xFF7EB8F7)
                                        .withOpacity(0.3)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.camera_alt_rounded,
                                      color: Color(0xFF7EB8F7), size: 13),
                                  SizedBox(width: 5),
                                  Text('Scan again',
                                      style: TextStyle(
                                          color: Color(0xFF7EB8F7),
                                          fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_capturedImage != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Image.file(_capturedImage!,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.4),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 12,
                                child: Text('Captured image',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 10,
                                        letterSpacing: 1)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      _buildVisibilityCard(r.cloudAnalysis),
                      const SizedBox(height: 16),
                      if (r.overallCondition.isNotEmpty)
                        _buildInfoBanner(Icons.info_outline_rounded,
                            r.overallCondition, const Color(0xFF7EB8F7)),
                      if (r.overallCondition.isNotEmpty)
                        const SizedBox(height: 12),
                      if (r.observingRecommendation.isNotEmpty)
                        _buildInfoBanner(Icons.recommend_rounded,
                            r.observingRecommendation, const Color(0xFF88E0B0)),
                      if (r.observingRecommendation.isNotEmpty)
                        const SizedBox(height: 20),
                      if (r.constellations.isNotEmpty) ...[
                        _sectionLabel('✦', 'Constellations Detected',
                            r.constellations.length),
                        const SizedBox(height: 10),
                        ...r.constellations
                            .map((c) => _buildConstellationCard(c)),
                        const SizedBox(height: 16),
                      ],
                      if (r.stars.isNotEmpty) ...[
                        _sectionLabel('★', 'Stars Identified', r.stars.length),
                        const SizedBox(height: 10),
                        ...r.stars.map((s) => _buildStarCard(s)),
                        const SizedBox(height: 16),
                      ],
                      if (r.planets.isNotEmpty) ...[
                        _sectionLabel('●', 'Planets Visible', r.planets.length),
                        const SizedBox(height: 10),
                        ...r.planets.map((p) => _buildPlanetCard(p)),
                        const SizedBox(height: 16),
                      ],
                      if (r.stars.isEmpty &&
                          r.planets.isEmpty &&
                          r.constellations.isEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withOpacity(0.03),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.cloud_rounded,
                                  color: Colors.white.withOpacity(0.2),
                                  size: 40),
                              const SizedBox(height: 12),
                              Text(
                                'No celestial objects detected',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 14,
                                    fontFamily: 'Georgia',
                                    fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Try again with a clearer view of the sky, '
                                'away from lights and clouds.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 12,
                                    height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilityCard(CloudAnalysis ca) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: ca.visibilityColor.withOpacity(0.07),
        border: Border.all(color: ca.visibilityColor.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(ca.visibilityIcon, color: ca.visibilityColor, size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sky Visibility',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10,
                          letterSpacing: 2)),
                  Text(ca.visibilityLabel,
                      style: TextStyle(
                          color: ca.visibilityColor,
                          fontSize: 18,
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300)),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: ca.coveragePercent / 100,
                      backgroundColor: Colors.white.withOpacity(0.06),
                      color: ca.visibilityColor,
                      strokeWidth: 5,
                    ),
                    Text('${ca.coveragePercent}%',
                        style: TextStyle(
                            color: ca.visibilityColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('cloud\ncover',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 10,
                      height: 1.3)),
            ],
          ),
          if (ca.cloudType.isNotEmpty && ca.cloudType != 'None') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.cloud_outlined,
                    color: Colors.white.withOpacity(0.3), size: 13),
                const SizedBox(width: 6),
                Text('Cloud type: ${ca.cloudType}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ],
          if (ca.transparencyNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(ca.transparencyNote,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Georgia')),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoBanner(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.6), size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 12.5,
                    height: 1.45)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String bullet, String title, int count) {
    return Row(
      children: [
        Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: const Color(0xFFE8C87A))),
        const SizedBox(width: 10),
        Text(title.toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontSize: 10, letterSpacing: 2.5)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF7EB8F7).withOpacity(0.12),
          ),
          child: Text('$count',
              style: const TextStyle(color: Color(0xFF7EB8F7), fontSize: 10)),
        ),
      ],
    );
  }

  Widget _buildStarCard(StarIdentification s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0A1220),
        border: Border.all(color: const Color(0xFF7EB8F7).withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7EB8F7).withOpacity(0.1),
              border:
                  Border.all(color: const Color(0xFF7EB8F7).withOpacity(0.3)),
            ),
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF7EB8F7),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(s.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Georgia',
                            fontStyle: FontStyle.italic)),
                    if (s.constellation.isNotEmpty) ...[
                      Text('  ·  ',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.2),
                              fontSize: 12)),
                      Flexible(
                        child: Text(s.constellation,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: const Color(0xFF7EB8F7).withOpacity(0.7),
                                fontSize: 11)),
                      ),
                    ],
                  ],
                ),
                if (s.magnitude.isNotEmpty || s.color.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (s.magnitude.isNotEmpty)
                        _miniTag('mag ${s.magnitude}', const Color(0xFFE8C87A)),
                      if (s.color.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _miniTag(s.color, const Color(0xFF88E0B0)),
                      ],
                    ],
                  ),
                ],
                if (s.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(s.description,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 11.5,
                          height: 1.4)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetCard(PlanetIdentification p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0A1220),
        border: Border.all(color: const Color(0xFFE8C87A).withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8C87A).withOpacity(0.1),
              border:
                  Border.all(color: const Color(0xFFE8C87A).withOpacity(0.3)),
            ),
            child: Center(
              child: Text(p.symbol,
                  style:
                      const TextStyle(color: Color(0xFFE8C87A), fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(p.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Georgia',
                            fontStyle: FontStyle.italic)),
                    if (p.brightness.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _miniTag(p.brightness, const Color(0xFFE8C87A)),
                    ],
                  ],
                ),
                if (p.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(p.description,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 11.5,
                          height: 1.4)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConstellationCard(ConstellationIdentification c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0A1220),
        border: Border.all(color: const Color(0xFF88E0B0).withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF88E0B0).withOpacity(0.1),
              border:
                  Border.all(color: const Color(0xFF88E0B0).withOpacity(0.3)),
            ),
            child: const Icon(Icons.star_border_rounded,
                color: Color(0xFF88E0B0), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(c.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Georgia',
                            fontStyle: FontStyle.italic)),
                    if (c.season.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _miniTag(c.season, const Color(0xFF88E0B0)),
                    ],
                  ],
                ),
                if (c.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(c.description,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 11.5,
                          height: 1.4)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(text,
          style: TextStyle(color: color.withOpacity(0.9), fontSize: 10)),
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
                colors: [color.withOpacity(opacity), Colors.transparent]),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return 'Scanned at $h:$m:$s';
  }
}

/* import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  MyApp(this.cameras);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AI_sky(cameras: cameras),
    );
  }
}

enum ViewMode { sensor, cameraAI }

class AI_sky extends StatefulWidget {
  final List<CameraDescription> cameras;
  const AI_sky({super.key, required this.cameras});

  @override
  State<AI_sky> createState() => _SkyViewerPageState();
}

class _SkyViewerPageState extends State<AI_sky> {
  late CameraController _controller;
  ViewMode _mode = ViewMode.cameraAI;

  String visibility = "Analyzing...";
  double cloudRatio = 0.0;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final backCamera = widget.cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller.initialize();

    _controller.startImageStream((CameraImage image) {
      processFrame(image);
    });

    setState(() {});
  }

  void processFrame(CameraImage cameraImage) async {
    try {
      final img.Image image = convertCameraImage(cameraImage);

      final ratio = estimateCloudCoverage(image);
      final vis = getVisibility(ratio);

      setState(() {
        cloudRatio = ratio;
        visibility = vis;
      });
    } catch (e) {
    }
  }

  img.Image convertCameraImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final img.Image imgImage = img.Image(width: width, height: height);

    final plane = cameraImage.planes[0];
    final bytes = plane.bytes;

    int pixelIndex = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final luminance = bytes[pixelIndex];
        imgImage.setPixelRgba(x, y, luminance, luminance, luminance, luminance);
        pixelIndex++;
      }
    }

    return imgImage;
  }

  double estimateCloudCoverage(img.Image image) {
    int cloudy = 0;
    int total = 0;

    for (int y = 0; y < image.height; y += 8) {
      for (int x = 0; x < image.width; x += 8) {
        final pixel = image.getPixel(x, y);
        final brightness = img.getLuminance(pixel);

        if (brightness > 180) {
          cloudy++;
        }
        total++;
      }
    }

    return cloudy / total;
  }

  String getVisibility(double ratio) {
    if (ratio < 0.2) return "Excellent";
    if (ratio < 0.4) return "Good";
    if (ratio < 0.7) return "Poor";
    return "Very Cloudy";
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller),
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Visibility: $visibility",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Clouds: ${(cloudRatio * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _mode = _mode == ViewMode.cameraAI
                        ? ViewMode.sensor
                        : ViewMode.cameraAI;
                  });
                },
                child: Text(_mode == ViewMode.cameraAI
                    ? "Switch to Sky Mode"
                    : "Switch to Camera AI"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/
