
/*  Gyroscope/accelerometer do NOT work on Flutter Web.
    This page works fully on Android and iOS.

    All the information for the code is from opensource documentations. :)
*/

import 'dart:async';
import 'dart:math';
import 'main.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark, scaffoldBackgroundColor: Colors.black),
      home: const SkyViewerPage(),
    );
  }
}

class StarData {
  final String name;
  final String constellation;
  final double ra;
  final double dec;
  final double magnitude;
  final String spectralType;
  final double distanceLy;
  final String description;
  final Color color;

  const StarData({
    required this.name,
    required this.constellation,
    required this.ra,
    required this.dec,
    required this.magnitude,
    required this.spectralType,
    required this.distanceLy,
    required this.description,
    required this.color,
  });
}

const List<StarData> kStarCatalog = [
  StarData(
      name: 'Sirius',
      constellation: 'Canis Major',
      ra: 101.287,
      dec: -16.716,
      magnitude: -1.46,
      spectralType: 'A1V',
      distanceLy: 8.6,
      description:
          'The brightest star in the night sky. Its blue-white light comes from a star twice the size of our Sun burning at 10,000°C.',
      color: Color(0xFFCDD8FF)),
  StarData(
      name: 'Canopus',
      constellation: 'Carina',
      ra: 95.988,
      dec: -52.696,
      magnitude: -0.74,
      spectralType: 'A9II',
      distanceLy: 310,
      description:
          'The second brightest star. A supergiant 65 times the radius of the Sun, used historically for spacecraft navigation.',
      color: Color(0xFFF8F8FF)),
  StarData(
      name: 'Arcturus',
      constellation: 'Boötes',
      ra: 213.915,
      dec: 19.182,
      magnitude: -0.05,
      spectralType: 'K1.5III',
      distanceLy: 37,
      description:
          'The brightest star in the northern hemisphere. An orange giant 25 times larger than the Sun.',
      color: Color(0xFFFFCC6F)),
  StarData(
      name: 'Vega',
      constellation: 'Lyra',
      ra: 279.235,
      dec: 38.784,
      magnitude: 0.03,
      spectralType: 'A0Va',
      distanceLy: 25,
      description:
          'Anchor of the Summer Triangle. Due to Earth\'s precession, Vega will become the North Star in about 12,000 years.',
      color: Color(0xFFCDD8FF)),
  StarData(
      name: 'Capella',
      constellation: 'Auriga',
      ra: 79.172,
      dec: 45.998,
      magnitude: 0.08,
      spectralType: 'G5III',
      distanceLy: 43,
      description:
          'Actually four stars — two giant pairs orbiting each other. One of the yellowest bright stars in the winter sky.',
      color: Color(0xFFFFFF99)),
  StarData(
      name: 'Rigel',
      constellation: 'Orion',
      ra: 78.634,
      dec: -8.202,
      magnitude: 0.13,
      spectralType: 'B8Ia',
      distanceLy: 860,
      description:
          'Orion\'s left foot — a blue supergiant 78,000 times more luminous than the Sun.',
      color: Color(0xFFAABFFF)),
  StarData(
      name: 'Procyon',
      constellation: 'Canis Minor',
      ra: 114.825,
      dec: 5.225,
      magnitude: 0.34,
      spectralType: 'F5IV-V',
      distanceLy: 11.4,
      description:
          'The Little Dog Star — just 11 light-years away. Has a white dwarf companion.',
      color: Color(0xFFF8F8FF)),
  StarData(
      name: 'Betelgeuse',
      constellation: 'Orion',
      ra: 88.793,
      dec: 7.407,
      magnitude: 0.42,
      spectralType: 'M1Ia',
      distanceLy: 700,
      description:
          'One of the largest stars known. A red supergiant expected to explode as a supernova within 100,000 years.',
      color: Color(0xFFFF6633)),
  StarData(
      name: 'Altair',
      constellation: 'Aquila',
      ra: 297.696,
      dec: 8.868,
      magnitude: 0.76,
      spectralType: 'A7V',
      distanceLy: 16.7,
      description:
          'The brightest star in Aquila the Eagle. Spins so fast it completes a rotation in under 9 hours.',
      color: Color(0xFFCDD8FF)),
  StarData(
      name: 'Aldebaran',
      constellation: 'Taurus',
      ra: 68.980,
      dec: 16.509,
      magnitude: 0.86,
      spectralType: 'K5III',
      distanceLy: 65,
      description:
          'The red eye of Taurus the Bull. An orange giant 44 times the Sun\'s diameter.',
      color: Color(0xFFFFCC6F)),
  StarData(
      name: 'Antares',
      constellation: 'Scorpius',
      ra: 247.352,
      dec: -26.432,
      magnitude: 0.96,
      spectralType: 'M1.5Iab',
      distanceLy: 550,
      description:
          'The heart of the Scorpion. Its name means "rival of Mars" for its similar red color.',
      color: Color(0xFFFF6633)),
  StarData(
      name: 'Spica',
      constellation: 'Virgo',
      ra: 201.298,
      dec: -11.161,
      magnitude: 0.97,
      spectralType: 'B1III',
      distanceLy: 250,
      description:
          'A binary system of two massive blue stars so close they are egg-shaped by tidal forces.',
      color: Color(0xFF9BB0FF)),
  StarData(
      name: 'Pollux',
      constellation: 'Gemini',
      ra: 116.329,
      dec: 28.026,
      magnitude: 1.14,
      spectralType: 'K0IIIb',
      distanceLy: 34,
      description:
          'The brightest star in Gemini. Hosts a confirmed exoplanet — Pollux b.',
      color: Color(0xFFFFCC6F)),
  StarData(
      name: 'Fomalhaut',
      constellation: 'Piscis Austrinus',
      ra: 344.413,
      dec: -29.622,
      magnitude: 1.16,
      spectralType: 'A3V',
      distanceLy: 25,
      description:
          'The Loneliest Bright Star. Surrounded by a famous dust ring imaged by Hubble.',
      color: Color(0xFFCDD8FF)),
  StarData(
      name: 'Deneb',
      constellation: 'Cygnus',
      ra: 310.358,
      dec: 45.280,
      magnitude: 1.25,
      spectralType: 'A2Ia',
      distanceLy: 2600,
      description:
          'The tail of the Swan. Despite being 2600 light-years away, it\'s one of the brightest stars due to extraordinary luminosity.',
      color: Color(0xFFCDD8FF)),
  StarData(
      name: 'Regulus',
      constellation: 'Leo',
      ra: 152.093,
      dec: 11.967,
      magnitude: 1.35,
      spectralType: 'B7V',
      distanceLy: 79,
      description:
          'The heart of Leo the Lion. One of the fastest-rotating stars, completing a revolution in under 16 hours.',
      color: Color(0xFFAABFFF)),
  StarData(
      name: 'Castor',
      constellation: 'Gemini',
      ra: 113.650,
      dec: 31.889,
      magnitude: 1.58,
      spectralType: 'A1V',
      distanceLy: 52,
      description:
          'The second Gemini twin — actually a sextuple star system: three pairs of binary stars.',
      color: Color(0xFFCDD8FF)),
  StarData(
      name: 'Bellatrix',
      constellation: 'Orion',
      ra: 81.283,
      dec: 6.350,
      magnitude: 1.64,
      spectralType: 'B2III',
      distanceLy: 250,
      description:
          'Orion\'s right shoulder — the Amazon Star. A hot blue giant 6 times the mass of the Sun.',
      color: Color(0xFF9BB0FF)),
  StarData(
      name: 'Elnath',
      constellation: 'Taurus',
      ra: 81.573,
      dec: 28.608,
      magnitude: 1.65,
      spectralType: 'B7III',
      distanceLy: 131,
      description:
          'The northern tip of Taurus, marking one of the Bull\'s horns.',
      color: Color(0xFFAABFFF)),
  StarData(
      name: 'Alnilam',
      constellation: 'Orion',
      ra: 84.053,
      dec: -1.202,
      magnitude: 1.69,
      spectralType: 'B0Ia',
      distanceLy: 1340,
      description:
          'The middle star of Orion\'s Belt. A blue supergiant 375,000 times more luminous than the Sun.',
      color: Color(0xFF9BB0FF)),
  StarData(
      name: 'Alnitak',
      constellation: 'Orion',
      ra: 85.190,
      dec: -1.943,
      magnitude: 1.74,
      spectralType: 'O9.5Ib',
      distanceLy: 800,
      description:
          'The easternmost star of Orion\'s Belt. Close to the famous Horsehead Nebula.',
      color: Color(0xFF9BB0FF)),
  StarData(
      name: 'Alioth',
      constellation: 'Ursa Major',
      ra: 193.507,
      dec: 55.960,
      magnitude: 1.76,
      spectralType: 'A0p',
      distanceLy: 81,
      description:
          'The brightest star in Ursa Major — the Big Dipper\'s handle star closest to the bowl.',
      color: Color(0xFFCDD8FF)),
  StarData(
      name: 'Dubhe',
      constellation: 'Ursa Major',
      ra: 165.932,
      dec: 61.751,
      magnitude: 1.79,
      spectralType: 'K0III',
      distanceLy: 124,
      description:
          'The outermost pointer star of the Big Dipper, pointing toward Polaris.',
      color: Color(0xFFFFCC6F)),
  StarData(
      name: 'Mirfak',
      constellation: 'Perseus',
      ra: 51.081,
      dec: 49.861,
      magnitude: 1.79,
      spectralType: 'F5Ib',
      distanceLy: 590,
      description:
          'The brightest star in Perseus. Surrounded by a moving cluster of young hot stars.',
      color: Color(0xFFF8F8FF)),
  StarData(
      name: 'Polaris',
      constellation: 'Ursa Minor',
      ra: 37.955,
      dec: 89.264,
      magnitude: 1.98,
      spectralType: 'F7Ib',
      distanceLy: 433,
      description:
          'The North Star — currently within 1° of the celestial north pole.',
      color: Color(0xFFF8F8FF)),
  StarData(
      name: 'Alphard',
      constellation: 'Hydra',
      ra: 141.897,
      dec: -8.659,
      magnitude: 1.98,
      spectralType: 'K3II',
      distanceLy: 177,
      description:
          'The Solitary One — the only bright star in the enormous constellation Hydra.',
      color: Color(0xFFFFCC6F)),
  StarData(
      name: 'Algol',
      constellation: 'Perseus',
      ra: 47.042,
      dec: 40.956,
      magnitude: 2.12,
      spectralType: 'B8V',
      distanceLy: 93,
      description:
          'The Demon Star. An eclipsing binary: every 2.87 days, a dimmer companion dims it for 10 hours.',
      color: Color(0xFFAABFFF)),
  StarData(
      name: 'Denebola',
      constellation: 'Leo',
      ra: 177.265,
      dec: 14.572,
      magnitude: 2.14,
      spectralType: 'A3V',
      distanceLy: 36,
      description:
          'The tail of Leo. Has a debris disk that may harbor a planetary system in formation.',
      color: Color(0xFFCDD8FF)),
  StarData(
      name: 'Alphecca',
      constellation: 'Corona Borealis',
      ra: 233.672,
      dec: 26.715,
      magnitude: 2.22,
      spectralType: 'A0V',
      distanceLy: 75,
      description:
          'The brightest star in the Northern Crown — a small but beautiful arc of stars.',
      color: Color(0xFFCDD8FF)),
  StarData(
      name: 'Sadr',
      constellation: 'Cygnus',
      ra: 305.557,
      dec: 40.257,
      magnitude: 2.23,
      spectralType: 'F8Ia',
      distanceLy: 1800,
      description:
          'The chest of the Swan — the center of the Northern Cross asterism.',
      color: Color(0xFFF8F8FF)),
  StarData(
      name: 'Schedar',
      constellation: 'Cassiopeia',
      ra: 10.127,
      dec: 56.537,
      magnitude: 2.24,
      spectralType: 'K0IIIa',
      distanceLy: 228,
      description: 'The brightest star in Cassiopeia\'s W shape.',
      color: Color(0xFFFFCC6F)),
  StarData(
      name: 'Navi',
      constellation: 'Cassiopeia',
      ra: 14.177,
      dec: 60.717,
      magnitude: 2.15,
      spectralType: 'B0.5IVpe',
      distanceLy: 610,
      description:
          'The middle star of Cassiopeia\'s W. Named by astronaut Gus Grissom, used as a navigation star for Apollo missions.',
      color: Color(0xFF9BB0FF)),
  StarData(
      name: 'Caph',
      constellation: 'Cassiopeia',
      ra: 2.295,
      dec: 59.150,
      magnitude: 2.28,
      spectralType: 'F2III',
      distanceLy: 54,
      description:
          'Part of Cassiopeia\'s W. A yellow-white giant that pulsates slightly in brightness.',
      color: Color(0xFFF8F8FF)),
  StarData(
      name: 'Mizar',
      constellation: 'Ursa Major',
      ra: 200.981,
      dec: 54.925,
      magnitude: 2.23,
      spectralType: 'A2V',
      distanceLy: 86,
      description:
          'The middle handle star of the Big Dipper. The first binary star discovered by telescope (1617).',
      color: Color(0xFFCDD8FF)),
  StarData(
      name: 'Rasalhague',
      constellation: 'Ophiuchus',
      ra: 263.734,
      dec: 12.560,
      magnitude: 2.07,
      spectralType: 'A5III',
      distanceLy: 47,
      description:
          'The head of Ophiuchus the Serpent Bearer. A white giant 25 times more luminous than the Sun.',
      color: Color(0xFFCDD8FF)),
  StarData(
      name: 'Alpheratz',
      constellation: 'Andromeda',
      ra: 2.097,
      dec: 29.091,
      magnitude: 2.07,
      spectralType: 'B9p',
      distanceLy: 97,
      description:
          'Shared between Andromeda and Pegasus. Forms the northeastern corner of the Great Square.',
      color: Color(0xFFAABFFF)),
  StarData(
      name: 'Mirach',
      constellation: 'Andromeda',
      ra: 17.433,
      dec: 35.621,
      magnitude: 2.05,
      spectralType: 'M0III',
      distanceLy: 197,
      description:
          'A red giant used as a guide star to find the Andromeda Galaxy — our nearest large galactic neighbor.',
      color: Color(0xFFFF6633)),
  StarData(
      name: 'Enif',
      constellation: 'Pegasus',
      ra: 326.046,
      dec: 9.875,
      magnitude: 2.38,
      spectralType: 'K2Ib',
      distanceLy: 690,
      description:
          'The nose of Pegasus the Winged Horse. In 2012, it briefly brightened by a full magnitude.',
      color: Color(0xFFFFCC6F)),
  StarData(
      name: 'Hamal',
      constellation: 'Aries',
      ra: 31.793,
      dec: 23.462,
      magnitude: 2.01,
      spectralType: 'K2III',
      distanceLy: 66,
      description:
          'The brightest star in Aries the Ram. 2000 years ago, the sun was here at the spring equinox.',
      color: Color(0xFFFFCC6F)),
  StarData(
      name: 'Nunki',
      constellation: 'Sagittarius',
      ra: 283.816,
      dec: -26.297,
      magnitude: 2.05,
      spectralType: 'B2V',
      distanceLy: 224,
      description:
          'A hot blue star in Sagittarius. The Voyager 2 spacecraft was aimed toward Nunki after its Saturn flyby.',
      color: Color(0xFFAABFFF)),
  StarData(
      name: 'Albireo',
      constellation: 'Cygnus',
      ra: 292.680,
      dec: 27.960,
      magnitude: 3.08,
      spectralType: 'K3II',
      distanceLy: 430,
      description:
          'The beak of the Swan — one of the most beautiful double stars. A telescope reveals a stunning gold and blue pair.',
      color: Color(0xFFFFCC6F)),
  StarData(
      name: 'Mira',
      constellation: 'Cetus',
      ra: 34.837,
      dec: -2.978,
      magnitude: 3.04,
      spectralType: 'M7IIIe',
      distanceLy: 299,
      description:
          'The Wonderful Star — the most famous long-period variable, cycling over 332 days.',
      color: Color(0xFFFF6633)),
  StarData(
      name: 'Algieba',
      constellation: 'Leo',
      ra: 154.993,
      dec: 19.842,
      magnitude: 2.01,
      spectralType: 'K1III',
      distanceLy: 130,
      description:
          'A beautiful double star in Leo — two orange giants orbiting each other over 500 years.',
      color: Color(0xFFFFCC6F)),
  StarData(
      name: 'Izar',
      constellation: 'Boötes',
      ra: 221.247,
      dec: 27.074,
      magnitude: 2.35,
      spectralType: 'K0II',
      distanceLy: 300,
      description:
          'A beautiful double star in Boötes — the contrast between the orange giant and blue companion is stunning.',
      color: Color(0xFFFFCC6F)),
  StarData(
      name: 'Almach',
      constellation: 'Andromeda',
      ra: 30.975,
      dec: 42.330,
      magnitude: 2.10,
      spectralType: 'K3II',
      distanceLy: 355,
      description:
          'The foot of Andromeda — a quadruple star system rivaling Albireo in color contrast.',
      color: Color(0xFFFFCC6F)),
  StarData(
      name: 'Alderamin',
      constellation: 'Cepheus',
      ra: 319.645,
      dec: 62.585,
      magnitude: 2.45,
      spectralType: 'A7IV',
      distanceLy: 49,
      description:
          'Due to precession, Alderamin will become the North Star in about 5,500 years.',
      color: Color(0xFFCDD8FF)),
  StarData(
      name: 'Kaus Australis',
      constellation: 'Sagittarius',
      ra: 276.043,
      dec: -34.384,
      magnitude: 1.85,
      spectralType: 'B9.5III',
      distanceLy: 143,
      description:
          'The brightest star in Sagittarius. Sits above the spout of the famous Teapot asterism.',
      color: Color(0xFFAABFFF)),
  StarData(
      name: 'Atria',
      constellation: 'Triangulum Australe',
      ra: 252.166,
      dec: -69.028,
      magnitude: 1.91,
      spectralType: 'K2II',
      distanceLy: 415,
      description:
          'The brightest star in the Southern Triangle. Over 5000 times more luminous than the Sun.',
      color: Color(0xFFFFCC6F)),
  StarData(
      name: 'Peacock',
      constellation: 'Pavo',
      ra: 306.412,
      dec: -56.735,
      magnitude: 1.94,
      spectralType: 'B2IV',
      distanceLy: 179,
      description:
          'The brightest star in Pavo the Peacock — one of the official navigation stars.',
      color: Color(0xFFAABFFF)),
  StarData(
      name: 'Achernar',
      constellation: 'Eridanus',
      ra: 24.429,
      dec: -57.237,
      magnitude: 0.46,
      spectralType: 'B6Vep',
      distanceLy: 139,
      description:
          'The most oblate star known — it spins so fast its equatorial diameter is 50% larger than its polar diameter.',
      color: Color(0xFFAABFFF)),
  StarData(
      name: 'Adhara',
      constellation: 'Canis Major',
      ra: 104.656,
      dec: -28.972,
      magnitude: 1.50,
      spectralType: 'B2II',
      distanceLy: 430,
      description:
          'Second brightest in Canis Major. Would be the brightest star if as close as Sirius.',
      color: Color(0xFF9BB0FF)),
];

class AstroMath {
  static double toRad(double deg) => deg * pi / 180.0;
  static double toDeg(double rad) => rad * 180.0 / pi;

  static double julianDay(DateTime dt) {
    final utc = dt.toUtc();
    int y = utc.year, m = utc.month;
    final d =
        utc.day + utc.hour / 24.0 + utc.minute / 1440.0 + utc.second / 86400.0;
    if (m <= 2) {
      y--;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5;
  }

  static double gmst(DateTime dt) {
    final jd = julianDay(dt);
    final t = (jd - 2451545.0) / 36525.0;
    double g = 280.46061837 +
        360.98564736629 * (jd - 2451545.0) +
        t * t * 0.000387933 -
        t * t * t / 38710000.0;
    return g % 360.0;
  }

  static double lst(DateTime dt, double lonDeg) => (gmst(dt) + lonDeg) % 360.0;

  static Map<String, double> raDecToAltAz(
      double raDeg, double decDeg, double latDeg, double lonDeg, DateTime dt) {
    final localST = lst(dt, lonDeg);
    double ha = (localST - raDeg) % 360.0;
    if (ha < 0) ha += 360.0;

    final haRad = toRad(ha);
    final decRad = toRad(decDeg);
    final latRad = toRad(latDeg);

    final sinAlt =
        sin(decRad) * sin(latRad) + cos(decRad) * cos(latRad) * cos(haRad);
    final alt = toDeg(asin(sinAlt.clamp(-1.0, 1.0)));

    final cosAz = (sin(decRad) - sin(toRad(alt)) * sin(latRad)) /
        (cos(toRad(alt)) * cos(latRad));
    double az = toDeg(acos(cosAz.clamp(-1.0, 1.0)));
    if (sin(haRad) > 0) az = 360.0 - az;

    return {
      'altitude': alt.isNaN ? 0.0 : alt,
      'azimuth': az.isNaN ? 0.0 : az,
    };
  }
}

class ComputedStar {
  final StarData data;
  double altitude;
  double azimuth;
  bool visible;

  ComputedStar({
    required this.data,
    required this.altitude,
    required this.azimuth,
    required this.visible,
  });
}


class SkyViewerPage extends StatefulWidget {
  const SkyViewerPage({super.key});

  @override
  State<SkyViewerPage> createState() => _SkyViewerPageState();
}

class _SkyViewerPageState extends State<SkyViewerPage>
    with TickerProviderStateMixin {
  double _azimuthDeg = 0.0;
  double _altitudeDeg = 45.0;
  double _rollDeg = 0.0;
  double _fovDeg = 60.0;

  double _smoothAz = 0.0;
  double _smoothAlt = 45.0;
  double _smoothRoll = 0.0;
  static const double _alpha = 0.15;

  List<double> _accel = [0, 0, 9.8];
  List<double> _magnet = [0, 1, 0];
  StreamSubscription? _accelSub;
  StreamSubscription? _magnetSub;

  Offset? _dragStart;
  double _dragAzStart = 0.0;
  double _dragAltStart = 45.0;

  double _lat = 44.94;
  double _lon = 26.02;
  bool _hasLocation = false;

  List<ComputedStar> _stars = [];
  Timer? _updateTimer;

  ComputedStar? _selectedStar;
  late AnimationController _infoCtrl;
  late Animation<double> _infoAnim;

  bool _showGrid = true;
  bool _showLabels = true;
  bool _nightMode = true;
  bool _showSearch = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    _infoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _infoAnim = CurvedAnimation(parent: _infoCtrl, curve: Curves.easeOutCubic);

    _initLocation();
    _startUpdateLoop();

    if (!kIsWeb) {
      _initSensors();
    }
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _magnetSub?.cancel();
    _updateTimer?.cancel();
    _infoCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }


  void _initSensors() {
    _accelSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((e) {
      _accel = [e.x, e.y, e.z];
      _updateOrientation();
    }, onError: (_) {});

    _magnetSub = magnetometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((e) {
      _magnet = [e.x, e.y, e.z];
      _updateOrientation();
    }, onError: (_) {});
  }

  void _updateOrientation() {
    final ax = _accel[0], ay = _accel[1], az = _accel[2];
    final mx = _magnet[0], my = _magnet[1], mz = _magnet[2];

    final normA = sqrt(ax * ax + ay * ay + az * az);
    if (!normA.isFinite || normA < 0.001) return;

    final rawAlt = AstroMath.toDeg(atan2(-ay, sqrt(ax * ax + az * az)));
    if (!rawAlt.isFinite) return;

    final nx = ax / normA, ny = ay / normA, nz = az / normA;
    final ex = my * nz - mz * ny;
    final ey = mz * nx - mx * nz;
    final ez = mx * ny - my * nx;
    final normE = sqrt(ex * ex + ey * ey + ez * ez);
    if (!normE.isFinite || normE < 0.001) return;

    final hx = ex / normE, hy = ey / normE;
    double rawAz = AstroMath.toDeg(atan2(-hy, hx));
    if (!rawAz.isFinite) return;
    if (rawAz < 0) rawAz += 360.0;

    final rawRoll = AstroMath.toDeg(atan2(ax, az));
    if (!rawRoll.isFinite) return;

    _smoothAz = _lerpAngle(_smoothAz, rawAz, _alpha);
    _smoothAlt = _smoothAlt + _alpha * (rawAlt - _smoothAlt);
    _smoothRoll = _smoothRoll + _alpha * (rawRoll - _smoothRoll);

    if (!_smoothAz.isFinite || !_smoothAlt.isFinite || !_smoothRoll.isFinite) {
      return;
    }

    if (mounted) {
      setState(() {
        _azimuthDeg = _smoothAz;
        _altitudeDeg = _smoothAlt;
        _rollDeg = _smoothRoll;
      });
    }
  }

  double _lerpAngle(double a, double b, double t) {
    double diff = b - a;
    while (diff > 180) {
      diff -= 360;
    }
    while (diff < -180) {
      diff += 360;
    }
    return a + diff * t;
  }


  void _onDragStart(DragStartDetails d) {
    _dragStart = d.localPosition;
    _dragAzStart = _azimuthDeg;
    _dragAltStart = _altitudeDeg;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_dragStart == null) return;
    final dx = d.localPosition.dx - _dragStart!.dx;
    final dy = d.localPosition.dy - _dragStart!.dy;
    final degPerPx = _fovDeg / MediaQuery.of(context).size.height;
    setState(() {
      _azimuthDeg = (_dragAzStart - dx * degPerPx) % 360;
      _altitudeDeg = (_dragAltStart + dy * degPerPx).clamp(-90.0, 90.0);
    });
  }


  Future<void> _initLocation() async {
    try {
      if (!kIsWeb) {
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.denied ||
            perm == LocationPermission.deniedForever) {
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);

      if (!pos.latitude.isFinite || !pos.longitude.isFinite) return;

      if (mounted) {
        setState(() {
          _lat = pos.latitude;
          _lon = pos.longitude;
          _hasLocation = true;
        });
        _computeStarPositions();
      }
    } catch (_) {
      // I used default Ploiești coordinates
    }
  }


  void _startUpdateLoop() {
    _computeStarPositions();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _computeStarPositions();
    });
  }

  void _computeStarPositions() {
    final now = DateTime.now();
    final computed = kStarCatalog.map((star) {
      final altAz = AstroMath.raDecToAltAz(star.ra, star.dec, _lat, _lon, now);
      final alt = altAz['altitude']!;
      final az = altAz['azimuth']!;
      return ComputedStar(
        data: star,
        altitude: alt,
        azimuth: az,
        visible: alt > -5 && alt.isFinite && az.isFinite,
      );
    }).toList();

    if (mounted) setState(() => _stars = computed);
  }


  Offset? _projectStar(ComputedStar star, Size size) {
    if (!star.visible) return null;

    double dAz = star.azimuth - _azimuthDeg;
    while (dAz > 180) {
      dAz -= 360;
    }
    while (dAz < -180) {
      dAz += 360;
    }
    final dAlt = star.altitude - _altitudeDeg;
    if (!dAz.isFinite || !dAlt.isFinite) return null;

    final scale = size.height / _fovDeg;
    final rollRad = AstroMath.toRad(kIsWeb ? 0 : -_rollDeg);
    final rawX = dAz * scale;
    final rawY = -dAlt * scale;
    final rx = rawX * cos(rollRad) - rawY * sin(rollRad);
    final ry = rawX * sin(rollRad) + rawY * cos(rollRad);

    final sx = size.width / 2 + rx;
    final sy = size.height / 2 + ry;
    if (!sx.isFinite || !sy.isFinite) return null;

    const margin = 80.0;
    if (sx < -margin || sx > size.width + margin) return null;
    if (sy < -margin || sy > size.height + margin) return null;

    return Offset(sx, sy);
  }


  void _onTap(TapDownDetails d, Size size) {
    final tap = d.localPosition;
    ComputedStar? nearest;
    double nearestDist = 44.0;

    for (final star in _stars) {
      final pos = _projectStar(star, size);
      if (pos == null) continue;
      final dist = (pos - tap).distance;
      if (dist < nearestDist) {
        nearestDist = dist;
        nearest = star;
      }
    }

    if (nearest != null) {
      setState(() => _selectedStar = nearest);
      _infoCtrl.forward(from: 0);
    } else {
      _dismissInfo();
    }
  }

  void _dismissInfo() {
    _infoCtrl.reverse().then((_) {
      if (mounted) setState(() => _selectedStar = null);
    });
  }


  List<ComputedStar> get _searchResults {
    if (_searchQuery.isEmpty) return [];
    return _stars
        .where((s) =>
            s.data.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.data.constellation
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .take(6)
        .toList();
  }

  void _focusStar(ComputedStar star) {
    setState(() {
      _azimuthDeg = star.azimuth;
      _altitudeDeg = star.altitude;
      _selectedStar = star;
      _showSearch = false;
      _searchQuery = '';
      _searchCtrl.clear();
    });
    _infoCtrl.forward(from: 0);
  }

  String _getCardinal(double az) {
    const dirs = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW'
    ];
    return dirs[((az / 22.5) % 16).round() % 16];
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        _nightMode ? const Color(0xFFFF4400) : const Color(0xFF7EB8F7);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (d) {
          final size = MediaQuery.of(context).size;
          _onTap(d, size);
        },
        onScaleUpdate: (d) {
          setState(() {
            _fovDeg = (_fovDeg / d.scale).clamp(20.0, 120.0);
          });
        },
        onPanStart: kIsWeb ? _onDragStart : null,
        onPanUpdate: kIsWeb ? _onDragUpdate : null,
        child: Stack(
          children: [
            LayoutBuilder(builder: (ctx, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return CustomPaint(
                size: size,
                painter: _SkyPainter(
                  stars: _stars,
                  projectStar: (s) => _projectStar(s, size),
                  selectedStar: _selectedStar,
                  azimuthDeg: _azimuthDeg,
                  altitudeDeg: _altitudeDeg,
                  fovDeg: _fovDeg,
                  showGrid: _showGrid,
                  showLabels: _showLabels,
                  nightMode: _nightMode,
                  screenSize: size,
                ),
              );
            }),

            if (_nightMode)
              IgnorePointer(
                child: Container(color: const Color(0x22FF2200)),
              ),

            _buildTopBar(accent),

            _buildCompass(accent),

            Center(
                child: CustomPaint(
              size: const Size(60, 60),
              painter: _CrosshairPainter(accent.withOpacity(0.4)),
            )),

            _buildToolbar(accent),

            if (kIsWeb && _selectedStar == null) _buildWebHint(accent),

            if (_showSearch) _buildSearch(accent),

            if (_selectedStar != null) _buildStarInfo(accent),
          ],
        ),
      ),
    );
  }


  Widget _buildTopBar(Color accent) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                    border: Border.all(color: accent.withOpacity(0.3)),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: accent, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SKY VIEWER',
                      style: TextStyle(
                          color: accent, fontSize: 9, letterSpacing: 3.5)),
                  Text(
                    '${_azimuthDeg.toStringAsFixed(0)}°  ·  '
                    '${_altitudeDeg.toStringAsFixed(0)}° alt  ·  '
                    '${_fovDeg.toStringAsFixed(0)}° fov',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showSearch = !_showSearch),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                    border: Border.all(color: accent.withOpacity(0.3)),
                  ),
                  child: Icon(Icons.search_rounded, color: accent, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCompass(Color accent) {
    return Positioned(
      bottom: _selectedStar != null ? 300 : 110,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.navigation_rounded, color: accent, size: 14),
              const SizedBox(width: 8),
              Text(_getCardinal(_azimuthDeg),
                  style: TextStyle(
                      color: accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('  ${_azimuthDeg.toStringAsFixed(1)}°',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildToolbar(Color accent) {
    return Positioned(
      right: 16,
      top: 0,
      bottom: 0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _toolBtn(Icons.grid_3x3_rounded, _showGrid, accent,
                () => setState(() => _showGrid = !_showGrid)),
            const SizedBox(height: 10),
            _toolBtn(Icons.label_rounded, _showLabels, accent,
                () => setState(() => _showLabels = !_showLabels)),
            const SizedBox(height: 10),
            _toolBtn(Icons.remove_red_eye_rounded, _nightMode, accent,
                () => setState(() => _nightMode = !_nightMode)),
            const SizedBox(height: 10),
            _iconBtn(Icons.add_rounded, accent,
                () => setState(() => _fovDeg = (_fovDeg - 10).clamp(20, 120))),
            const SizedBox(height: 6),
            _iconBtn(Icons.remove_rounded, accent,
                () => setState(() => _fovDeg = (_fovDeg + 10).clamp(20, 120))),
          ],
        ),
      ),
    );
  }

  Widget _toolBtn(
      IconData icon, bool active, Color accent, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              active ? accent.withOpacity(0.2) : Colors.black.withOpacity(0.5),
          border: Border.all(
            color: active
                ? accent.withOpacity(0.6)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(icon,
            color: active ? accent : Colors.white.withOpacity(0.3), size: 18),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color accent, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.5),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.5), size: 18),
      ),
    );
  }

  Widget _buildWebHint(Color accent) {
    return Positioned(
      bottom: 130,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.drag_indicator_rounded,
                  color: accent.withOpacity(0.7), size: 14),
              const SizedBox(width: 8),
              Text(
                'Drag to look around  ·  Pinch to zoom  ·  Tap a star',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.45), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSearch(Color accent) {
    final results = _searchResults;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 70, 60, 0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search_rounded,
                        color: accent.withOpacity(0.6), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        cursorColor: accent,
                        decoration: InputDecoration(
                          hintText: 'Search star or constellation…',
                          hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.25),
                              fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _showSearch = false;
                        _searchQuery = '';
                        _searchCtrl.clear();
                      }),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.close_rounded,
                            color: Colors.white.withOpacity(0.3), size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              if (results.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: results.map((star) {
                      final isVis = star.visible && star.altitude > 0;
                      return GestureDetector(
                        onTap: () => _focusStar(star),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: star.data.color,
                                  boxShadow: [
                                    BoxShadow(
                                        color: star.data.color.withOpacity(0.6),
                                        blurRadius: 4)
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(star.data.name,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 13)),
                                    Text(star.data.constellation,
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.4),
                                            fontSize: 10)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: isVis
                                      ? accent.withOpacity(0.15)
                                      : Colors.white.withOpacity(0.05),
                                ),
                                child: Text(
                                  isVis
                                      ? '${star.altitude.toStringAsFixed(0)}° alt'
                                      : 'Below horizon',
                                  style: TextStyle(
                                      color: isVis
                                          ? accent
                                          : Colors.white.withOpacity(0.2),
                                      fontSize: 9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildStarInfo(Color accent) {
    final star = _selectedStar!;
    final chipColor = _nightMode ? accent : star.data.color;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _infoAnim,
        builder: (_, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(_infoAnim),
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF060D1A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: chipColor.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                  color: chipColor.withOpacity(0.08),
                  blurRadius: 30,
                  spreadRadius: 5),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: star.data.color.withOpacity(0.1),
                            border: Border.all(
                                color: star.data.color.withOpacity(0.3)),
                            boxShadow: [
                              BoxShadow(
                                  color: star.data.color.withOpacity(0.3),
                                  blurRadius: 16)
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: star.data.color,
                                boxShadow: [
                                  BoxShadow(
                                      color: star.data.color.withOpacity(0.8),
                                      blurRadius: 8)
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(star.data.constellation.toUpperCase(),
                                  style: TextStyle(
                                      color: chipColor.withOpacity(0.6),
                                      fontSize: 9,
                                      letterSpacing: 2.5)),
                              const SizedBox(height: 3),
                              Text(star.data.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontFamily: 'Georgia',
                                      fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _dismissInfo,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                            child: Icon(Icons.close_rounded,
                                color: Colors.white.withOpacity(0.35),
                                size: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _chip(
                              'Magnitude',
                              star.data.magnitude.toStringAsFixed(2),
                              chipColor),
                          const SizedBox(width: 8),
                          _chip(
                              'Distance',
                              '${star.data.distanceLy.toStringAsFixed(0)} ly',
                              chipColor),
                          const SizedBox(width: 8),
                          _chip(
                              'Altitude',
                              '${star.altitude.toStringAsFixed(1)}°',
                              chipColor),
                          const SizedBox(width: 8),
                          _chip('Azimuth',
                              '${star.azimuth.toStringAsFixed(1)}°', chipColor),
                          const SizedBox(width: 8),
                          _chip('Type', star.data.spectralType, chipColor),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(star.data.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                          height: 1.65,
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                        )),
                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: chipColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: chipColor.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              color: chipColor.withOpacity(0.6), size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'The light you\'re seeing left '
                              '${star.data.name} '
                              '${star.data.distanceLy.toStringAsFixed(0)} years ago.',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 11.5,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
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

  Widget _chip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 1),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 9,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}


class _SkyPainter extends CustomPainter {
  final List<ComputedStar> stars;
  final Offset? Function(ComputedStar) projectStar;
  final ComputedStar? selectedStar;
  final double azimuthDeg, altitudeDeg, fovDeg;
  final bool showGrid, showLabels, nightMode;
  final Size screenSize;

  _SkyPainter({
    required this.stars,
    required this.projectStar,
    required this.selectedStar,
    required this.azimuthDeg,
    required this.altitudeDeg,
    required this.fovDeg,
    required this.showGrid,
    required this.showLabels,
    required this.nightMode,
    required this.screenSize,
  });

  Color get _grid =>
      nightMode ? const Color(0x22FF2200) : const Color(0x22FFFFFF);
  Color get _labelCol =>
      nightMode ? const Color(0x88FF4400) : const Color(0x88FFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: nightMode
              ? [const Color(0xFF0A0500), const Color(0xFF050200)]
              : [const Color(0xFF020D1A), const Color(0xFF000508)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    if (showGrid) _drawGrid(canvas, size);
    _drawStars(canvas, size);
    _drawHorizon(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _grid
      ..strokeWidth = 0.5;
    final scale = size.height / fovDeg;

    for (int alt = -80; alt <= 90; alt += 10) {
      final y = size.height / 2 - (alt - altitudeDeg) * scale;
      if (y < 0 || y > size.height) continue;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
      if (alt % 30 == 0) {
        _text(canvas, '$alt°', Offset(4, y - 10), _labelCol, 9);
      }
    }
    for (int az = 0; az < 360; az += 10) {
      double dAz = az - azimuthDeg;
      while (dAz > 180) {
        dAz -= 360;
      }
      while (dAz < -180) {
        dAz += 360;
      }
      final x = size.width / 2 + dAz * scale;
      if (x < 0 || x > size.width) continue;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
      if (az % 90 == 0) {
        const labels = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
        _text(canvas, labels[az]!, Offset(x - 5, size.height - 24),
            _labelCol.withOpacity(0.9), 11);
      }
    }
  }

  void _drawStars(Canvas canvas, Size size) {
    final sorted = [...stars]
      ..sort((a, b) => b.data.magnitude.compareTo(a.data.magnitude));

    for (final star in sorted) {
      final pos = projectStar(star);
      if (pos == null) continue;
      if (!pos.dx.isFinite || !pos.dy.isFinite) continue;

      final isSelected = selectedStar?.data.name == star.data.name;
      final mag = star.data.magnitude;
      double r = (4.5 - mag * 0.7).clamp(1.0, 7.0);

      if (mag < 2.0 || isSelected) {
        canvas.drawCircle(
          pos,
          r * (isSelected ? 4 : 3),
          Paint()
            ..color = star.data.color.withOpacity(isSelected ? 0.4 : 0.12)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 2),
        );
      }

      if (isSelected) {
        canvas.drawCircle(
          pos,
          r * 3 + 4,
          Paint()
            ..color = star.data.color.withOpacity(0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
        _drawBrackets(canvas, pos, r * 3 + 10, star.data.color);
      }

      canvas.drawCircle(
        pos,
        r,
        Paint()
          ..color = nightMode
              ? Color.lerp(star.data.color, const Color(0xFFFF6633), 0.6)!
              : star.data.color,
      );

      if (mag < 1.5) _drawSpikes(canvas, pos, r, star.data.color);

      if (showLabels && mag < 2.5) {
        _text(
            canvas,
            star.data.name,
            Offset(pos.dx + r + 4, pos.dy - 6),
            nightMode
                ? const Color(0xFFFF4400).withOpacity(0.6)
                : star.data.color.withOpacity(0.7),
            9.5);
      }
    }
  }

  void _drawSpikes(Canvas canvas, Offset pos, double r, Color color) {
    final p = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final a = i * pi / 2;
      canvas.drawLine(
        Offset(pos.dx + cos(a) * r * 1.5, pos.dy + sin(a) * r * 1.5),
        Offset(pos.dx + cos(a) * r * 4.5, pos.dy + sin(a) * r * 4.5),
        p,
      );
    }
  }

  void _drawBrackets(Canvas canvas, Offset pos, double r, Color color) {
    final p = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const len = 10.0;
    for (int i = 0; i < 4; i++) {
      final sx = i < 2 ? -1.0 : 1.0;
      final sy = i % 2 == 0 ? -1.0 : 1.0;
      final cx = pos.dx + sx * r;
      final cy = pos.dy + sy * r;
      canvas.drawLine(Offset(cx, cy), Offset(cx + sx * len, cy), p);
      canvas.drawLine(Offset(cx, cy), Offset(cx, cy + sy * len), p);
    }
  }

  void _drawHorizon(Canvas canvas, Size size) {
    final scale = size.height / fovDeg;
    final hy = size.height / 2 + altitudeDeg * scale;
    if (!hy.isFinite) return;

    if (hy >= 0 && hy <= size.height) {
      canvas.drawRect(
        Rect.fromLTRB(0, hy, size.width, size.height),
        Paint()
          ..color = nightMode
              ? const Color(0xFF0A0300).withOpacity(0.85)
              : const Color(0xFF020D10).withOpacity(0.85),
      );
      canvas.drawLine(
        Offset(0, hy),
        Offset(size.width, hy),
        Paint()
          ..color =
              nightMode ? const Color(0x66FF4400) : const Color(0x446688AA)
          ..strokeWidth = 1.5,
      );
      _text(canvas, '— HORIZON —', Offset(size.width / 2 - 40, hy + 4),
          nightMode ? const Color(0x55FF4400) : const Color(0x556688AA), 9);
    }
  }

  void _text(Canvas canvas, String text, Offset pos, Color color, double size) {
    final tp = TextPainter(
      text:
          TextSpan(text: text, style: TextStyle(color: color, fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(_SkyPainter old) =>
      old.azimuthDeg != azimuthDeg ||
      old.altitudeDeg != altitudeDeg ||
      old.selectedStar != selectedStar ||
      old.showGrid != showGrid ||
      old.showLabels != showLabels ||
      old.nightMode != nightMode;
}


class _CrosshairPainter extends CustomPainter {
  final Color color;
  _CrosshairPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.0;
    final cx = size.width / 2, cy = size.height / 2;
    const gap = 8.0, arm = 16.0;
    canvas.drawLine(Offset(cx - arm - gap, cy), Offset(cx - gap, cy), p);
    canvas.drawLine(Offset(cx + gap, cy), Offset(cx + arm + gap, cy), p);
    canvas.drawLine(Offset(cx, cy - arm - gap), Offset(cx, cy - gap), p);
    canvas.drawLine(Offset(cx, cy + gap), Offset(cx, cy + arm + gap), p);
    canvas.drawCircle(
        Offset(cx, cy),
        gap * 0.8,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8);
  }

  @override
  bool shouldRepaint(_CrosshairPainter old) => old.color != color;
}
