import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeditationSession {
  final String name;
  final int durationSeconds;
  final String musicAsset;
  MeditationSession({
    required this.name,
    required this.durationSeconds,
    required this.musicAsset,
  });
}

class BreathingPattern {
  final String name;
  final String description;
  final List<BreathPhase> phases;

  BreathingPattern({
    required this.name,
    required this.description,
    required this.phases,
  });
}

class BreathPhase {
  final String name;
  final int durationSeconds;

  BreathPhase({
    required this.name,
    required this.durationSeconds,
  });
}

class MeditationStats {
  int totalMinutes;
  int sessionCount;
  int streak;
  DateTime lastSessionDate;
  MeditationStats({
    required this.totalMinutes,
    required this.sessionCount,
    required this.streak,
    required this.lastSessionDate,
  });
}

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _GradientProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  _GradientProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle (light neutral)
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc with gradient
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        colors: gradientColors,
        startAngle: -pi / 2,
        endAngle: -pi / 2 + (2 * pi * progress),
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MeditationPageState extends State<MeditationPage> with SingleTickerProviderStateMixin {
   final List<MeditationSession> sessions = [
    MeditationSession(
        name: "Quick Calm (5 min)",
        durationSeconds: 300,
        musicAsset: "assets/audio/breath_5.mp3"),
    MeditationSession(
        name: "Deep Focus (10 min)",
        durationSeconds: 600,
        musicAsset: "assets/audio/breath_10.mp3"),
    MeditationSession(
        name: "Stress Relief (15 min)",
        durationSeconds: 900,
        musicAsset: "assets/audio/breath_15.mp3"),
    MeditationSession(
        name: "Extended Peace (60 min)",
        durationSeconds: 3600,
        musicAsset: "assets/audio/breath_60.mp3"),
  ];

  final List<BreathingPattern> breathingPatterns = [
    BreathingPattern(
      name: "Box Breathing",
      description:
          "Inhale: 4s, Hold: 4s, Exhale: 4s, Hold: 4s\nGood for focus, stress control, and calming the nervous system.",
      phases: [
        BreathPhase(name: "Inhale", durationSeconds: 4),
        BreathPhase(name: "Hold", durationSeconds: 4),
        BreathPhase(name: "Exhale", durationSeconds: 4),
        BreathPhase(name: "Hold", durationSeconds: 4),
      ],
    ),
    BreathingPattern(
      name: "Equal Breathing",
      description:
          "Inhale: 4-5s, Exhale: 4-5s\nSmooth, continuous rhythm. Works well for general meditation.",
      phases: [
        BreathPhase(name: "Inhale", durationSeconds: 4),
        BreathPhase(name: "Exhale", durationSeconds: 4),
      ],
    ),
    BreathingPattern(
      name: "Extended Exhale",
      description:
          "Inhale: 4s, Exhale: 6-8s\nHelps reduce anxiety and heart rate.",
      phases: [
        BreathPhase(name: "Inhale", durationSeconds: 4),
        BreathPhase(name: "Exhale", durationSeconds: 6),
      ],
    ),
    BreathingPattern(
      name: "4-7-8 Breathing",
      description:
          "Inhale: 4s, Hold: 7s, Exhale: 8s\nDeep relaxation, usually done for 4-6 rounds.",
      phases: [
        BreathPhase(name: "Inhale", durationSeconds: 4),
        BreathPhase(name: "Hold", durationSeconds: 7),
        BreathPhase(name: "Exhale", durationSeconds: 8),
      ],
    ),
  ];

  MeditationSession? selectedSession;
  BreathingPattern? selectedBreathingPattern;
  bool sessionStarted = false;
  bool sessionReady =
      false; // New state for when session is ready but not started
  bool patternSelectionMode = false;
  int remainingSeconds = 0;
  int currentPhaseIndex = 0;
  int phaseCounter = 0; // Changed from phaseSecondsRemaining to phaseCounter
  String breathPhase = "Inhale";
  String countdownText = "";
  late AudioPlayer audioPlayer;
  Timer? timer;

  // Update color to match the screenshot - a soft pink
  // Light palette (pastel pink → purple)
  final Color appThemeColor = const Color(0xFFFEC5E5); // soft pink
  final Color appThemeColorAccent = const Color(0xFFFF6F91); // medium rose / coral
  final Color appThemePurple = const Color(0xFF9A57E5); // lavender purple
  // Page background (soft peachy pink gradient base)
  final Color backgroundPink = const Color(0xFFFFD6E0);

  // Meditation stats & offline history
  MeditationStats stats = MeditationStats(totalMinutes: 0, sessionCount: 0, streak: 0, lastSessionDate: DateTime.now().subtract(Duration(days: 2)));
  late Box box;
  String userId = '';

  // history map (date -> minutes) and today's minutes
  Map<String,int> history = {};
  int todayMinutes = 0;
  int dailyGoal = 60;

  // Motivational text rotation
  final List<String> motivations = [
    "Take a deep breath — today is a good day to be calm.",
    "You're just minutes away from today's goal.",
    "Small steps every day lead to big change.",
    "Breathe in peace, breathe out stress.",
  ];
  int _motivationIndex = 0;
  Timer? _motivationTimer;

  // Flame animation for streak
  late AnimationController _flameController;
  late Animation<double> _flameAnim;

  bool trackerExpanded = true;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    patternSelectionMode = false;
    sessionReady = false; // Initialize sessionReady to false

    // init flame animation and motivation rotation
    _flameController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _flameAnim = Tween<double>(begin: 0.9, end: 1.12).animate(CurvedAnimation(parent: _flameController, curve: Curves.easeInOut));
    _flameController.repeat(reverse: true);

    _motivationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() => _motivationIndex = (_motivationIndex + 1) % motivations.length);
    });

    _initStats();
  }

  @override
  void dispose() {
    timer?.cancel();
    audioPlayer.stop();
    audioPlayer.dispose();
    _motivationTimer?.cancel();
    _flameController.dispose();
    super.dispose();
  }

  // Initialize stats and history from Hive and Firebase (merge)
  Future<void> _initStats() async {
    box = await Hive.openBox('meditationStats');
    User? user = FirebaseAuth.instance.currentUser;
    userId = user?.uid ?? '';

    // load local history and stats
    history = Map<String,int>.from(box.get('history', defaultValue: {}));
    String todayKey = DateTime.now().toIso8601String().split('T')[0];
    todayMinutes = history[todayKey] ?? 0;

    if (box.get('stats') != null) {
      var s = box.get('stats');
      stats = MeditationStats(
        totalMinutes: s['totalMinutes'],
        sessionCount: s['sessionCount'],
        streak: s['streak'],
        lastSessionDate: DateTime.parse(s['lastSessionDate']),
      );
    }

    if (userId.isNotEmpty) {
      var doc = await FirebaseFirestore.instance.collection('MeditationStats').doc(userId).get();
      if (doc.exists) {
        var d = doc.data()!;
        stats = MeditationStats(
          totalMinutes: d['totalMinutes'] ?? stats.totalMinutes,
          sessionCount: d['sessionCount'] ?? stats.sessionCount,
          streak: d['streak'] ?? stats.streak,
          lastSessionDate: (d['lastSessionDate'] as Timestamp).toDate(),
        );
        if (d['history'] != null && d['history'] is Map) {
          Map<String, dynamic> remoteHistory = Map<String, dynamic>.from(d['history']);
          remoteHistory.forEach((k,v) { history[k] = (history[k] ?? 0) + (v as int); });
          await box.put('history', history);
          todayMinutes = history[todayKey] ?? 0;
        }
        await box.put('stats', {
          'totalMinutes': stats.totalMinutes,
          'sessionCount': stats.sessionCount,
          'streak': stats.streak,
          'lastSessionDate': stats.lastSessionDate.toIso8601String(),
        });
      }
    }

    if (mounted) setState(() {});
  }

  // Update stats after a completed session
  Future<void> _updateStats(int minutes) async {
    DateTime today = DateTime.now();
    String todayKey = today.toIso8601String().split('T')[0];

    bool isStreak = stats.lastSessionDate.difference(today).inDays == -1;
    stats.totalMinutes += minutes;
    stats.sessionCount += 1;
    stats.streak = isStreak ? stats.streak + 1 : 1;
    stats.lastSessionDate = today;

    history[todayKey] = (history[todayKey] ?? 0) + minutes;
    todayMinutes = history[todayKey]!;

    await box.put('stats', {
      'totalMinutes': stats.totalMinutes,
      'sessionCount': stats.sessionCount,
      'streak': stats.streak,
      'lastSessionDate': stats.lastSessionDate.toIso8601String(),
    });
    await box.put('history', history);

    if (userId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('MeditationStats').doc(userId).set({
        'totalMinutes': stats.totalMinutes,
        'sessionCount': stats.sessionCount,
        'streak': stats.streak,
        'lastSessionDate': Timestamp.fromDate(stats.lastSessionDate),
        'history': history,
      }, SetOptions(merge: true));
    }

    if (mounted) setState(() {});
  }

  // Updated startSession method - now actually starts the breathing
  void startSession() async {
    if (!mounted || !sessionReady) return;

    setState(() {
      countdownText = "Prepare to breathe";
      sessionStarted = true; // Mark session as started immediately
    });

    try {
      await audioPlayer.play(AssetSource(selectedSession!.musicAsset));
    } catch (e) {
      print("Error playing audio: $e");
      // Continue without audio if there's an error
    }

    // Initial preparation countdown
    for (int i = 3; i > 0; i--) {
      if (!mounted || !sessionStarted) break;
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && sessionStarted) {
        setState(() {
          countdownText = "Starting in $i...";
        });
      }
    }

    // Wait one more second after countdown
    if (mounted && sessionStarted) {
      await Future.delayed(const Duration(seconds: 1));
    }

    // Initialize first phase - START WITH COUNTER AT 1
    if (mounted && sessionStarted) {
      setState(() {
        phaseCounter = 1;
        countdownText = "1";
        breathPhase = selectedBreathingPattern!.phases[0].name;
        currentPhaseIndex = 0;
      });

      // Start the breathing cycles timer
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || !sessionStarted) {
          // Check sessionStarted, not sessionReady
          timer.cancel();
          return;
        }

        setState(() {
          remainingSeconds--;

          // End session if time is up
          if (remainingSeconds <= 0) {
            timer.cancel();
            sessionReady = false;
            sessionStarted = false;
            audioPlayer.stop();
            countdownText = "Session Complete";
            breathPhase = "Session Complete";
            // Update stats
            _updateStats(selectedSession!.durationSeconds ~/ 60);
            return;
          }

          // Check if current phase is complete
          if (phaseCounter >=
              selectedBreathingPattern!
                  .phases[currentPhaseIndex].durationSeconds) {
            // Move to next phase
            currentPhaseIndex = (currentPhaseIndex + 1) %
                selectedBreathingPattern!.phases.length;
            breathPhase =
                selectedBreathingPattern!.phases[currentPhaseIndex].name;
            phaseCounter = 1; // Reset counter to 1 for new phase
            countdownText = "1"; // Update display immediately
          } else {
            // Continue current phase, increment counter
            phaseCounter++;
            countdownText = phaseCounter.toString(); // Update display
          }
        });
      });
    }
  }

  // New method to set up the session (called after choosing breathing pattern)
  void setupSession() {
    print('setupSession called: selectedSession=$selectedSession, selectedBreathingPattern=$selectedBreathingPattern');
    if (selectedSession == null || selectedBreathingPattern == null) {
      setState(() {
        patternSelectionMode = true;
      });
      return;
    }

    setState(() {
      sessionReady = true;
      sessionStarted = false;
      remainingSeconds = selectedSession!.durationSeconds;
      currentPhaseIndex = 0;
      phaseCounter = 0;
      breathPhase = selectedBreathingPattern!.phases[0].name;
      countdownText = "";
    });
  }

  String getAnimationForSession() {
    if (selectedSession == null) {
      return "assets/animation/session_5.json";
    }

    int duration = selectedSession!.durationSeconds;
    if (duration <= 300) {
      return "assets/animation/session_5.json";
    } else if (duration <= 600) {
      return "assets/animation/session_10.json";
    } else if (duration <= 900) {
      return "assets/animation/session_15.json";
    } else {
      return "assets/animation/session_60.json";
    }
  }

  // Helper to build a polished stat tile
  Widget _statTile(ThemeProvider themeProvider, String label, String value, IconData icon) {
    final bool dark = themeProvider.isDarkMode;
    final Color iconBg = dark ? AppColors.accentPurple : Colors.white.withOpacity(0.18);
    final Color textColor = dark ? AppColors.darkText : Colors.white;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: dark ? Colors.white : AppColors.hotPink, size: 22),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                color: textColor.withOpacity(0.9),
                fontSize: 12,
              )),
        ],
      ),
    );
  }

  Widget _verticalDivider(ThemeProvider themeProvider) {
    return Container(
      width: 1,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: themeProvider.isDarkMode ? Colors.white24 : Colors.white24,
    );
  }

  // UI helpers: progress ring, heatmap, daily goal bar, motivational text, animated flame
  Widget _progressRing(String label, String value, double percent, IconData icon, ThemeProvider themeProvider) {
    final bool dark = themeProvider.isDarkMode;
    final double size = 100;
    final double stroke = 12;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Soft background ring with very light pink tint
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: stroke,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFDF2F8).withOpacity(0.6)),
              ),
            ),
            
            // Progress ring with very soft gradient
            SizedBox(
              width: size,
              height: size,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return SweepGradient(
                    colors: [
                      Color(0xFFFDBBD3), // very soft pink
                      Color(0xFFFC9BB5), // soft coral pink  
                      Color(0xFFE8A7E8), // soft lavender
                      Color(0xFFD4A7F4), // soft purple
                    ],
                    startAngle: -pi / 2,
                    endAngle: -pi / 2 + (2 * pi),
                    stops: [0.0, 0.3, 0.7, 1.0],
                  ).createShader(rect);
                },
                child: CircularProgressIndicator(
                  value: percent.clamp(0.0, 1.0),
                  strokeWidth: stroke,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),

            // Inner circle with soft gradient fill
            Container(
              width: size - stroke * 1.8,
              height: size - stroke * 1.8,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFDF2F8).withOpacity(0.95),
                    Color(0xFFFBE7F3).withOpacity(0.85),
                  ],
                  center: Alignment.center,
                  radius: 0.7,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 4)),
                  BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 0, spreadRadius: -1),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Icon(icon, color: Color(0xFFD4A7F4), size: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(value, style: TextStyle(color: Color(0xFF8B5A9F), fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(label, style: TextStyle(color: dark ? AppColors.darkText : Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _dailyGoalBar(ThemeProvider themeProvider) {
    double progress = todayMinutes / dailyGoal;
    return Column(
      children: [
        Text('Today: $todayMinutes / $dailyGoal min', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: themeProvider.isDarkMode ? AppColors.darkText : Colors.black87)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 10,
            width: double.infinity,
            color: themeProvider.isDarkMode ? Colors.white12 : Colors.grey[200],
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [appThemeColorAccent, appThemePurple]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _weekHeatmap(ThemeProvider themeProvider) {
    final List<String> days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    List<Widget> columns = [];
    for (int i = 0; i < 7; i++) {
      DateTime d = DateTime.now().subtract(Duration(days: 6 - i));
      String key = d.toIso8601String().split('T')[0];
      bool filled = (history[key] ?? 0) > 0;
      columns.add(
        Expanded(
          child: Column(
            children: [
              Text(days[i], style: TextStyle(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: filled ? (themeProvider.isDarkMode ? AppColors.accentPurple : appThemeColorAccent.withOpacity(0.25)) : Colors.black12.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: columns,
    );
  }

  Widget _motivationalText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Text(
        motivations[_motivationIndex],
        key: ValueKey<int>(_motivationIndex),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _animatedFlame(ThemeProvider themeProvider) {
    return ScaleTransition(
      scale: _flameAnim,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [Color(0xFFFF8A5C), Color(0xFFFFD27F)]),
          boxShadow: [BoxShadow(color: Color(0xFFFF8A5C).withOpacity(0.28), blurRadius: 12, spreadRadius: 3)],
        ),
        child: Icon(Icons.local_fire_department, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Meditation', style: TextStyle(color: Colors.white)),
            backgroundColor: themeProvider.isDarkMode ? AppColors.mediumPurple : AppColors.hotPink,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          backgroundColor: themeProvider.isDarkMode
              ? AppColors.darkPurple
              : backgroundPink,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Button to view tracker page
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.bar_chart, color: Colors.white),
                        label: Text("View Progress Tracker", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeProvider.isDarkMode ? AppColors.mediumPurple : AppColors.hotPink,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackerPage(
                                stats: stats,
                                todayMinutes: todayMinutes,
                                dailyGoal: dailyGoal,
                                history: history,
                                isDarkMode: themeProvider.isDarkMode,
                                appThemeColorAccent: appThemeColorAccent,
                                appThemePurple: appThemePurple,
                                hotPink: AppColors.hotPink,
                                motivations: motivations,
                                motivationIndex: _motivationIndex,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Main content below tracker
                  patternSelectionMode
                      ? _buildPatternSelectionUI(themeProvider)
                      : sessionReady
                          ? _buildActiveSessionUI(themeProvider)
                          : _buildSessionSelectionUI(themeProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionSelectionUI(ThemeProvider themeProvider) {
    String sessionDescription = "";
    if (selectedSession != null) {
      if (selectedSession == sessions[0]) {
        sessionDescription = "A short reset to slow your breath and clear the mind. Perfect between tasks.";
      } else if (selectedSession == sessions[1]) {
        sessionDescription = "Enhance concentration and mental clarity with this focus-building practice.";
      } else if (selectedSession == sessions[2]) {
        sessionDescription = "Release tension and find calm with this stress-relieving session.";
      } else {
        sessionDescription = "Immerse yourself in a complete meditation experience for deep relaxation.";
      }
    }

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 18),
            Text(
              "Meditation",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Color(0xFFFDF2F8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Container(
                  height: 180,
                  width: 180,
                  child: Lottie.asset(
                    getAnimationForSession(),
                    fit: BoxFit.contain,
                    animate: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  final isSelected = selectedSession == session;
                  String tagLabel;
                  switch (index) {
                    case 0:
                      tagLabel = "Reset in 5";
                      break;
                    case 1:
                      tagLabel = "Focus booster";
                      break;
                    case 2:
                      tagLabel = "Unwind deeply";
                      break;
                    default:
                      tagLabel = "Full immersion";
                  }
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSession = session;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFFFF8AB6) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected ? Color(0xFFFF8AB6).withOpacity(0.18) : Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: isSelected ? Border.all(color: Color(0xFFFF8AB6), width: 2) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.name.split(' (')[0],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${session.durationSeconds ~/ 60} min",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected ? Colors.white.withOpacity(0.7) : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? Color(0xFFFEC5E5) : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tagLabel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            if (selectedSession != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFFDF2F8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.spa, color: Color(0xFFFF6F91), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedSession!.name.split(' (')[0],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sessionDescription,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        patternSelectionMode = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF8AB6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      "Choose Breathing Pattern",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  // Pattern selection UI remains the same
  Widget _buildPatternSelectionUI(ThemeProvider themeProvider) {
    double listHeight = MediaQuery.of(context).size.height * 0.5;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    patternSelectionMode = false;
                  });
                },
              ),
              const SizedBox(width: 8),
              const Text(
                "Choose Breathing Pattern",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: listHeight,
            child: ListView.builder(
              itemCount: breathingPatterns.length,
              itemBuilder: (context, index) {
                final pattern = breathingPatterns[index];
                final isSelected = selectedBreathingPattern == pattern;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected ? Border.all(color: Color(0xFFFF8AB6), width: 2) : Border.all(color: Colors.transparent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        selectedBreathingPattern = pattern;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pattern.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pattern.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedBreathingPattern != null
                    ? () {
                        setState(() {
                          patternSelectionMode = false;
                          setupSession();
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF8AB6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 3,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text(
                  "Begin Session",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Updated active session UI with Start button and proper phase display
  Widget _buildActiveSessionUI(ThemeProvider themeProvider) {
    if (selectedSession == null || selectedBreathingPattern == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            "Session or pattern not selected. Please go back and choose a session and pattern.",
            style: TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    // Determine if we should show the countdown message below the card
    bool showCountdownMsg = sessionStarted && (countdownText == "Prepare to breathe" || countdownText.startsWith("Starting"));
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFEC5E5), Color(0xFFD4A7F4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(48),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFD4A7F4).withOpacity(0.18),
                  blurRadius: 32,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 240,
                  width: 240,
                  child: Lottie.asset(
                    getAnimationForSession(),
                    fit: BoxFit.contain,
                    animate: true,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  breathPhase,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                // Only show the phase countdown number inside the card
                if (sessionStarted && breathPhase != "Session Complete" && !showCountdownMsg)
                  Text(
                    countdownText,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9A57E5),
                    ),
                  ),
              ],
            ),
          ),
          // Show small countdown message below card if needed
          if (showCountdownMsg)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                countdownText,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 28),
          Text(
            "Find your calm, one breath at a time.",
            style: TextStyle(
              fontSize: 20,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [Color(0xFFFEC5E5), Color(0xFFD4A7F4), Color(0xFFFEC5E5)],
                      startAngle: 0.0,
                      endAngle: 2 * pi,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFD4A7F4).withOpacity(0.18),
                        blurRadius: 32,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _GradientProgressPainter(
                      progress: remainingSeconds / selectedSession!.durationSeconds,
                      strokeWidth: 12,
                      gradientColors: [Color(0xFF9A57E5), Color(0xFFFEC5E5)],
                      backgroundColor: Colors.transparent,
                    ),
                    child: Container(),
                  ),
                ),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}",
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!sessionStarted)
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0xFFFEC5E5),
                  child: IconButton(
                    icon: Icon(Icons.play_arrow, color: Colors.white, size: 32),
                    onPressed: startSession,
                    tooltip: "Start",
                  ),
                )
              else ...[
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0xFF9A57E5),
                  child: IconButton(
                    icon: Icon(Icons.pause, color: Colors.white, size: 32),
                    onPressed: () {
                      setState(() {
                        timer?.cancel();
                        sessionStarted = false;
                      });
                    },
                    tooltip: "Pause",
                  ),
                ),
                const SizedBox(width: 24),
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0xFF9A57E5),
                  child: IconButton(
                    icon: Icon(Icons.stop, color: Colors.white, size: 32),
                    onPressed: () {
                      setState(() {
                        sessionReady = false;
                        sessionStarted = false;
                        audioPlayer.stop();
                        timer?.cancel();
                        countdownText = "";
                        breathPhase = "Inhale";
                        phaseCounter = 0;
                      });
                    },
                    tooltip: "End Session",
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class TrackerPage extends StatelessWidget {
  final MeditationStats stats;
  final int todayMinutes;
  final int dailyGoal;
  final Map<String, int> history;
  final bool isDarkMode;
  final Color appThemeColorAccent;
  final Color appThemePurple;
  final Color hotPink;

  final List<String> motivations;
  final int motivationIndex;

  TrackerPage({
    required this.stats,
    required this.todayMinutes,
    required this.dailyGoal,
    required this.history,
    required this.isDarkMode,
    required this.appThemeColorAccent,
    required this.appThemePurple,
    required this.hotPink,
    required this.motivations,
    required this.motivationIndex,
  });

  Widget _progressRing(String label, String value, double percent, IconData icon) {
    final double size = 100;
    final double stroke = 12;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: stroke,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFDF2F8).withOpacity(0.6)),
              ),
            ),
            SizedBox(
              width: size,
              height: size,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return SweepGradient(
                    colors: [
                      Color(0xFFFDBBD3),
                      Color(0xFFFC9BB5),
                      Color(0xFFE8A7E8),
                      Color(0xFFD4A7F4),
                    ],
                    startAngle: -pi / 2,
                    endAngle: -pi / 2 + (2 * pi),
                    stops: [0.0, 0.3, 0.7, 1.0],
                  ).createShader(rect);
                },
                child: CircularProgressIndicator(
                  value: percent.clamp(0.0, 1.0),
                  strokeWidth: stroke,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),
            Container(
              width: size - stroke * 1.8,
              height: size - stroke * 1.8,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFDF2F8).withOpacity(0.95),
                    Color(0xFFFBE7F3).withOpacity(0.85),
                  ],
                  center: Alignment.center,
                  radius: 0.7,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 4)),
                  BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 0, spreadRadius: -1),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Icon(icon, color: Color(0xFFD4A7F4), size: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(value, style: TextStyle(color: Color(0xFF8B5A9F), fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(label, style: TextStyle(color: isDarkMode ? AppColors.darkText : Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _dailyGoalBar() {
    double progress = todayMinutes / dailyGoal;
    return Column(
      children: [
        Text('Today: $todayMinutes / $dailyGoal min', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDarkMode ? AppColors.darkText : Colors.black87)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 10,
            width: double.infinity,
            color: isDarkMode ? Colors.white12 : Colors.grey[200],
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [appThemeColorAccent, appThemePurple]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _weekHeatmap() {
    final List<String> days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    List<Widget> columns = [];
    for (int i = 0; i < 7; i++) {
      DateTime d = DateTime.now().subtract(Duration(days: 6 - i));
      String key = d.toIso8601String().split('T')[0];
      bool filled = (history[key] ?? 0) > 0;
      columns.add(
        Expanded(
          child: Column(
            children: [
              Text(days[i], style: TextStyle(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: filled ? (isDarkMode ? AppColors.accentPurple : appThemeColorAccent.withOpacity(0.25)) : Colors.black12.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: columns,
    );
  }

  Widget _motivationalText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Text(
        motivations[motivationIndex],
        key: ValueKey<int>(motivationIndex),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Tracker', style: TextStyle(color: Colors.white)),
        backgroundColor: isDarkMode ? AppColors.mediumPurple : hotPink,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: isDarkMode ? AppColors.darkPurple : Color(0xFFFFD6E0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.mediumPurple : hotPink,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, 8))],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _progressRing('Total Minutes', stats.totalMinutes.toString(), (todayMinutes / (dailyGoal <= 0 ? 1 : dailyGoal)).clamp(0.0, 1.0), Icons.timer),
                    _progressRing('Sessions', stats.sessionCount.toString(), (stats.sessionCount / 7).clamp(0.0, 1.0), Icons.auto_stories),
                    _progressRing('Streak', stats.streak.toString(), (stats.streak / 14).clamp(0.0, 1.0), Icons.whatshot),
                  ],
                ),
                const SizedBox(height: 14),
                _dailyGoalBar(),
                const SizedBox(height: 12),
                _weekHeatmap(),
                const SizedBox(height: 12),
                _motivationalText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
