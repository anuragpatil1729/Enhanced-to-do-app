import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  Timer? _timer;
  int _start = 25 * 60;
  bool _isRunning = false;
  String _sessionType = 'Focus';

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _timer?.cancel();
          _isRunning = false;
          // Simple session switch logic
          if (_sessionType == 'Focus') {
            _sessionType = 'Break';
            _start = 5 * 60;
          } else {
            _sessionType = 'Focus';
            _start = 25 * 60;
          }
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
    setState(() {
      _isRunning = true;
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _start = 25 * 60;
      _sessionType = 'Focus';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _start ~/ 60;
    final seconds = _start % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Mode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _sessionType,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _start / (25 * 60),
                    strokeWidth: 10,
                  ),
                  Center(
                    child: Text(
                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning)
                  ElevatedButton(
                    onPressed: startTimer,
                    child: const Text('Start'),
                  ),
                if (_isRunning)
                  ElevatedButton(
                    onPressed: pauseTimer,
                    child: const Text('Pause'),
                  ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: resetTimer,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
