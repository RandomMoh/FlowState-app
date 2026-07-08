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

class _PremiumNavBar extends StatelessWidget {
  const _PremiumNavBar({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(
        label: 'Focus',
        icon: _FocusIcon(active: false, colors: context.colors),
        activeIcon: _FocusIcon(active: true, colors: context.colors),
      ),
      _NavItem(
        label: 'Tasks',
        icon: _TasksIcon(active: false, colors: context.colors),
        activeIcon: _TasksIcon(active: true, colors: context.colors),
      ),
      _NavItem(
        label: 'Stats',
        icon: _StatsIcon(active: false, colors: context.colors),
        activeIcon: _StatsIcon(active: true, colors: context.colors),
      ),
    ];

    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border(
          top: BorderSide(color: context.colors.muted, width: 0.5),
        ),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(child: _NavTile(
              item: items[i],
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: selected ? 20 : 0,
              height: 2,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: selected ? context.colors.primaryAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected ? item.activeIcon : item.icon,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? context.colors.textPrimary : context.colors.textTertiary,
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

class _FocusIcon extends StatelessWidget {
  const _FocusIcon({this.active = false, required this.colors});
  final bool active;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _FocusIconPainter(active: active, colors: colors),
    );
  }
}

class _FocusIconPainter extends CustomPainter {
  final bool active;
  final AppColors colors;
  const _FocusIconPainter({required this.active, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final color = active ? colors.textPrimary : colors.textTertiary;
    final strokeW = active ? 1.8 : 1.4;
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, size.width / 2 - strokeW / 2, paint);
    canvas.drawCircle(center, size.width / 2 - 5.5, paint);
    canvas.drawCircle(center, 1.8, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_FocusIconPainter old) => old.active != active || old.colors != colors;
}

class _TasksIcon extends StatelessWidget {
  const _TasksIcon({this.active = false, required this.colors});
  final bool active;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _TasksIconPainter(active: active, colors: colors),
    );
  }
}

class _TasksIconPainter extends CustomPainter {
  final bool active;
  final AppColors colors;
  const _TasksIconPainter({required this.active, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final color = active ? colors.textPrimary : colors.textTertiary;
    final strokeW = active ? 1.8 : 1.4;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()..color = color..style = PaintingStyle.fill;

    final boxRect = Rect.fromLTWH(0, 1, 7, 7);
    canvas.drawRect(boxRect, paint);
    if (active) {
      final tickPath = Path()
        ..moveTo(1.5, 4.5)
        ..lineTo(3.0, 6.0)
        ..lineTo(5.5, 2.5);
      canvas.drawPath(tickPath, paint);
    }
    canvas.drawLine(Offset(9.5, 4.5), Offset(size.width, 4.5), paint);
    canvas.drawCircle(const Offset(3.5, 13), 3.0, paint);
    canvas.drawLine(const Offset(9.5, 13), Offset(size.width, 13), paint);

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
  }

  @override
  bool shouldRepaint(_TasksIconPainter old) => old.active != active || old.colors != colors;
}

class _StatsIcon extends StatelessWidget {
  const _StatsIcon({this.active = false, required this.colors});
  final bool active;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _StatsIconPainter(active: active, colors: colors),
    );
  }
}

class _StatsIconPainter extends CustomPainter {
  final bool active;
  final AppColors colors;
  const _StatsIconPainter({required this.active, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final color = active ? colors.textPrimary : colors.textTertiary;
    final barW = 5.0;
    final gap = 2.0;
    final baseY = size.height - 1;
    final paint = Paint()..color = color..style = PaintingStyle.fill;

    final heights = [8.0, 13.0, 18.0];
    for (int i = 0; i < 3; i++) {
      final left = i * (barW + gap);
      final h = heights[i];
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
  bool shouldRepaint(_StatsIconPainter old) => old.active != active || old.colors != colors;
}
