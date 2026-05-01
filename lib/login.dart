

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main.dart';

/*for testing without Firebase wired up
  void main() => runApp(const _AquilaApp());
  class _AquilaApp extends StatelessWidget {
  c onst _AquilaApp();
    @override
  Widget build(BuildContext context) => MaterialApp(
    home: const LoginPage(),
    theme: ThemeData(brightness: Brightness.dark),
  );
}
*/


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
      final opacity = 0.3 + 0.7 * ((sin(phase * s.speed + s.offset) + 1) / 2);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.radius,
        Paint()
          ..color = s.color.withOpacity(opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.radius * 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => old.phase != phase;
}


class LoginPage extends StatefulWidget {
  
  final VoidCallback? onAuthenticated;
  const LoginPage({super.key, this.onAuthenticated});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _starCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late List<_Star> _stars;

  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    final rng = Random(7);
    final starColors = [
      Colors.white,
      const Color(0xFFB8D4FF),
      const Color(0xFFFFE8C0)
    ];
    _stars = List.generate(
        140,
        (_) => _Star(
              x: rng.nextDouble(),
              y: rng.nextDouble(),
              radius: rng.nextDouble() * 1.6 + 0.3,
              speed: rng.nextDouble() * 2 + 0.5,
              offset: rng.nextDouble() * pi * 2,
              color: starColors[rng.nextInt(starColors.length)],
            ));

    _starCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
      _formKey.currentState?.reset();
      _emailCtrl.clear();
      _passwordCtrl.clear();
      _confirmCtrl.clear();
      _nameCtrl.clear();
    });
    _slideCtrl.forward(from: 0);
    _fadeCtrl.forward(from: 0.6);
  }


  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      } else {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
        // Save display name
        await credential.user?.updateDisplayName(_nameCtrl.text.trim());
      }

      /*if (mounted) {
        setState(() => _loading = false);
        widget.onAuthenticated?.call();
        if (widget.onAuthenticated == null && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }*/
      if (mounted) {
        setState(() => _loading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = _friendlyError(e.code);
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() =>
          _errorMessage = 'Enter your email first, then tap Forgot Password.');
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (mounted) _showSnack('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _friendlyError(e.code));
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Color(0xFF7EB8F7))),
      backgroundColor: const Color(0xFF0A1628),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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

          _nebula(300, const Color(0xFF1A3A6B), 0.4, top: -100, left: -80),
          _nebula(240, const Color(0xFF3B1A5E), 0.3, top: 120, right: -60),
          _nebula(200, const Color(0xFF0D3050), 0.35, bottom: -60, left: 60),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      _buildLogo(),
                      const SizedBox(height: 48),
                      _buildCard(),
                      const SizedBox(height: 32),
                      _buildToggleRow(),
                      const SizedBox(height: 40),
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


  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: const Color(0xFF7EB8F7).withOpacity(0.25), width: 1.5),
            gradient: const RadialGradient(
              colors: [Color(0xFF0E2040), Color(0xFF050D1A)],
            ),
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(42, 42),
              painter: _EaglePainter(),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'AQUILA',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 32,
            letterSpacing: 10,
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'stargazing whenever, wherever!',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 2,
            color: const Color(0xFF7EB8F7).withOpacity(0.6),
            fontStyle: FontStyle.italic,
            fontFamily: 'Georgia',
          ),
        ),
      ],
    );
  }


  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFF080F1E).withOpacity(0.85),
        border: Border.all(
            color: const Color(0xFF7EB8F7).withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7EB8F7).withOpacity(0.04),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isLogin ? 'Welcome back!' : 'Join Aquila!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isLogin
                    ? 'Sign in to continue stargazing'
                    : 'Create your account to begin',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),

              if (!_isLogin) ...[
                _buildField(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: 16),
              ],

              _buildField(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter your email';
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildField(
                controller: _passwordCtrl,
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                obscure: _obscurePassword,
                toggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter your password';
                  if (!_isLogin && v.length < 6) return 'At least 6 characters';
                  return null;
                },
              ),

              if (!_isLogin) ...[
                const SizedBox(height: 16),
                _buildField(
                  controller: _confirmCtrl,
                  label: 'Confirm Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscureConfirm,
                  toggleObscure: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (v != _passwordCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],

              if (_isLogin) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _forgotPassword,
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: const Color(0xFF7EB8F7).withOpacity(0.7),
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            const Color(0xFF7EB8F7).withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ],

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Color(0xFFFF9999), size: 15),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFFF9999),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              GestureDetector(
                onTap: _loading ? null : _submit,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: _loading
                          ? [
                              const Color(0xFF1A3A6B).withOpacity(0.5),
                              const Color(0xFF1A3A6B).withOpacity(0.3),
                            ]
                          : [
                              const Color(0xFF1A4A8A),
                              const Color(0xFF0D2A55),
                            ],
                    ),
                    border: Border.all(
                      color: _loading
                          ? const Color(0xFF7EB8F7).withOpacity(0.1)
                          : const Color(0xFF7EB8F7).withOpacity(0.4),
                    ),
                    boxShadow: _loading
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFF7EB8F7).withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF7EB8F7),
                            ),
                          )
                        : Text(
                            _isLogin ? 'Sign In' : 'Create Account',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Georgia',
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                        child: Divider(color: Colors.white.withOpacity(0.08))),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      /*child: Text(
                        'or continue with',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 11,
                        ),
                      ),*/
                    ),
                    Expanded(
                        child: Divider(color: Colors.white.withOpacity(0.08))),
                  ],
                ),
              ),

              /*// Google sign-in button
              GestureDetector(
                onTap: () => _showSnack(
                    'Add google_sign_in package to enable Google login'),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withOpacity(0.04),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GoogleLogo(),
                      const SizedBox(width: 10),
                      Text(
                        'Google',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: const Color(0xFF7EB8F7),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon,
            color: const Color(0xFF7EB8F7).withOpacity(0.5), size: 18),
        suffixIcon: toggleObscure != null
            ? GestureDetector(
                onTap: toggleObscure,
                child: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white.withOpacity(0.3),
                  size: 18,
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF0A1628).withOpacity(0.6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: const Color(0xFF7EB8F7).withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: const Color(0xFF7EB8F7).withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: const Color(0xFF7EB8F7).withOpacity(0.5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF9999), fontSize: 11),
      ),
    );
  }


  Widget _buildToggleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? 'New to Aquila? ' : 'Already have an account? ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 13,
          ),
        ),
        GestureDetector(
          onTap: _toggleMode,
          child: Text(
            _isLogin ? 'Create account' : 'Sign in',
            style: const TextStyle(
              color: Color(0xFF7EB8F7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF7EB8F7),
            ),
          ),
        ),
      ],
    );
  }


  Widget _nebula(double size, Color color, double opacity,
      {double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
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

class _EaglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF7EB8F7).withOpacity(0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF7EB8F7)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = const Color(0xFF7EB8F7).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final stars = [
      Offset(size.width * 0.50, size.height * 0.42),
      Offset(size.width * 0.50, size.height * 0.20),
      Offset(size.width * 0.50, size.height * 0.65),
      Offset(size.width * 0.25, size.height * 0.35),
      Offset(size.width * 0.75, size.height * 0.30),
      Offset(size.width * 0.20, size.height * 0.60),
      Offset(size.width * 0.80, size.height * 0.58),
    ];

    final lines = [
      [0, 1],
      [0, 2],
      [0, 3],
      [0, 4],
      [3, 5],
      [4, 6],
    ];
    for (final l in lines) {
      canvas.drawLine(stars[l[0]], stars[l[1]], linePaint);
    }

    for (int i = 0; i < stars.length; i++) {
      final r = i == 0 ? 3.5 : (i <= 2 ? 2.2 : 1.5);
      canvas.drawCircle(stars[i], r + 1.5, glowPaint);
      canvas.drawCircle(stars[i], r, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

/*
class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _GoogleLogoPainter(),
    );
  }
}*/

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    paint.color = const Color(0xFF4285F4).withOpacity(0.8);
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r - 1),
        pi * 0.15,
        pi * 1.7,
        false,
        paint);

    paint.color = const Color(0xFF7EB8F7).withOpacity(0.7);
    paint.strokeWidth = 2.0;
    canvas.drawLine(
      Offset(c.dx, c.dy),
      Offset(c.dx + r - 1, c.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
