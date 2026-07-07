import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _PremiumNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) {
          HapticFeedback.selectionClick();
          navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

/// Fully custom bottom navigation bar — no generic NavigationBar widget.
class _PremiumNavBar extends StatelessWidget {
  const _PremiumNavBar({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final void Function(int) onTap;

  static const _items = [
    _NavItem(
      label: 'Focus',
      icon: _FocusIcon(),
      activeIcon: _FocusIcon(active: true),
    ),
    _NavItem(
      label: 'Tasks',
      icon: _TasksIcon(),
      activeIcon: _TasksIcon(active: true),
    ),
    _NavItem(
      label: 'Stats',
      icon: _StatsIcon(),
      activeIcon: _StatsIcon(active: true),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(
          top: BorderSide(color: AppTheme.muted, width: 0.5),
        ),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        children: [
          for (int i = 0; i < _items.length; i++)
            Expanded(child: _NavTile(
              item: _items[i],
              selected: currentIndex == i,
              onTap: () => onTap(i),
            )),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.selected, required this.onTap});
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active indicator dot above icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: selected ? 20 : 0,
              height: 2,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            // Icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? item.activeIcon
                  : item.icon,
            ),
            const SizedBox(height: 4),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppTheme.textPrimary : AppTheme.textTertiary,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.label, required this.icon, required this.activeIcon});
  final String label;
  final Widget icon;
  final Widget activeIcon;
}


/// Focus icon: a circle with a thin inner ring and a center dot
class _FocusIcon extends StatelessWidget {
  const _FocusIcon({this.active = false});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _FocusIconPainter(active: active),
    );
  }
}

class _FocusIconPainter extends CustomPainter {
  final bool active;
  const _FocusIconPainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final color = active ? AppTheme.textPrimary : AppTheme.textTertiary;
    final strokeW = active ? 1.8 : 1.4;
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke;

    // Outer ring
    canvas.drawCircle(center, size.width / 2 - strokeW / 2, paint);
    // Inner ring
    canvas.drawCircle(center, size.width / 2 - 5.5, paint);
    // Center dot
    canvas.drawCircle(center, 1.8,
        Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_FocusIconPainter old) => old.active != active;
}

/// Tasks icon: a clean checklist (3 lines, 1st has a tick mark)
class _TasksIcon extends StatelessWidget {
  const _TasksIcon({this.active = false});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _TasksIconPainter(active: active),
    );
  }
}

class _TasksIconPainter extends CustomPainter {
  final bool active;
  const _TasksIconPainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final color = active ? AppTheme.textPrimary : AppTheme.textTertiary;
    final strokeW = active ? 1.8 : 1.4;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()..color = color..style = PaintingStyle.fill;

    // Row 1: checkbox (small square with tick)
    final boxRect = Rect.fromLTWH(0, 1, 7, 7);
    canvas.drawRect(boxRect, paint);
    if (active) {
      // Tick inside
      final tickPath = Path()
        ..moveTo(1.5, 4.5)
        ..lineTo(3.0, 6.0)
        ..lineTo(5.5, 2.5);
      canvas.drawPath(tickPath, paint);
    }
    // Line next to row 1
    canvas.drawLine(Offset(9.5, 4.5), Offset(size.width, 4.5), paint);

    // Row 2: empty circle
    canvas.drawCircle(const Offset(3.5, 13), 3.0, paint);
    // Line next to row 2
    canvas.drawLine(const Offset(9.5, 13), Offset(size.width, 13), paint);

    // Row 3: empty circle (faded / incomplete)
    final faint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(3.5, size.height - 2), 2.5, faint);
    canvas.drawLine(
      Offset(9.5, size.height - 2),
      Offset(size.width * 0.7, size.height - 2),
      faint,
    );

    // suppress unused
    fillPaint.color;
  }

  @override
  bool shouldRepaint(_TasksIconPainter old) => old.active != active;
}

/// Stats icon: a minimal bar chart (3 bars, ascending)
class _StatsIcon extends StatelessWidget {
  const _StatsIcon({this.active = false});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _StatsIconPainter(active: active),
    );
  }
}

class _StatsIconPainter extends CustomPainter {
  final bool active;
  const _StatsIconPainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final color = active ? AppTheme.textPrimary : AppTheme.textTertiary;
    final barW = 5.0;
    final gap = 2.0;
    final baseY = size.height - 1;
    final paint = Paint()..color = color..style = PaintingStyle.fill;

    // 3 bars: short, medium, tall
    final heights = [8.0, 13.0, 18.0];
    for (int i = 0; i < 3; i++) {
      final left = i * (barW + gap);
      final h = heights[i];
      // Inactive: outline only
      if (!active) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
      } else {
        paint.style = PaintingStyle.fill;
      }
      canvas.drawRect(
        Rect.fromLTWH(left, baseY - h, barW, h),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StatsIconPainter old) => old.active != active;
}
