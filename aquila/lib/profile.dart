import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login.dart';
import 'starfield.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  User? user;

  final _nameCtrl = TextEditingController();

  late AnimationController _starCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  late List<Star> _stars;

  @override
  void initState() {
    super.initState();

    user = _auth.currentUser;
    _nameCtrl.text = user?.displayName ?? '';

    final rng = Random(7);
    final starColors = [
      Colors.white,
      const Color(0xFFB8D4FF),
      const Color(0xFFFFE8C0),
    ];

    _stars = List.generate(
      120,
      (_) => Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: rng.nextDouble() * 1.6 + 0.3,
        speed: rng.nextDouble() * 2 + 0.5,
        offset: rng.nextDouble() * pi * 2,
        color: starColors[rng.nextInt(starColors.length)],
      ),
    );

    _starCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideCtrl,
      curve: Curves.easeOutCubic,
    ));

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    await user?.updateDisplayName(_nameCtrl.text.trim());
    setState(() {});
    _showSnack("Name updated ✨");
  }

  Future<void> _resetPassword() async {
    if (user?.email == null) return;
    await _auth.sendPasswordResetEmail(email: user!.email!);
    _showSnack("Password reset email sent");
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Color(0xFF7EB8F7))),
      backgroundColor: const Color(0xFF0A1628),
      behavior: SnackBarBehavior.floating,
    ));
  }



  Widget _buildHeader() {
    return Row(
      children: [
        // Back to home page :)
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0A1628).withOpacity(0.9),
              border: Border.all(
                color: const Color(0xFF7EB8F7).withOpacity(0.25),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF7EB8F7),
              size: 16,
            ),
          ),
        ),

        const SizedBox(width: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PROFILE',
              style: TextStyle(
                color: Color(0xFF7EB8F7),
                fontSize: 10,
                letterSpacing: 4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Your account & preferences',
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
              color: const Color(0xFF7EB8F7).withOpacity(0.2),
            ),
          ),
          child: Icon(
            Icons.settings_rounded,
            color: const Color(0xFF7EB8F7).withOpacity(0.6),
            size: 18,
          ),
        ),
      ],
    );
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
              painter: StarfieldPainter(_stars, _starCtrl.value * 2 * pi),
              size: MediaQuery.of(context).size,
            ),
          ),

          _nebula(260, const Color(0xFF1A3A6B), 0.4, top: -80, left: -80),
          _nebula(220, const Color(0xFF3B1A5E), 0.3, top: 120, right: -60),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      _buildHeader(),

                      const SizedBox(height: 12),
                      Divider(color: Colors.white.withOpacity(0.08)),

                      const SizedBox(height: 24),

                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFF0E2040),
                        child: Text(
                          (user?.displayName ?? "A")[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Color(0xFF7EB8F7),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: const Color(0xFF080F1E).withOpacity(0.9),
                          border: Border.all(
                            color:
                                const Color(0xFF7EB8F7).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _nameCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: "Display Name",
                                labelStyle:
                                    TextStyle(color: Colors.white54),
                              ),
                            ),

                            const SizedBox(height: 16),

                            _actionButton("Update Name", _updateName),
                            const SizedBox(height: 10),
                            _actionButton("Reset Password", _resetPassword),
                            const SizedBox(height: 10),
                            _actionButton("Logout", _logout, isDanger: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _actionButton(String text, VoidCallback onTap,
      {bool isDanger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: isDanger
                ? [Colors.red.shade400, Colors.red.shade800]
                : [const Color(0xFF1A4A8A), const Color(0xFF0D2A55)],
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }


  Widget _nebula(double size, Color color, double opacity,
      {double? top, double? left, double? right}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
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