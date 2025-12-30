import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamicquiz/data/models/question_model.dart';
import 'package:islamicquiz/data/providers/auth_provider.dart';
import 'package:islamicquiz/ui/screens/quiz/quiz_screen.dart';
import 'package:islamicquiz/ui/screens/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    bool darkMode = Theme.of(context).brightness == Brightness.dark;

    final userData = ref.watch(userDataProvider);
    final user = userData.valueOrNull;
    final points = user?.points ?? 0;
    final level = user?.level ?? 1;
    final firstName = user?.displayName.split(' ').first ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.auto_stories,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Islamic Quiz',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: IconButton(
              icon: Icon(Icons.settings_outlined, size: 22,
               color: darkMode? Colors.white : Colors.black),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      firstName.isNotEmpty 
                          ? 'Assalamu Alaikum, $firstName'
                          : 'Assalamu Alaikum',
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Test Your Knowledge',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Inline Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInlineStat(
                          icon: Icons.emoji_events_outlined,
                          value: points.toString(),
                          label: 'Points',
                        ),
                        Container(
                          height: 36,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        _buildInlineStat(
                          icon: Icons.trending_up,
                          value: level.toString(),
                          label: 'Level',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              
              // Quiz Difficulty
              Text(
                'Choose Difficulty Level',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              _buildDifficultyCard(
                textTheme: textTheme,
                title: 'Easy',
                subtitle: 'Easy questions for beginners',
                icon: Icons.school,
                color: Colors.green.shade700,
                onTap: () {
                  _navigateToQuiz(QuestionDifficulty.easy);
                },
              ),
              const SizedBox(height: 8),
              
              _buildDifficultyCard(
                textTheme: textTheme,
                title: 'Medium',
                subtitle: 'Moderate difficulty questions',
                icon: Icons.psychology,
                color: colorScheme.primary,
                onTap: () {
                  _navigateToQuiz(QuestionDifficulty.medium);
                },
              ),
              const SizedBox(height: 8),
              
              _buildDifficultyCard(
                textTheme: textTheme,
                title: 'Hard',
                subtitle: 'Challenging questions for experts',
                icon: Icons.military_tech,
                color: Colors.red,
                onTap: () {
                  _navigateToQuiz(QuestionDifficulty.hard);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToQuiz(QuestionDifficulty difficulty) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(difficulty: difficulty),
      ),
    );
  }

  Widget _buildInlineStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.9)),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyCard({
    required TextTheme textTheme,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = isDarkMode ? Color.lerp(color, Colors.white, 0.35)! : color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode 
                    ? effectiveColor.withValues(alpha: 0.5)
                    : color.withValues(alpha: 0.25),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: isDarkMode
                    ? [
                        effectiveColor.withValues(alpha: 0.2),
                        effectiveColor.withValues(alpha: 0.08),
                      ]
                    : [
                        color.withValues(alpha: 0.08),
                        color.withValues(alpha: 0.02),
                      ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, size: 32, color: effectiveColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: effectiveColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: textTheme.bodyMedium?.copyWith(
                            color: isDarkMode 
                                ? Colors.white70 
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: effectiveColor.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
