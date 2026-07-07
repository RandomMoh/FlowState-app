import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme.dart';
import '../data/stats_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(statsProvider);
    final notifier = ref.read(statsProvider.notifier);
    final weeklyMins = notifier.weeklyMinutes;
    final totalMins = notifier.totalMinutesThisWeek;
    final totalSessions = notifier.totalSessionsAllTime;
    final maxY = weeklyMins.isEmpty
        ? 60.0
        : (weeklyMins.reduce((a, b) => a > b ? a : b) + 30).clamp(30, 999);

    final now = DateTime.now();
    final dayLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return ['M', 'T', 'W', 'T', 'F', 'S', 'S'][d.weekday - 1];
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ANALYTICS',
          style: TextStyle(letterSpacing: 4.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: sessions.isEmpty
          ? _buildEmpty()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'THIS WEEK',
                          value: _formatMins(totalMins),
                          icon: Icons.timer_outlined,
                        ).animate().fadeIn().slideY(begin: 0.2),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: _StatCard(
                          label: 'SESSIONS',
                          value: '$totalSessions',
                          icon: Icons.bolt_outlined,
                        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingXxl),

                  const Text(
                    'DAILY FOCUS — LAST 7 DAYS',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      letterSpacing: 2.0,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY.toDouble(),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    dayLabels[i],
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) return const SizedBox.shrink();
                                return Text(
                                  '${value.toInt()}m',
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 10),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: AppTheme.surface,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          for (int i = 0; i < 7; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: weeklyMins[i],
                                  color: weeklyMins[i] > 0
                                      ? AppTheme.primaryAccent
                                      : AppTheme.surface,
                                  width: 22,
                                  borderRadius: BorderRadius.zero,
                                ),
                              ],
                            ),
                        ],
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => AppTheme.surface,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final mins = rod.toY.toInt();
                              if (mins == 0) return null;
                              return BarTooltipItem(
                                '${mins}m',
                                const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w700),
                              );
                            },
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                  ),

                  const SizedBox(height: AppTheme.spacingXxl),

                  const Text(
                    'RECENT SESSIONS',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      letterSpacing: 2.0,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  ...sessions.reversed.take(10).toList().asMap().entries.map(
                        (e) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            border: Border.all(
                                color: AppTheme.muted
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(e.value.date),
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                    letterSpacing: 1.0),
                              ),
                              Text(
                                '${e.value.durationMinutes}m',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (50 * e.key).ms),
                      ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart, size: 64, color: AppTheme.textSecondary),
          SizedBox(height: 16),
          Text(
            'NO DATA YET',
            style: TextStyle(
              color: AppTheme.textSecondary,
              letterSpacing: 3.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Complete a focus session to see your stats',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatMins(int mins) {
    if (mins < 60) return '${mins}m';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${d.day}/${d.month}';
  }
}


class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(
            color: AppTheme.muted.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.0,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}
