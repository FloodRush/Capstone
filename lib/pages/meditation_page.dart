import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

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

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
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
  final Color appThemeColor = const Color(0xFFFF80AB);
  final Color backgroundPink = const Color(0xFFFCE4EC);

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    patternSelectionMode = false;
    sessionReady = false; // Initialize sessionReady to false
  }

  @override
  void dispose() {
    timer?.cancel();
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          child: patternSelectionMode
              ? _buildPatternSelectionUI()
              : sessionReady
                  ? _buildActiveSessionUI()
                  : _buildSessionSelectionUI(),
        ),
      ),
    );
  }

  Widget _buildSessionSelectionUI() {
    // Description for the selected session
    String sessionDescription = "";
    if (selectedSession != null) {
      if (selectedSession == sessions[0]) {
        sessionDescription =
            "A short reset to slow your breath and clear the mind. Perfect between tasks.";
      } else if (selectedSession == sessions[1]) {
        sessionDescription =
            "Enhance concentration and mental clarity with this focus-building practice.";
      } else if (selectedSession == sessions[2]) {
        sessionDescription =
            "Release tension and find calm with this stress-relieving session.";
      } else {
        sessionDescription =
            "Immerse yourself in a complete meditation experience for deep relaxation.";
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          const Text(
            "Meditation",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // Main meditation animation - changes based on selected session
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: backgroundPink,
              borderRadius: BorderRadius.circular(16),
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

          const SizedBox(height: 30),

          // Session grid cards - now with proper height calculation
          GridView.builder(
            shrinkWrap: true, // Important for scrollable content
            physics:
                const NeverScrollableScrollPhysics(), // Disable grid scrolling
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
            ),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              // Get session information
              final session = sessions[index];
              final isSelected = selectedSession == session;

              // Define tag labels for each session
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
                    color: isSelected ? appThemeColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.name
                                .split(' (')[0], // Remove the duration part
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
                              color:
                                  isSelected ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tagLabel,
                          style: TextStyle(
                            fontSize: 12,
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

          const SizedBox(height: 30), // Space before info card

          if (selectedSession != null) ...[
            // Session description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.spa, color: appThemeColor, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedSession!.name.split(' (')[0],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

            // Choose Breathing Pattern button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    patternSelectionMode = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appThemeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Choose Breathing Pattern",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20), // Bottom padding for scroll
          ],
        ],
      ),
    );
  }

  // Pattern selection UI remains the same
  Widget _buildPatternSelectionUI() {
    return Column(
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
        Expanded(
          child: ListView.builder(
            itemCount: breathingPatterns.length,
            itemBuilder: (context, index) {
              final pattern = breathingPatterns[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: selectedBreathingPattern == pattern ? 3 : 1,
                color: selectedBreathingPattern == pattern
                    ? appThemeColor.withOpacity(0.1)
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: selectedBreathingPattern == pattern
                        ? appThemeColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedBreathingPattern = pattern;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pattern.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedBreathingPattern != null
                ? () {
                    setState(() {
                      patternSelectionMode = false;
                      setupSession(); // Changed from startSession to setupSession
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: appThemeColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: const Text(
              "Begin Session",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Updated active session UI with Start button and proper phase display
  Widget _buildActiveSessionUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),

        const Text(
          "Meditation",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        // Keep the animation at the top
        Container(
          height: 200,
          width: 200,
          child: Lottie.asset(
            getAnimationForSession(),
            fit: BoxFit.contain,
            animate: true,
          ),
        ),

        const SizedBox(height: 30),

        // Large breathing phase name
        Text(
          breathPhase,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 16),

        // Show different content based on session state
        if (!sessionStarted)
          // Session ready but not started - show Start button
          Column(
            children: [
              Text(
                "Ready to begin your ${selectedSession!.name.split(' (')[0].toLowerCase()} session",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: startSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appThemeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Start",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        else if (countdownText == "Prepare to breathe" ||
            countdownText.startsWith("Starting") ||
            countdownText == "Session Complete")
          // Show preparation or completion text
          Text(
            countdownText,
            style: TextStyle(
              fontSize: 24,
              color: appThemeColor,
              fontWeight: FontWeight.w500,
            ),
          )
        else if (breathPhase != "Session Complete")
          // Show the phase counter (1, 2, 3, 4, etc.)
          Text(
            countdownText,
            style: TextStyle(
              fontSize: 36,
              color: appThemeColor,
              fontWeight: FontWeight.bold,
            ),
          ),

        const Spacer(),

        // Session countdown timer
        Text(
          "${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}",
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        // End Session button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "End Session",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
