/*import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class SkyViewerPage extends StatefulWidget {
  const SkyViewerPage({super.key});

  @override
  State<SkyViewerPage> createState() => _SkyViewerPageState();
}

class _SkyViewerPageState extends State<SkyViewerPage> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  bool arAvailable = true;
  bool placed = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF020810),
      body: Stack(
        children: [
          arAvailable ? _buildARView() : _buildFallbackSky(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),
                  const Spacer(),
                  _instructionCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildARView() {
    return ARView(
      onARViewCreated: _onARCreated,
      planeDetectionConfig: PlaneDetectionConfig.horizontal,
    );
  }

  void _onARCreated(
    ARSessionManager session,
    ARObjectManager object,
    ARAnchorManager anchor,
    ARLocationManager location,
  ) {
    arSessionManager = session;
    arObjectManager = object;
    arAnchorManager = anchor;

    session.onInitialize(
      showPlanes: true,
      handleTaps: true,
    );

    object.onInitialize();

    session.onPlaneOrPointTap = _onTap;
  }

  Future<void> _onTap(List<ARHitTestResult> hits) async {
    if (placed) return;

    final hit = hits.first;

    final anchor = ARPlaneAnchor(
      transformation: hit.worldTransform,
    );

    final added = await arAnchorManager?.addAnchor(anchor);

    if (added ?? false) {
      await _addSky(anchor);
      setState(() => placed = true);
    }
  }

  Future<void> _addSky(ARPlaneAnchor anchor) async {
    final node = ARNode(
      type: NodeType.webGLB,
      uri:
          "https://modelviewer.dev/shared-assets/models/Astronaut.glb",
      scale: vm.Vector3(1.5, 1.5, 1.5),
      position: vm.Vector3(0, 0, 0),
    );

    await arObjectManager?.addNode(node, planeAnchor: anchor);
  }


  Widget _buildFallbackSky() {
    return AnimatedStarfield();
  }


  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFF7EB8F7).withOpacity(0.3)),
            ),
            child: const Icon(Icons.arrow_back,
                color: Color(0xFF7EB8F7), size: 20),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          "AR SKY",
          style: TextStyle(
            color: Color(0xFF7EB8F7),
            letterSpacing: 3,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _instructionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFF7EB8F7).withOpacity(0.2)),
        gradient: const LinearGradient(
          colors: [Color(0xFF0E2040), Color(0xFF1A0D35)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CEILING MODE",
            style: TextStyle(
              color: Color(0xFF7EB8F7),
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            placed
                ? "Sky placed above you ✨"
                : "Point your camera at the ceiling\nand tap to project the sky",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Georgia',
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedStarfield extends StatefulWidget {
  @override
  State<AnimatedStarfield> createState() => _AnimatedStarfieldState();
}

class _AnimatedStarfieldState extends State<AnimatedStarfield>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late List<_Star> stars;

  @override
  void initState() {
    super.initState();

    final rng = Random();

    stars = List.generate(
      150,
      (_) => _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        r: rng.nextDouble() * 1.5 + 0.5,
        speed: rng.nextDouble() * 2,
      ),
    );

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _StarPainter(stars, controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Star {
  double x, y, r, speed;
  _Star({required this.x, required this.y, required this.r, required this.speed});
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;

  _StarPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final opacity = 0.4 + 0.6 * sin(t * pi * 2 * s.speed);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.r,
        Paint()
          ..color = Colors.white.withOpacity(opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
*/