import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/timer/presentation/timer_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';
import '../features/stats/presentation/stats_screen.dart';
import 'scaffold_with_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorFocusKey = GlobalKey<NavigatorState>(
  debugLabel: 'focusNav',
);
final _shellNavigatorTasksKey = GlobalKey<NavigatorState>(
  debugLabel: 'tasksNav',
);
final _shellNavigatorStatsKey = GlobalKey<NavigatorState>(
  debugLabel: 'statsNav',
);

final goRouter = GoRouter(
  initialLocation: '/focus',
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorFocusKey,
          routes: [
            GoRoute(
              path: '/focus',
              builder: (context, state) => const TimerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorTasksKey,
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (context, state) => const TasksScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorStatsKey,
          routes: [
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
