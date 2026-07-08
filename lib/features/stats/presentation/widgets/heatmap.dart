import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../data/stats_provider.dart';

class HeatmapWidget extends ConsumerWidget {
  const HeatmapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(statsProvider);
    final now = DateTime.now();
    // Generate data for the last 60 days
    final Map<String, int> dailyMinutes = {};
    for (var s in sessions) {
      final key = '${s.date.year}-${s.date.month}-${s.date.day}';
      dailyMinutes[key] = (dailyMinutes[key] ?? 0) + s.durationMinutes;
    }

    // 7 rows, 8 columns approx (56 days)
    final int daysCount = 60;
    
    // We want the columns to be weeks and rows to be days of week.
    // Instead of full GitHub style which is complex to align, we can just do a Wrap 
    // or a GridView with crossAxisCount: 10
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIVITY HEATMAP',
          style: TextStyle(
            color: context.colors.textSecondary,
            letterSpacing: 2.0,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(daysCount, (index) {
            final date = now.subtract(Duration(days: daysCount - 1 - index));
            final key = '${date.year}-${date.month}-${date.day}';
            final mins = dailyMinutes[key] ?? 0;
            
            // Calculate intensity
            Color boxColor;
            if (mins == 0) {
              boxColor = context.colors.surface;
            } else if (mins < 30) {
              boxColor = context.colors.primaryAccent.withValues(alpha: 0.3);
            } else if (mins < 60) {
              boxColor = context.colors.primaryAccent.withValues(alpha: 0.6);
            } else {
              boxColor = context.colors.primaryAccent;
            }

            return Tooltip(
              message: '${date.month}/${date.day}: ${mins}m',
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(2),
                  border: mins == 0
                      ? Border.all(color: context.colors.muted.withValues(alpha: 0.2))
                      : null,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
