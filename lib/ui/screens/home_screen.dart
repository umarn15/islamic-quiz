import 'package:flutter/material.dart';
import 'package:islamicquiz/data/models/question_model.dart';
import 'package:islamicquiz/ui/screens/quiz/quiz_screen.dart';
import 'package:islamicquiz/ui/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.waving_hand,
                        size: 48,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Assalamu Alaikum!',
                        style: textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ready to learn about Islam?',
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      textTheme: textTheme,
                      icon: Icons.emoji_events,
                      label: 'Points',
                      value: '0',
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      textTheme: textTheme,
                      icon: Icons.star,
                      label: 'Level',
                      value: '1',
                      color: Colors.yellow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
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

  Widget _buildStatCard({
    required TextTheme textTheme,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                    color: color,
                  ),
            ),
            Text(
              label,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
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
