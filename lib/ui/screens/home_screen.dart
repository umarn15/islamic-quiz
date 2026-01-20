import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamicquiz/core/localization/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    bool darkMode = Theme.of(context).brightness == Brightness.dark;

    final userData = ref.watch(userDataProvider);
    final localStats = ref.watch(localStatsProvider);
    final user = userData.valueOrNull;
    final isLoggedIn = user != null;
    
    final points = isLoggedIn ? user.points : localStats.points;
    final firstName = user?.displayName.split(' ').first ?? '';

    return Scaffold(
      backgroundColor: darkMode ? null : const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6B4CE6),
                    const Color(0xFF8B6EF7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_stories,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.appTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: darkMode 
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.settings_rounded,
                  size: 24,
                  color: darkMode ? Colors.white : const Color(0xFF6B4CE6),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
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
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6B4CE6),
                      Color(0xFF8B6EF7),
                      Color(0xFFAB8EFF),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 30,
                      bottom: -10,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    // Decorative mosque icon
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Icon(
                        Icons.mosque,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.waving_hand_rounded,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _greeting(firstName, l10n),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.letsLearnAndHaveFun,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Stats cards
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: darkMode
                                      ? [
                                          Colors.white.withValues(alpha: 0.15),
                                          Colors.white.withValues(alpha: 0.08),
                                        ]
                                      : [
                                          const Color(0xFFEDE9FE),
                                          const Color(0xFFDDD6FE),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: darkMode
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : const Color(0xFF8B6EF7).withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: darkMode
                                        ? const Color(0xFF6B4CE6).withValues(alpha: 0.3)
                                        : const Color(0xFF6B4CE6).withValues(alpha: 0.15),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: darkMode
                                            ? [
                                                const Color(0xFF8B6EF7).withValues(alpha: 0.3),
                                                const Color(0xFF6B4CE6).withValues(alpha: 0.2),
                                              ]
                                            : [
                                                Colors.deepPurple.shade100,
                                                Colors.deepPurple.shade50,
                                              ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.emoji_events_rounded,
                                      size: 30,
                                      color: darkMode
                                          ? Colors.grey.shade300
                                          : Colors.deepPurple.shade300,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    points.toString(),
                                    style: TextStyle(
                                      color: darkMode
                                          ? Colors.white
                                          : const Color(0xFF6B4CE6),
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.points,
                                    style: TextStyle(
                                      color: darkMode
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : const Color(0xFF6B4CE6).withValues(alpha: 0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              // Quiz Difficulty
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B4CE6), Color(0xFF8B6EF7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.sports_esports_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.pickYourChallenge,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              _buildDifficultyCard(
                textTheme: textTheme,
                title: l10n.easy,
                subtitle: l10n.perfectForBeginners,
                icon: Icons.sentiment_satisfied_alt_rounded,
                color: const Color(0xFF4CAF50),
                onTap: () {
                  _navigateToQuiz(QuestionDifficulty.easy);
                },
              ),
              const SizedBox(height: 12),
              
              _buildDifficultyCard(
                textTheme: textTheme,
                title: l10n.medium,
                subtitle: l10n.readyForMore,
                icon: Icons.psychology_rounded,
                color: const Color(0xFFFF9800),
                onTap: () {
                  _navigateToQuiz(QuestionDifficulty.medium);
                },
              ),
              const SizedBox(height: 12),
              
              _buildDifficultyCard(
                textTheme: textTheme,
                title: l10n.hard,
                subtitle: l10n.forTheBraveOnes,
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xFFF44336),
                onTap: () {
                  _navigateToQuiz(QuestionDifficulty.hard);
                },
              ),
              const SizedBox(height: 20),
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
    final l10n = AppLocalizations.of(context);
    final questionCounts = [5, 10, 15, 20];
    final icons = [
      Icons.looks_one_rounded,
      Icons.looks_two_rounded,
      Icons.looks_3_rounded,
      Icons.looks_4_rounded,
    ];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B4CE6), Color(0xFF8B6EF7)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.quiz_rounded,
                      size: 24,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.howManyQuestions,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: questionCounts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final count = entry.value;
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
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 84) / 2,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF6B4CE6).withValues(alpha: 0.15),
                            const Color(0xFF8B6EF7).withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF6B4CE6).withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            icons[index],
                            size: 32,
                            color: const Color(0xFF6B4CE6),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF6B4CE6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.questions,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
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
    final effectiveColor = isDarkMode ? Color.lerp(color, Colors.white, 0.3)! : color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                      effectiveColor.withValues(alpha: 0.3),
                      effectiveColor.withValues(alpha: 0.16),
                    ]
            ),
            border: Border.all(
              color: effectiveColor.withValues(alpha: isDarkMode ? 0.4 : 0.2),
              width: 2.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: effectiveColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: effectiveColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode 
                              ? Colors.white70 
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 22,
                    color: effectiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _greeting(String firstName, AppLocalizations l10n) {
    final greeting = l10n.assalamualaikum;
    return firstName.isNotEmpty ? '$greeting $firstName' : greeting;
  }
}
