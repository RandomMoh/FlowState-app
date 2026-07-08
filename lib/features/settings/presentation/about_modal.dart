import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme.dart';
import '../../../core/theme_provider.dart';

class AboutModal extends ConsumerWidget {
  const AboutModal({super.key});

  Future<void> _launchURL(String urlString) async {
    final url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Dialog(
      backgroundColor: context.colors.surface2,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'SETTINGS & ABOUT',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 14,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            
            // Theme Toggler
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border.all(color: context.colors.muted.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'THEME',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 56,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDark ? context.colors.primaryAccent : context.colors.muted,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            top: 2,
                            bottom: 2,
                            left: isDark ? 30 : 2,
                            right: isDark ? 2 : 30,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.colors.background,
                              ),
                              child: Icon(
                                isDark ? Icons.dark_mode : Icons.light_mode,
                                size: 14,
                                color: isDark ? context.colors.primaryAccent : context.colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            // GitHub Link
            InkWell(
              onTap: () => _launchURL('https://github.com/RandomMoh/FlowState-app.git'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  border: Border.all(color: context.colors.muted.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.code, color: context.colors.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OPEN SOURCE',
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 12,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'View the source code on GitHub',
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: context.colors.textTertiary, size: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Gumroad Link
            InkWell(
              onTap: () => _launchURL('https://mohh.gumroad.com/'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  border: Border.all(color: context.colors.muted.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.storefront, color: context.colors.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MORE FROM MOHH',
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 12,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Explore premium web templates',
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: context.colors.textTertiary, size: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CLOSE',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showAboutModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const AboutModal(),
  );
}
