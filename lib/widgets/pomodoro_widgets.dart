import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroWidget extends StatefulWidget {
  final String title;
  const PomodoroWidget({super.key, required this.title});

  @override
  State<PomodoroWidget> createState() => _PomodoroWidgetState();
}

class _PomodoroWidgetState extends State<PomodoroWidget> {
  static const workMinutes = 25;
  static const breakMinutes = 5;

  late Duration remaining;
  Timer? _timer;
  bool running = false;
  bool onBreak = false;

  @override
  void initState() {
    super.initState();
    remaining = Duration(minutes: workMinutes);
  }

  void _startPause() {
    if (running) {
      _timer?.cancel();
      setState(()=>running=false);
      return;
    }
    setState(()=>running=true);
    _timer = Timer.periodic(const Duration(seconds:1), (_) {
      if (remaining.inSeconds <= 0) {
        _timer?.cancel();
        setState(()=>running=false);
        // toggle break/work
        setState(()=> onBreak = !onBreak);
        setState(()=> remaining = Duration(minutes: onBreak ? breakMinutes : workMinutes));
      } else {
        setState(()=> remaining = remaining - const Duration(seconds:1));
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() { running=false; onBreak=false; remaining=Duration(minutes: workMinutes); });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2,'0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2,'0');
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.title, style: const TextStyle(fontSize:18, fontWeight: FontWeight.bold)),
        const SizedBox(height:12),
        Text('${onBreak ? "Break" : "Work"} — $minutes:$seconds', style: const TextStyle(fontSize:32)),
        const SizedBox(height:12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(onPressed: _startPause, child: Text(running ? 'Pause' : 'Start')),
          const SizedBox(width:12),
          ElevatedButton(onPressed: _reset, child: const Text('Reset')),
        ]),
        const SizedBox(height:8),
        Text('Pomodoro — ${workMinutes}m work / ${breakMinutes}m break', style: const TextStyle(fontSize:12))
      ]),
    );
  }
}
