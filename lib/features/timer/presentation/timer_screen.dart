import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme.dart';
import '../../../../core/audio_service.dart';
import '../../../../core/notification_service.dart';
import '../../settings/presentation/about_modal.dart';
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
    ref.read(notificationServiceProvider).showTimerNotification(remainingSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        timer.cancel();
        // Record the completed session in stats
        final completedMinutes = totalSeconds ~/ 60;
        ref.read(statsProvider.notifier).recordSession(completedMinutes);
        HapticFeedback.heavyImpact();
        ref.read(audioServiceProvider).playCompletionDing();
        ref.read(notificationServiceProvider).showCompletionNotification();
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
        ref.read(notificationServiceProvider).cancelTimerNotification();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    ref.read(notificationServiceProvider).cancelTimerNotification();
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
              backgroundColor: context.colors.surface,
              title: Text(
                'SET FOCUS DURATION',
                style: TextStyle(
                  color: context.colors.textPrimary,
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
                    style: TextStyle(
                      color: context.colors.textPrimary,
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
                    activeColor: context.colors.primaryAccent,
                    inactiveColor: context.colors.muted,
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
                                  ? context.colors.primaryAccent
                                  : context.colors.background,
                              labelStyle: TextStyle(
                                color: selectedMinutes == m
                                    ? context.colors.background
                                    : context.colors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                              side: BorderSide(color: context.colors.muted),
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
                  child: Text('CANCEL',
                      style: TextStyle(color: context.colors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primaryAccent,
                    foregroundColor: context.colors.background,
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
                  child: Text('SET',
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
        backgroundColor: context.colors.surface,
        title: Text(
          'SESSION TYPE',
          style: TextStyle(
            color: context.colors.textPrimary,
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
                Divider(color: context.colors.muted, height: 1),
            itemBuilder: (_, i) => ListTile(
              dense: true,
              title: Text(
                labels[i],
                style: TextStyle(
                  color: labels[i] == _label
                      ? context.colors.primaryAccent
                      : context.colors.textPrimary,
                  fontWeight: labels[i] == _label
                      ? FontWeight.w800
                      : FontWeight.normal,
                  letterSpacing: 2.0,
                ),
              ),
              trailing: labels[i] == _label
                  ? Icon(Icons.check, color: context.colors.primaryAccent)
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
        backgroundColor: context.colors.surface,
        title: Text('SESSION COMPLETE',
            style: TextStyle(
                color: context.colors.textPrimary,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w800)),
        content: Text(
          'Great work! ${totalSeconds ~/ 60} minutes of $_label recorded.',
          style: TextStyle(color: context.colors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primaryAccent,
              foregroundColor: context.colors.background,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text('DONE',
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
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Balance for center alignment
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: _showLabelPicker,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _label,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    letterSpacing: 4.0,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.textSecondary,
                                  ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.keyboard_arrow_down,
                                color: context.colors.textSecondary, size: 18),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms),
                    ),
                  ),
                  IconButton(
                    onPressed: () => showAboutModal(context),
                    icon: Icon(Icons.more_horiz, color: context.colors.textSecondary),
                  ),
                ],
              ),

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
                      color: context.colors.textSecondary.withValues(alpha: 0.6),
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
                          ? context.colors.background
                          : context.colors.primaryAccent,
                      border: Border.all(
                          color: context.colors.primaryAccent, width: 2),
                    ),
                    child: Text(
                      isRunning ? 'PAUSE' : 'START FOCUS',
                      style: TextStyle(
                        color: isRunning
                            ? context.colors.primaryAccent
                            : context.colors.background,
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
                  child: Text(
                    'RESET',
                    style: TextStyle(
                      color: context.colors.textSecondary,
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
