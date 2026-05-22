import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/constants.dart';

/// Cronómetro Pomodoro (25/5 ou customizável).
class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const _focusSeconds = 25 * 60;
  int _remaining = _focusSeconds;
  Timer? _timer;
  bool _running = false;

  void _start() {
    if (_running) return;
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 0) {
        _stop();
        return;
      }
      setState(() => _remaining--);
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _stop();
    setState(() => _remaining = _focusSeconds);
  }

  String get _formatted {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_remaining / _focusSeconds);
    return Scaffold(
      appBar: AppBar(title: const Text('Pomodoro')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                    Text(
                      _formatted,
                      style: const TextStyle(
                          fontSize: 54, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text('🎯 Foco total durante 25 minutos',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    iconSize: 32,
                    onPressed: _running ? _stop : _start,
                    icon: Icon(_running
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.all(18),
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    iconSize: 30,
                    onPressed: _reset,
                    icon: const Icon(Icons.restart_alt_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
