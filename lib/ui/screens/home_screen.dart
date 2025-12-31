import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamicquiz/data/models/question_model.dart';
import 'package:islamicquiz/data/providers/auth_provider.dart';
import 'package:islamicquiz/data/providers/local_stats_provider.dart';
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
    final localStats = ref.watch(localStatsProvider);
    final user = userData.valueOrNull;
    final isLoggedIn = user != null;
    
    final points = isLoggedIn ? user.points : localStats.points;
    final level = isLoggedIn ? user.level : localStats.level;
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
              Container(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: darkMode
                        ? [
                      colorScheme.primary.withValues(alpha: 0.6),
                      colorScheme.primary.withValues(alpha: 0.5),
                      colorScheme.primary.withValues(alpha: 0.4),
                    ]
                        : [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.85),
                      colorScheme.primary.withValues(alpha: 0.7),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative pattern
                    Positioned(
                      right: 0,
                      top: -6,
                      child: Icon(
                        Icons.mosque,
                        size: 140,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstName.isNotEmpty
                              ? 'Assalamu Alaikum, $firstName'
                              : 'Assalamu Alaikum',
                          style: textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Test and grow your Islamic knowledge',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Stats card
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildInlineStat(
                                icon: Icons.emoji_events_outlined,
                                value: points.toString(),
                                label: 'Points',
                              ),
                              Container(
                                height: 36,
                                width: 1,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              _buildInlineStat(
                                icon: Icons.trending_up,
                                value: level.toString(),
                                label: 'Level',
                              ),
                            ],
                          ),
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
    _showQuestionCountDialog(difficulty);
  }

  void _showQuestionCountDialog(QuestionDifficulty difficulty) {
    final colorScheme = Theme.of(context).colorScheme;
    final questionCounts = [5, 10, 15, 20, 40];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.quiz, color: colorScheme.primary),
                const SizedBox(width: 10),
                const Text(
                  'Number of Questions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: questionCounts.map((count) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          difficulty: difficulty,
                          questionCount: count,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 76) / 2,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Questions',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
                        effectiveColor.withValues(alpha: 0.1),
                        effectiveColor.withValues(alpha: 0.06),
                      ]
                    : [
                        color.withValues(alpha: 0.06),
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
