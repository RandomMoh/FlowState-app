import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/theme_provider.dart';
import 'core/router.dart';
import 'core/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const ProviderScope(child: FlowStateApp()));
}

class FlowStateApp extends ConsumerStatefulWidget {
  const FlowStateApp({super.key});

  @override
  ConsumerState<FlowStateApp> createState() => _FlowStateAppState();
}

class _FlowStateAppState extends ConsumerState<FlowStateApp> {
  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await Permission.notification.request();
    await ref.read(notificationServiceProvider).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'FlowState',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
    );
  }
}
