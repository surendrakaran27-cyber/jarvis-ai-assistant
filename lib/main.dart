import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const JarvisApp());

class JarvisApp extends StatefulWidget {
  const JarvisApp({super.key});

  @override
  State<JarvisApp> createState() => _JarvisAppState();
}

class _JarvisAppState extends State<JarvisApp> {
  bool _isDarkMode = true;

  void toggleTheme(bool val) {
    setState(() => _isDarkMode = val);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JARVIS OS',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      home: JarvisHomeScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: toggleTheme,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF07090E),
      primaryColor: const Color(0xFFFFB300),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFFB300),
        secondary: Color(0xFF00E5FF),
        surface: Color(0xFF0E131F),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFE8ECF2),
      primaryColor: const Color(0xFFFF8F00),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFF8F00),
        secondary: Color(0xFF0091EA),
        surface: Color(0xFFFFFFFF),
      ),
    );
  }
}

class JarvisHomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const JarvisHomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<JarvisHomeScreen> createState() => _JarvisHomeScreenState();
}

class _JarvisHomeScreenState extends State<JarvisHomeScreen>
    with TickerProviderStateMixin {
  int _currentNavIndex = 0;
  late AnimationController _idleAnimController;
  late AnimationController _pulseAnimController;

  final FlutterTts _tts = FlutterTts();
  final List<Map<String, String>> _logs = [];
  final TextEditingController _commandInputController = TextEditingController();

  double _rotX = 0.0;
  double _rotY = 0.0;
  double _scale = 1.0;

  String _activeHologramShape = "ORB";
  bool _isSpeaking = false;
  String _statusText = "SYSTEM STANDBY";
  String _lastVoiceSubtitle = "Tap the reactor or enter a command...";

  @override
  void initState() {
    super.initState();

    _idleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _pulseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _initTtsEngine();
    _addLog("SYSTEM_BOOT", "JARVIS Core protocol initialized successfully.");
  }

  @override
  void dispose() {
    _idleAnimController.dispose();
    _pulseAnimController.dispose();
    _tts.stop();
    _commandInputController.dispose();
    super.dispose();
  }

  Future<void> _initTtsEngine() async {
    await _tts.setLanguage("hi-IN");
    await _tts.setPitch(0.75);
    await _tts.setSpeechRate(0.9);

    _tts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
        _statusText = "JARVIS TRANSMITTING";
      });
    });

    _tts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _statusText = "SYSTEM ONLINE";
      });
    });
  }

  Future<void> _speakResponse(String text) async {
    setState(() => _lastVoiceSubtitle = text);
    _addLog("JARVIS_VOICE", text);
    await _tts.speak(text);
  }

  void _addLog(String type, String message) {
    setState(() {
      _logs.insert(0, {
        "time":
            "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}",
        "type": type,
        "msg": message,
      });
    });
  }

  void _handleCommand(String cmd) {
    if (cmd.trim().isEmpty) return;
    _commandInputController.clear();
    _addLog("USER_INPUT", cmd);

    final lower = cmd.toLowerCase();

    if (lower.contains("cube") || lower.contains("dabba") || lower.contains("box")) {
      setState(() => _activeHologramShape = "CUBE");
      _speakResponse("Hologram converted to 3D Cube Wireframe architecture, sir.");
    } else if (lower.contains("pyramid") || lower.contains("cone")) {
      setState(() => _activeHologramShape = "PYRAMID");
      _speakResponse("Reconfiguring holographic projection to Pyramid matrix.");
    } else if (lower.contains("cylinder") || lower.contains("reactor")) {
      setState(() => _activeHologramShape = "CYLINDER");
      _speakResponse("Rendering Arc Reactor core cylinder.");
    } else if (lower.contains("orb") ||
        lower.contains("sphere") ||
        lower.contains("circle") ||
        lower.contains("reset")) {
      setState(() => _activeHologramShape = "ORB");
      _speakResponse("Primary AI Sphere matrix restored.");
    } else {
      _speakResponse("Command analyzed. Hologram synchronized for: $cmd");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildFuturisticTopBar(isDark),
            Expanded(
              child: IndexedStack(
                index: _currentNavIndex,
                children: [
                  _buildHologramWorkspace(isDark),
                  _buildSciFiLogsHUD(isDark),
                  _buildSciFiSettingsHUD(isDark),
                ],
              ),
            ),
            _buildFuturisticNavBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildFuturisticTopBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E131F).withOpacity(0.7) : Colors.white.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFFFFB300).withOpacity(0.3) : Colors.black12,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isSpeaking ? const Color(0xFF00E5FF) : const Color(0xFFFFB300),
                  boxShadow: [
                    BoxShadow(
                      color: _isSpeaking ? const Color(0xFF00E5FF) : const Color(0xFFFFB300),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.8,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          Text(
            "MODEL: $_activeHologramShape",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Color(0xFFFFB300),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHologramWorkspace(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            _lastVoiceSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF007799),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _rotY += details.delta.dx * 0.01;
                _rotX -= details.delta.dy * 0.01;
              });
            },
            onDoubleTap: () {
              setState(() {
                _rotX = 0;
                _rotY = 0;
                _scale = 1.0;
              });
            },
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_idleAnimController, _pulseAnimController]),
                builder: (context, child) {
                  final pulseScale = _isSpeaking
                      ? 1.0 + (_pulseAnimController.value * 0.18)
                      : 1.0 + (_pulseAnimController.value * 0.04);

                  return CustomPaint(
                    size: const Size(320, 320),
                    painter: Hologram3DPainter(
                      rotX: _rotX,
                      rotY: _rotY + (_idleAnimController.value * 2 * math.pi),
                      scale: _scale * pulseScale,
                      shapeType: _activeHologramShape,
                      glowColor: const Color(0xFFFFB300),
                      accentColor: const Color(0xFF00E5FF),
                      isSpeaking: _isSpeaking,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0E131F) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFFFFB300).withOpacity(0.3) : Colors.black12,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commandInputController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: const InputDecoration(
                    hintText: "Transform hologram: cube, pyramid, orb...",
                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  onSubmitted: _handleCommand,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: Color(0xFFFFB300)),
                onPressed: () => _handleCommand(_commandInputController.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSciFiLogsHUD(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _logs.length,
      itemBuilder: (context, idx) {
        final log = _logs[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0E131F) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: log['type'] == "USER_INPUT"
                    ? const Color(0xFF00E5FF)
                    : const Color(0xFFFFB300),
                width: 3,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    log['type']!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: log['type'] == "USER_INPUT"
                          ? const Color(0xFF00E5FF)
                          : const Color(0xFFFFB300),
                    ),
                  ),
                  Text(
                    log['time']!,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                log['msg']!,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSciFiSettingsHUD(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0E131F) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Cyber Dark Interface", style: TextStyle(fontWeight: FontWeight.w600)),
              Switch(
                value: widget.isDarkMode,
                activeColor: const Color(0xFFFFB300),
                onChanged: widget.onThemeChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0E131F) : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Voice Engine Pitch: 0.75 (Heavy Baritone)",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(height: 4),
              Text("Language Matrix: Hinglish / Indian English",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFuturisticNavBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E131F) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFFFFB300).withOpacity(0.2) : Colors.black12,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFFFFB300),
        unselectedItemColor: Colors.grey,
        onTap: (idx) => setState(() => _currentNavIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.hub_rounded), label: 'Hologram'),
          BottomNavigationBarItem(icon: Icon(Icons.terminal_rounded), label: 'Telemetry'),
          BottomNavigationBarItem(icon: Icon(Icons.tune_rounded), label: 'System HUD'),
        ],
      ),
    );
  }
}

class Hologram3DPainter extends CustomPainter {
  final double rotX;
  final double rotY;
  final double scale;
  final String shapeType;
  final Color glowColor;
  final Color accentColor;
  final bool isSpeaking;

  Hologram3DPainter({
    required this.rotX,
    required this.rotY,
    required this.scale,
    required this.shapeType,
    required this.glowColor,
    required this.accentColor,
    required this.isSpeaking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintLine = Paint()
      ..color = (isSpeaking ? accentColor : glowColor).withOpacity(0.65)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = isSpeaking ? accentColor : glowColor
      ..style = PaintingStyle.fill;

    List<List<double>> nodes = [];
    List<List<int>> edges = [];

    if (shapeType == "CUBE") {
      nodes = [
        [-50, -50, -50], [50, -50, -50], [50, 50, -50], [-50, 50, -50],
        [-50, -50, 50], [50, -50, 50], [50, 50, 50], [-50, 50, 50],
      ];
      edges = [
        [0, 1], [1, 2], [2, 3], [3, 0],
        [4, 5], [5, 6], [6, 7], [7, 4],
        [0, 4], [1, 5], [2, 6], [3, 7],
      ];
    } else if (shapeType == "PYRAMID") {
      nodes = [
        [0, -70, 0],
        [-60, 50, -60], [60, 50, -60],
        [60, 50, 60], [-60, 50, 60],
      ];
      edges = [
        [0, 1], [0, 2], [0, 3], [0, 4],
        [1, 2], [2, 3], [3, 4], [4, 1],
      ];
    } else {
      const int rings = 6;
      const int ptsPerRing = 12;
      const double radius = 75.0;

      for (int i = 0; i < rings; i++) {
        final phi = (math.pi / (rings + 1)) * (i + 1);
        final r = radius * math.sin(phi);
        final y = radius * math.cos(phi);

        for (int j = 0; j < ptsPerRing; j++) {
          final theta = (2 * math.pi / ptsPerRing) * j;
          final x = r * math.cos(theta);
          final z = r * math.sin(theta);
          nodes.add([x, y, z]);
        }
      }
    }

    List<Offset> projected = [];
    for (final node in nodes) {
      double x = node[0] * scale;
      double y = node[1] * scale;
      double z = node[2] * scale;

      double x1 = x * math.cos(rotY) + z * math.sin(rotY);
      double z1 = -x * math.sin(rotY) + z * math.cos(rotY);

      double y2 = y * math.cos(rotX) - z1 * math.sin(rotX);
      double z2 = y * math.sin(rotX) + z1 * math.cos(rotX);

      double fov = 280.0 / (280.0 + z2);
      projected.add(Offset(center.dx + x1 * fov, center.dy + y2 * fov));
    }

    for (final edge in edges) {
      if (edge[0] < projected.length && edge[1] < projected.length) {
        canvas.drawLine(projected[edge[0]], projected[edge[1]], paintLine);
      }
    }

    for (final p in projected) {
      canvas.drawCircle(p, 2.0, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant Hologram3DPainter oldDelegate) => true;
}
