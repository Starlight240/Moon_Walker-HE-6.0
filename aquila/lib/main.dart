import 'dart:math';

import 'package:aquila/coming_soon.dart';
import 'package:aquila/events.dart';
import 'package:aquila/profile.dart';
import 'package:aquila/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'map.dart';
import 'sky_viewer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Aquila());
}

enum AppLanguage { english, romanian, french, german, turkish, hungarian }

extension AppLanguageExtension on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'EN';
      case AppLanguage.romanian:
        return 'RO';
      case AppLanguage.french:
        return 'FR';
      case AppLanguage.german:
        return 'DE';
      case AppLanguage.turkish:
        return 'TR';
      case AppLanguage.hungarian:
        return 'HU';
    }
  }

  String get nativeName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.romanian:
        return 'Română';
      case AppLanguage.french:
        return 'Français';
      case AppLanguage.german:
        return 'Deutsch';
      case AppLanguage.turkish:
        return 'Türkçe';
      case AppLanguage.hungarian:
        return 'Magyar';
    }
  }

  String get flag {
    switch (this) {
      case AppLanguage.english:
        return '🇬🇧';
      case AppLanguage.romanian:
        return '🇷🇴';
      case AppLanguage.french:
        return '🇫🇷';
      case AppLanguage.german:
        return '🇩🇪';
      case AppLanguage.turkish:
        return '🇹🇷';
      case AppLanguage.hungarian:
        return '🇭🇺';
    }
  }
}

class LocaleProvider extends InheritedWidget {
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  const LocaleProvider({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    required super.child,
  });

  static LocaleProvider of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<LocaleProvider>();
    assert(result != null, 'No LocaleProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(LocaleProvider old) => old.language != language;
}

class AppLocalizations {
  final AppLanguage language;
  const AppLocalizations(this.language);

  static AppLocalizations of(BuildContext context) =>
      AppLocalizations(LocaleProvider.of(context).language);

  String get appName => 'AQUILA';

  String get chooseLanguage {
    switch (language) {
      case AppLanguage.english:
        return 'Choose Language';
      case AppLanguage.romanian:
        return 'Alege Limba';
      case AppLanguage.french:
        return 'Choisir la Langue';
      case AppLanguage.german:
        return 'Sprache Wählen';
      case AppLanguage.turkish:
        return 'Dil Seçin';
      case AppLanguage.hungarian:
        return 'Nyelv Választása';
    }
  }

  String get selectLanguageSubtitle {
    switch (language) {
      case AppLanguage.english:
        return 'The app will update instantly';
      case AppLanguage.romanian:
        return 'Aplicația se va actualiza instant';
      case AppLanguage.french:
        return 'L\'app se mettra à jour instantanément';
      case AppLanguage.german:
        return 'Die App wird sofort aktualisiert';
      case AppLanguage.turkish:
        return 'Uygulama anında güncellenecek';
      case AppLanguage.hungarian:
        return 'Az alkalmazás azonnal frissül';
    }
  }

  String get homeGreeting {
    switch (language) {
      case AppLanguage.english:
        return 'Hello,\nStar Lover!';
      case AppLanguage.romanian:
        return 'Bună,\nIubitor de Stele!';
      case AppLanguage.french:
        return 'Bonjour,\nAmoureux des Étoiles!';
      case AppLanguage.german:
        return 'Hallo,\nSternenfan!';
      case AppLanguage.turkish:
        return 'Merhaba,\nYıldız Sever!';
      case AppLanguage.hungarian:
        return 'Szia,\nCsillag Kedvelő!';
    }
  }

  String get tonightEvents {
    switch (language) {
      case AppLanguage.english:
        return 'Tonight\'s Events';
      case AppLanguage.romanian:
        return 'Evenimente de Azi-Noapte';
      case AppLanguage.french:
        return 'Événements de Ce Soir';
      case AppLanguage.german:
        return 'Heutige Abendereignisse';
      case AppLanguage.turkish:
        return 'Bu Geceki Olaylar';
      case AppLanguage.hungarian:
        return 'Mai Esti Események';
    }
  }

  String get darkSkySpots {
    switch (language) {
      case AppLanguage.english:
        return 'Dark Sky Spots Near You';
      case AppLanguage.romanian:
        return 'Locuri cu Cer Întunecat';
      case AppLanguage.french:
        return 'Sites à Ciel Noir Proches';
      case AppLanguage.german:
        return 'Dunkelhimmelplätze in der Nähe';
      case AppLanguage.turkish:
        return 'Yakınındaki Karanlık Gökyüzü';
      case AppLanguage.hungarian:
        return 'Közeli Sötét Égbolt Helyek';
    }
  }

  String get openArView {
    switch (language) {
      case AppLanguage.english:
        return 'Open AR view';
      case AppLanguage.romanian:
        return 'Deschide vedere AR';
      case AppLanguage.french:
        return 'Ouvrir la vue RA';
      case AppLanguage.german:
        return 'AR-Ansicht öffnen';
      case AppLanguage.turkish:
        return 'AR görünümünü aç';
      case AppLanguage.hungarian:
        return 'AR nézet megnyitása';
    }
  }

  String get pointAtSky {
    switch (language) {
      case AppLanguage.english:
        return 'Point at the sky\nto start exploring';
      case AppLanguage.romanian:
        return 'Îndreptați spre cer\npentru a explora';
      case AppLanguage.french:
        return 'Pointez vers le ciel\npour explorer';
      case AppLanguage.german:
        return 'Zeige zum Himmel\nzum Erkunden';
      case AppLanguage.turkish:
        return 'Keşfetmek için\ngökyüzüne işaret et';
      case AppLanguage.hungarian:
        return 'Mutass az égre\na felfedezéshez';
    }
  }

  String get liveSkyView {
    switch (language) {
      case AppLanguage.english:
        return 'LIVE SKY VIEW';
      case AppLanguage.romanian:
        return 'VED. CER ÎN DIRECT';
      case AppLanguage.french:
        return 'VUE CIEL EN DIRECT';
      case AppLanguage.german:
        return 'LIVE-HIMMELSANSICHT';
      case AppLanguage.turkish:
        return 'CANLI GÖKYÜZÜ';
      case AppLanguage.hungarian:
        return 'ÉLŐ ÉG NÉZET';
    }
  }

  String get openFullMap {
    switch (language) {
      case AppLanguage.english:
        return 'Open full map';
      case AppLanguage.romanian:
        return 'Deschide harta';
      case AppLanguage.french:
        return 'Ouvrir la carte';
      case AppLanguage.german:
        return 'Karte öffnen';
      case AppLanguage.turkish:
        return 'Haritayı aç';
      case AppLanguage.hungarian:
        return 'Térkép megnyitása';
    }
  }

  String get navHome {
    switch (language) {
      case AppLanguage.english:
        return 'Home';
      case AppLanguage.romanian:
        return 'Acasă';
      case AppLanguage.french:
        return 'Accueil';
      case AppLanguage.german:
        return 'Start';
      case AppLanguage.turkish:
        return 'Ana Sayfa';
      case AppLanguage.hungarian:
        return 'Főoldal';
    }
  }

  String get navSky {
    switch (language) {
      case AppLanguage.english:
        return 'Sky';
      case AppLanguage.romanian:
        return 'Cer';
      case AppLanguage.french:
        return 'Ciel';
      case AppLanguage.german:
        return 'Himmel';
      case AppLanguage.turkish:
        return 'Gökyüzü';
      case AppLanguage.hungarian:
        return 'Égbolt';
    }
  }

  String get navEvents {
    switch (language) {
      case AppLanguage.english:
        return 'Events';
      case AppLanguage.romanian:
        return 'Evenimente';
      case AppLanguage.french:
        return 'Événements';
      case AppLanguage.german:
        return 'Ereignisse';
      case AppLanguage.turkish:
        return 'Etkinlikler';
      case AppLanguage.hungarian:
        return 'Események';
    }
  }

  String get navMap {
    switch (language) {
      case AppLanguage.english:
        return 'Map';
      case AppLanguage.romanian:
        return 'Hartă';
      case AppLanguage.french:
        return 'Carte';
      case AppLanguage.german:
        return 'Karte';
      case AppLanguage.turkish:
        return 'Harita';
      case AppLanguage.hungarian:
        return 'Térkép';
    }
  }

  String get navProfile {
    switch (language) {
      case AppLanguage.english:
        return 'Profile';
      case AppLanguage.romanian:
        return 'Profil';
      case AppLanguage.french:
        return 'Profil';
      case AppLanguage.german:
        return 'Profil';
      case AppLanguage.turkish:
        return 'Profil';
      case AppLanguage.hungarian:
        return 'Profil';
    }
  }

  String get eventLunarEclipse {
    switch (language) {
      case AppLanguage.english:
        return 'Lunar Eclipse';
      case AppLanguage.romanian:
        return 'Eclipsă de Lună';
      case AppLanguage.french:
        return 'Éclipse Lunaire';
      case AppLanguage.german:
        return 'Mondfinsternis';
      case AppLanguage.turkish:
        return 'Ay Tutulması';
      case AppLanguage.hungarian:
        return 'Holdfogyatkozás';
    }
  }

  String get eventLunarSub {
    switch (language) {
      case AppLanguage.english:
        return 'Penumbral · Full visibility';
      case AppLanguage.romanian:
        return 'Penumbrală · Vizibilitate totală';
      case AppLanguage.french:
        return 'Pénombrale · Visibilité totale';
      case AppLanguage.german:
        return 'Halbschatten · Volle Sichtbarkeit';
      case AppLanguage.turkish:
        return 'Yarı gölge · Tam görünürlük';
      case AppLanguage.hungarian:
        return 'Félárnyék · Teljes láthatóság';
    }
  }

  String get eventPerseid {
    switch (language) {
      case AppLanguage.english:
        return 'Perseid Meteor Shower';
      case AppLanguage.romanian:
        return 'Ploaia de Meteori Perseid';
      case AppLanguage.french:
        return 'Pluie de Météorites Perséides';
      case AppLanguage.german:
        return 'Perseiden-Meteorschauer';
      case AppLanguage.turkish:
        return 'Perseid Meteor Yağmuru';
      case AppLanguage.hungarian:
        return 'Perseidák Meteor-zápor';
    }
  }

  String get eventPerseidSub {
    switch (language) {
      case AppLanguage.english:
        return 'Peak activity · 90/hr';
      case AppLanguage.romanian:
        return 'Activitate maximă · 90/oră';
      case AppLanguage.french:
        return 'Activité maximale · 90/h';
      case AppLanguage.german:
        return 'Höchstaktivität · 90/Std';
      case AppLanguage.turkish:
        return 'En yüksek aktivite · 90/sa';
      case AppLanguage.hungarian:
        return 'Csúcsaktivitás · 90/óra';
    }
  }

  String get eventJupiter {
    switch (language) {
      case AppLanguage.english:
        return 'Jupiter at Opposition';
      case AppLanguage.romanian:
        return 'Jupiter în Opoziție';
      case AppLanguage.french:
        return 'Jupiter en Opposition';
      case AppLanguage.german:
        return 'Jupiter in Opposition';
      case AppLanguage.turkish:
        return 'Jüpiter Kavuşum Karşıtı';
      case AppLanguage.hungarian:
        return 'Jupiter Szembenállásban';
    }
  }

  String get eventJupiterSub {
    switch (language) {
      case AppLanguage.english:
        return 'Closest approach of 2026';
      case AppLanguage.romanian:
        return 'Cea mai apropiată de 2026';
      case AppLanguage.french:
        return 'Approche la plus proche de 2026';
      case AppLanguage.german:
        return 'Nächste Annäherung 2026';
      case AppLanguage.turkish:
        return '2026\'nın en yakın geçişi';
      case AppLanguage.hungarian:
        return '2026 legközelebbi megközelítése';
    }
  }

  String get bestSpot {
    switch (language) {
      case AppLanguage.english:
        return 'Best spot\n32 km';
      case AppLanguage.romanian:
        return 'Loc ideal\n32 km';
      case AppLanguage.french:
        return 'Meilleur site\n32 km';
      case AppLanguage.german:
        return 'Bester Ort\n32 km';
      case AppLanguage.turkish:
        return 'En iyi yer\n32 km';
      case AppLanguage.hungarian:
        return 'Legjobb hely\n32 km';
    }
  }
}

class Aquila extends StatefulWidget {
  const Aquila({super.key});

  @override
  State<Aquila> createState() => _AquilaState();
}

class _AquilaState extends State<Aquila> {
  AppLanguage _language = AppLanguage.english;

  @override
  Widget build(BuildContext context) {
    return LocaleProvider(
      language: _language,
      onLanguageChanged: (lang) => setState(() => _language = lang),
      child: MaterialApp(
        title: 'Aquila',
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
        home: const SplashScreen(),
      ),
    );
  }
}

class StarfieldPainter extends CustomPainter {
  final List<StarPoint> stars;
  final double twinklePhase;

  StarfieldPainter(this.stars, this.twinklePhase);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final opacity =
          0.4 + 0.6 * ((sin(twinklePhase * star.speed + star.offset) + 1) / 2);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        Paint()
          ..color = star.color.withOpacity(opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.radius * 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter old) => old.twinklePhase != twinklePhase;
}

class StarPoint {
  final double x, y, radius, speed, offset;
  final Color color;
  StarPoint({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.offset,
    required this.color,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _twinkleController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late List<StarPoint> _stars;
  int _selectedIndex = 0;

  late final List<Widget> pages = [
    const HomePage(),
    const SkyViewerPage(),
    const EventsPage(),
    const DarkSkyMapPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    final rng = Random(42);
    _stars = List.generate(180, (_) {
      final baseColors = [
        Colors.white,
        const Color(0xFFB8D4FF),
        const Color(0xFFFFE8C0),
        const Color(0xFFFFCCCC),
      ];
      return StarPoint(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: rng.nextDouble() * 1.8 + 0.3,
        speed: rng.nextDouble() * 2 + 0.5,
        offset: rng.nextDouble() * pi * 2,
        color: baseColors[rng.nextInt(baseColors.length)],
      );
    });

    _twinkleController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _showLanguagePicker(BuildContext context) {
    final provider = LocaleProvider.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _LanguagePickerSheet(
        currentLanguage: provider.language,
        onSelected: (lang) {
          provider.onLanguageChanged(lang);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _twinkleController,
            builder: (_, __) => CustomPaint(
              painter:
                  StarfieldPainter(_stars, _twinkleController.value * 2 * pi),
              size: MediaQuery.of(context).size,
            ),
          ),

          Positioned(
              top: -120,
              left: -80,
              child: _nebulaBlob(320, const Color(0xFF1A3A6B), 0.45)),
          Positioned(
              top: 80,
              right: -60,
              child: _nebulaBlob(260, const Color(0xFF3B1A5E), 0.35)),
          Positioned(
              bottom: 100,
              left: 40,
              child: _nebulaBlob(200, const Color(0xFF0D3050), 0.3)),

          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context, loc)),
                  SliverToBoxAdapter(child: _buildSkyViewCard(context, loc)),
                  SliverToBoxAdapter(
                      child: _buildSectionTitle(loc.tonightEvents)),
                  SliverToBoxAdapter(child: _buildEventsList(context, loc)),
                  SliverToBoxAdapter(
                      child: _buildSectionTitle(loc.darkSkySpots)),
                  SliverToBoxAdapter(child: _buildMapPreview(context, loc)),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, loc),
    );
  }

  Widget _nebulaBlob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
            colors: [color.withOpacity(opacity), Colors.transparent]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations loc) {
    final provider = LocaleProvider.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aquila',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 11,
                  letterSpacing: 6,
                  color: const Color(0xFF7EB8F7).withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.homeGreeting,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 28,
                  height: 1.15,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _showLanguagePicker(context),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF7EB8F7).withOpacity(0.35),
                        width: 1.5),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A2F50), Color(0xFF0D1B33)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      provider.language.code,
                      style: const TextStyle(
                        color: Color(0xFF7EB8F7),
                        fontSize: 11,
                        fontFamily: 'Georgia',
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfilePage())),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF7EB8F7).withOpacity(0.4),
                          width: 1.5),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A2F50), Color(0xFF0D1B33)],
                      ),
                    ),
                    child: const Center(
                      child: Text('A',
                          style: TextStyle(
                            color: Color(0xFF7EB8F7),
                            fontSize: 17,
                            fontFamily: 'Georgia',
                            fontStyle: FontStyle.italic,
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAICard(BuildContext context, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ComingSoonPage()),
          );
        },
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF0E2040), Color(0xFF1A0D35)],
            ),
            border: Border.all(color: const Color(0xFF7EB8F7).withOpacity(0.2)),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(Icons.auto_awesome,
                    size: 120,
                    color: const Color(0xFF7EB8F7).withOpacity(0.08)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "AI SKY ANALYSIS",
                      style: TextStyle(
                        color: Color(0xFF7EB8F7),
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Point camera at the sky\nand discover what's above",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "Start scanning",
                          style: TextStyle(
                            color: const Color(0xFF7EB8F7).withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward,
                            color: Color(0xFF7EB8F7), size: 14),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSkyViewCard(BuildContext context, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ComingSoonPage())),
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
              Positioned(
                  right: -30,
                  top: -30,
                  child: _decorativeRing(140, const Color(0xFF7EB8F7), 0.07)),
              Positioned(
                  right: 10,
                  top: 10,
                  child: _decorativeRing(90, const Color(0xFF7EB8F7), 0.1)),
              Positioned(
                  right: 35,
                  top: 35,
                  child: _decorativeRing(40, const Color(0xFF7EB8F7), 0.18)),
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
                      child: Text(loc.liveSkyView,
                          style: const TextStyle(
                              color: Color(0xFF7EB8F7),
                              fontSize: 10,
                              letterSpacing: 2.5)),
                    ),
                    const SizedBox(height: 10),
                    Text(loc.pointAtSky,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                          height: 1.3,
                        )),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(loc.openArView,
                            style: const TextStyle(
                                color: Color(0xFF7EB8F7),
                                fontSize: 13,
                                letterSpacing: 0.5)),
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
                color: const Color(0xFFE8C87A)),
          ),
          const SizedBox(width: 10),
          Text(title.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEventsList(BuildContext context, AppLocalizations loc) {
    final events = [
      _EventData(
          icon: '☽',
          title: loc.eventLunarEclipse,
          subtitle: loc.eventLunarSub,
          date: 'Tonight  23:14',
          color: const Color(0xFFE8C87A)),
      _EventData(
          icon: '★',
          title: loc.eventPerseid,
          subtitle: loc.eventPerseidSub,
          date: 'Aug 12  22:00',
          color: const Color(0xFF7EB8F7)),
      _EventData(
          icon: '♃',
          title: loc.eventJupiter,
          subtitle: loc.eventJupiterSub,
          date: 'Aug 19  21:30',
          color: const Color(0xFFFFBB88)),
    ];

    return SizedBox(
      height: 136,
      child: GestureDetector(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const EventsPage())),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          scrollDirection: Axis.horizontal,
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (ctx, i) => _EventCard(event: events[i]),
        ),
      ),
    );
  }

  Widget _buildMapPreview(BuildContext context, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const DarkSkyMapPage())),
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
              CustomPaint(
                painter: _MapGridPainter(),
                size: const Size(double.infinity, 150),
              ),
              Positioned(
                  left: 110,
                  top: 55,
                  child: _mapPin(const Color(0xFF7EB8F7), loc.bestSpot)),
              Positioned(
                  left: 220,
                  top: 80,
                  child: _mapPin(const Color(0xFFE8C87A), '')),
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
              Positioned(
                bottom: 16,
                right: 20,
                child: Row(
                  children: [
                    Text(loc.openFullMap,
                        style: const TextStyle(
                            color: Color(0xFF7EB8F7),
                            fontSize: 12,
                            letterSpacing: 0.5)),
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
              BoxShadow(color: color.withOpacity(0.6), blurRadius: 8)
            ],
          ),
        ),
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontSize: 9, height: 1.3)),
          ),
      ],
    );
  }



  Widget _buildBottomNav(BuildContext context, AppLocalizations loc) {
    final navItems = [
      {'icon': Icons.home_rounded, 'label': loc.navHome},
      {'icon': Icons.auto_awesome, 'label': loc.navSky},
      {'icon': Icons.event_rounded, 'label': loc.navEvents},
      {'icon': Icons.map_rounded, 'label': loc.navMap},
      {'icon': Icons.person_rounded, 'label': loc.navProfile},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xFF7EB8F7).withOpacity(0.1),
            width: 1,
          ),
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
            children: List.generate(navItems.length, (i) {
              final selected = i == _selectedIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = i;
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => pages[i]),
                  );
                },
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
                        navItems[i]['icon'] as IconData,
                        size: 22,
                        color: selected
                            ? const Color(0xFF7EB8F7)
                            : Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        navItems[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 9.5,
                          letterSpacing: 0.3,
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


class _LanguagePickerSheet extends StatelessWidget {
  final AppLanguage currentLanguage;
  final ValueChanged<AppLanguage> onSelected;

  const _LanguagePickerSheet({
    required this.currentLanguage,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(currentLanguage);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF08111F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF1A3A6B), width: 1),
          left: BorderSide(color: Color(0xFF1A3A6B), width: 1),
          right: BorderSide(color: Color(0xFF1A3A6B), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF7EB8F7).withOpacity(0.1),
                      border: Border.all(
                          color: const Color(0xFF7EB8F7).withOpacity(0.25)),
                    ),
                    child: const Center(
                      child: Text('🌐', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.chooseLanguage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Georgia',
                            fontStyle: FontStyle.italic,
                          )),
                      const SizedBox(height: 2),
                      Text(loc.selectLanguageSubtitle,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
                children: AppLanguage.values.map((lang) {
                  final isSelected = lang == currentLanguage;
                  return GestureDetector(
                    onTap: () => onSelected(lang),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: isSelected
                            ? const Color(0xFF7EB8F7).withOpacity(0.12)
                            : const Color(0xFF0A1628).withOpacity(0.7),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF7EB8F7).withOpacity(0.5)
                              : Colors.white.withOpacity(0.08),
                          width: isSelected ? 1.3 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Text(lang.flag,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(lang.nativeName,
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF7EB8F7)
                                            : Colors.white.withOpacity(0.8),
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      )),
                                  Text(lang.code,
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF7EB8F7)
                                                .withOpacity(0.6)
                                            : Colors.white.withOpacity(0.25),
                                        fontSize: 10,
                                        letterSpacing: 1,
                                      )),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFF7EB8F7), size: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventData {
  final String icon, title, subtitle, date;
  final Color color;
  const _EventData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.color,
  });
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
        border: Border.all(color: event.color.withOpacity(0.2), width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [event.color.withOpacity(0.08), const Color(0xFF0A1220)],
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: event.color.withOpacity(0.12),
                ),
                child: Text(event.date,
                    style: TextStyle(
                        color: event.color, fontSize: 9, letterSpacing: 0.3)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 3),
              Text(event.subtitle,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.45), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}


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

    final roadPaint = Paint()
      ..color = const Color(0xFF7EB8F7).withOpacity(0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.7)
        ..cubicTo(size.width * 0.3, size.height * 0.4, size.width * 0.6,
            size.height * 0.8, size.width, size.height * 0.5),
      roadPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.3)
        ..cubicTo(size.width * 0.4, size.height * 0.6, size.width * 0.7,
            size.height * 0.2, size.width, size.height * 0.4),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
