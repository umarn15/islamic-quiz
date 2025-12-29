import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamicquiz/core/theme_data.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Section
              Text(
                'Appearance',
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
                                  'Dark Mode',
                                  style: textTheme.titleMedium,
                                ),
                                Text(
                                  themeNotifier.isDarkMode 
                                      ? 'Dark theme is enabled' 
                                      : 'Light theme is enabled',
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
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // About Section
              Text(
                'About',
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
                        title: 'App Version',
                        subtitle: '1.0.0',
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 2.0),
                      //   child: Divider(color: Colors.grey),
                      // ),
                      // _buildInfoRow(
                      //   context: context,
                      //   icon: Icons.star_outline,
                      //   title: 'Islamic Quiz',
                      //   subtitle: 'Learn Islam through interactive quizzes',
                      //   colorScheme: colorScheme,
                      //   textTheme: textTheme,
                      // ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Reset Section
              Text(
                'Data',
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
                            Icons.refresh,
                            color: colorScheme.error,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reset Progress',
                                  style: textTheme.titleMedium,
                                ),
                                Text(
                                  'Clear all quiz progress and scores',
                                  style: textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _showResetDialog(context);
                            },
                            child: Text(
                              'Reset',
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ),
                        ],
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

  void _showResetDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Progress'),
          content: const Text(
            'Are you sure you want to reset all your quiz progress? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement reset functionality
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progress reset successfully'),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}