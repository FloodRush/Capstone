
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class MeditationPage extends StatefulWidget {
  @override
  _MeditationPageState createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  int selectedSession = 5;
  bool showStart = false;
  bool showCountdown = false;
  String countdownText = "Ready... Start";
  late AudioPlayer _musicPlayer;
  late AudioPlayer _breathPlayer;
  Timer? _breathTimer;

  @override
  void initState() {
    super.initState();
    _musicPlayer = AudioPlayer();
    _breathPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _musicPlayer.dispose();
    _breathPlayer.dispose();
    _breathTimer?.cancel();
    super.dispose();
  }

  void startSession() async {
    setState(() {
      showStart = true;
      showCountdown = false;
      countdownText = "Ready... Start";
    });

    // Delay for "Ready... Start"
    await Future.delayed(Duration(seconds: 2));

    playSessionMusic();
    startBreathingLoop();
  }

  void startBreathingLoop() {
    setState(() {
      showCountdown = true;
    });

    _breathTimer = Timer.periodic(Duration(seconds: 8), (timer) async {
      for (int i = 5; i > 0; i--) {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          countdownText = "Inhale $i";
        });
      }
      for (int i = 3; i > 0; i--) {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          countdownText = "Exhale $i";
        });
      }
    });
  }

  void playSessionMusic() async {
    String musicPath = "assets/audio/meditation_music.mp3";
    String breathPath = "assets/audio/breath_5.mp3";

    switch (selectedSession) {
      case 10:
        breathPath = "assets/audio/breath_10.mp3";
        break;
      case 15:
        breathPath = "assets/audio/breath_15.mp3";
        break;
      case 60:
        breathPath = "assets/audio/breath_15.mp3";
        break;
    }

    await _musicPlayer.stop();
    await _breathPlayer.stop();
    await _musicPlayer.play(AssetSource(musicPath));
    await _breathPlayer.play(AssetSource(breathPath));
  }

  String getAnimationForSession() {
    switch (selectedSession) {
      case 10:
        return "assets/animation/session_10.json";
      case 15:
        return "assets/animation/session_15.json";
      case 60:
        return "assets/animation/session_60.json";
      case 5:
      default:
        return "assets/animation/session_5.json";
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionDurations = [5, 10, 15, 60];

    return Scaffold(
      backgroundColor: Color(0xFFFDF4FF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
        child: Column(
          children: [
            Text("Meditation", style: TextStyle(fontSize: 22)),
            SizedBox(height: 20),
            Lottie.asset(getAnimationForSession(), height: 200),
            SizedBox(height: 20),
            if (showStart)
              Column(
                children: [
                  Text(
                    countdownText,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text("Focus on your breathing.Inhale deeply, exhale slowly.",
                      textAlign: TextAlign.center),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    "Close your eyes.Let go of distractions.",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                ],
              ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: sessionDurations.map((duration) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSession = duration;
                    });
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: selectedSession == duration
                        ? Colors.purpleAccent
                        : Colors.grey.shade300,
                    child: Text("S${sessionDurations.indexOf(duration) + 1}",
                        style: TextStyle(color: Colors.black)),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: startSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.purple,
                elevation: 5,
              ),
              child: Text("Start Meditation"),
            )
          ],
        ),
      ),
    );
  }
}
