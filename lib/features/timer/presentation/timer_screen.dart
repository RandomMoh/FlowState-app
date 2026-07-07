import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme.dart';
import '../../stats/data/stats_provider.dart';
import 'widgets/animated_dial.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  bool isRunning = false;
  int remainingSeconds = 25 * 60;
  int totalSeconds = 25 * 60;
  Timer? _timer;
  String _label = 'DEEP WORK';


  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        timer.cancel();
        // Record the completed session in stats
        final completedMinutes = totalSeconds ~/ 60;
        ref.read(statsProvider.notifier).recordSession(completedMinutes);
        HapticFeedback.heavyImpact();
        setState(() {
          isRunning = false;
          remainingSeconds = totalSeconds;
        });
        _showCompletionDialog();
      }
    });
  }

  void _toggleTimer() {
    setState(() {
      isRunning = !isRunning;
      if (isRunning) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      remainingSeconds = totalSeconds;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  String get timeText {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }


  Future<void> _showDurationPicker() async {
    if (isRunning) return; // can't edit while running
    int selectedMinutes = totalSeconds ~/ 60;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.surface,
              title: const Text(
                'SET FOCUS DURATION',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$selectedMinutes min',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: selectedMinutes.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    activeColor: AppTheme.primaryAccent,
                    inactiveColor: AppTheme.muted,
                    onChanged: (v) =>
                        setModalState(() => selectedMinutes = v.round()),
                  ),
                  const SizedBox(height: 8),
                  // Quick picks
                  Wrap(
                    spacing: 8,
                    children: [5, 10, 15, 25, 30, 45, 60, 90]
                        .map(
                          (m) => GestureDetector(
                            onTap: () => setModalState(() => selectedMinutes = m),
                            child: Chip(
                              label: Text('${m}m'),
                              backgroundColor: selectedMinutes == m
                                  ? AppTheme.primaryAccent
                                  : AppTheme.background,
                              labelStyle: TextStyle(
                                color: selectedMinutes == m
                                    ? AppTheme.background
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                              side: const BorderSide(color: AppTheme.muted),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('CANCEL',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: AppTheme.background,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                  ),
                  onPressed: () {
                    setState(() {
                      totalSeconds = selectedMinutes * 60;
                      remainingSeconds = totalSeconds;
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('SET',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _showLabelPicker() async {
    if (isRunning) return;
    const labels = [
      'DEEP WORK',
      'READING',
      'CODING',
      'WRITING',
      'STUDYING',
      'PLANNING',
      'DESIGN',
    ];
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'SESSION TYPE',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: labels.length,
            separatorBuilder: (_, _) =>
                const Divider(color: AppTheme.muted, height: 1),
            itemBuilder: (_, i) => ListTile(
              dense: true,
              title: Text(
                labels[i],
                style: TextStyle(
                  color: labels[i] == _label
                      ? AppTheme.primaryAccent
                      : AppTheme.textPrimary,
                  fontWeight: labels[i] == _label
                      ? FontWeight.w800
                      : FontWeight.normal,
                  letterSpacing: 2.0,
                ),
              ),
              trailing: labels[i] == _label
                  ? const Icon(Icons.check, color: AppTheme.primaryAccent)
                  : null,
              onTap: () {
                setState(() => _label = labels[i]);
                Navigator.pop(ctx);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('SESSION COMPLETE',
            style: TextStyle(
                color: AppTheme.textPrimary,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w800)),
        content: Text(
          'Great work! ${totalSeconds ~/ 60} minutes of $_label recorded.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              foregroundColor: AppTheme.background,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('DONE',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Session label — tap to change
                GestureDetector(
                  onTap: _showLabelPicker,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              letterSpacing: 4.0,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down,
                          color: AppTheme.textSecondary, size: 18),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms),

                const SizedBox(height: AppTheme.spacingXxl),

                // Tap dial to set duration
                GestureDetector(
                  onTap: _showDurationPicker,
                  child: AnimatedDial(
                    progress: remainingSeconds / totalSeconds,
                    timeText: timeText,
                    isRunning: isRunning,
                  ).animate().scale(
                        delay: 200.ms,
                        duration: 800.ms,
                        curve: Curves.easeOutBack,
                      ),
                ),

                const SizedBox(height: 8),
                if (!isRunning)
                  Text(
                    'Tap timer to change duration',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.6),
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: AppTheme.spacingXxl),

                // Play / Pause
                GestureDetector(
                  onTap: _toggleTimer,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 20),
                    decoration: BoxDecoration(
                      color: isRunning
                          ? AppTheme.background
                          : AppTheme.primaryAccent,
                      border: Border.all(
                          color: AppTheme.primaryAccent, width: 2),
                    ),
                    child: Text(
                      isRunning ? 'PAUSE' : 'START FOCUS',
                      style: TextStyle(
                        color: isRunning
                            ? AppTheme.primaryAccent
                            : AppTheme.background,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ).animate(target: isRunning ? 1 : 0).shimmer(
                        duration: 1000.ms,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                ),

                const SizedBox(height: 16),

                // Reset button
                GestureDetector(
                  onTap: _resetTimer,
                  child: const Text(
                    'RESET',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
