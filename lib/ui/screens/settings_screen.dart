import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamicquiz/core/localization/app_localizations.dart';
import 'package:islamicquiz/core/localization/locale_provider.dart';
import 'package:islamicquiz/core/theme_data.dart';
import 'package:islamicquiz/data/providers/auth_provider.dart';
import 'package:islamicquiz/data/services/auth_service.dart';
import 'package:islamicquiz/ui/screens/auth/login_screen.dart';
import 'package:islamicquiz/ui/screens/home_screen.dart';

import '../../main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeNotifier = ref.watch(themeProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final userData = ref.watch(userDataProvider);
    final isLoggedIn = userData.valueOrNull != null;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Section
              Text(
                l10n.appearance,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            themeNotifier.isDarkMode 
                                ? Icons.dark_mode 
                                : Icons.light_mode,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.darkMode,
                                  style: textTheme.titleMedium,
                                ),
                                Text(
                                  themeNotifier.isDarkMode 
                                      ? l10n.darkThemeEnabled 
                                      : l10n.lightThemeEnabled,
                                  style: textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: themeNotifier.isDarkMode,
                            onChanged: (value) {
                              ref.read(themeProvider.notifier).toggleTheme();
                            },
                            activeThumbColor: colorScheme.primary,
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      // Language Selection
                      InkWell(
                        onTap: () => _showLanguageDialog(context, ref, currentLocale),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.language,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.language,
                                      style: textTheme.titleMedium,
                                    ),
                                    Text(
                                      l10n.currentLanguage,
                                      style: textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: colorScheme.primary.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Account Section
              Text(
                l10n.account,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: isLoggedIn
                      ? _buildLoggedInContent(context, ref, userData.valueOrNull!, textTheme, colorScheme, l10n)
                      : _buildSignInContent(context, textTheme, colorScheme, l10n),
                ),
              ),

              const SizedBox(height: 24),
              
              // About Section
              Text(
                l10n.about,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context: context,
                        icon: Icons.info_outline,
                        title: l10n.appVersion,
                        subtitle: "${pubVersionName}(${pubVersionCode})",
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, Locale currentLocale) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context: context,
              ref: ref,
              locale: const Locale('en'),
              name: 'English',
              nativeName: 'English',
              isSelected: currentLocale.languageCode == 'en',
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 8),
            _buildLanguageOption(
              context: context,
              ref: ref,
              locale: const Locale('ur'),
              name: 'Urdu',
              nativeName: 'اردو',
              isSelected: currentLocale.languageCode == 'ur',
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required WidgetRef ref,
    required Locale locale,
    required String name,
    required String nativeName,
    required bool isSelected,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    nativeName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium,
              ),
              Text(
                subtitle,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignInContent(BuildContext context, TextTheme textTheme, ColorScheme colorScheme, AppLocalizations l10n) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.person_outline,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.signIn,
                    style: textTheme.titleMedium,
                  ),
                  Text(
                    l10n.signInToSaveProgress,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInContent(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? 'User',
                    style: textTheme.titleMedium,
                  ),
                  Text(
                    user.email ?? '',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 32),
        InkWell(
          onTap: () => _showLogoutDialog(context, ref, l10n),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  color: colorScheme.error,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.signOut,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.error.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.signOutConfirmTitle),
          content: Text(l10n.signOutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await AuthService().signOut();
                ref.read(userDataProvider.notifier).clearUser();
                
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
              ),
              child: Text(l10n.signOut),
            ),
          ],
        );
      },
    );
  }
}