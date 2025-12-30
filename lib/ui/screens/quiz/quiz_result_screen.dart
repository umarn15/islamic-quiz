import 'package:flutter/material.dart';
import 'package:islamicquiz/data/models/question_model.dart';
import 'package:islamicquiz/ui/screens/home_screen.dart';
import 'quiz_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final QuestionDifficulty difficulty;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = (correctAnswers / totalQuestions * 100).round();
    final resultData = _getResultData(percentage);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Result Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: resultData.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  resultData.icon,
                  size: 64,
                  color: resultData.color,
                ),
              ),
              const SizedBox(height: 24),
              
              // Result Title
              Text(
                resultData.title,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: resultData.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                resultData.message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Score Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.1),
                      colorScheme.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 40),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        Text(
                          ' / ${totalQuestions * 30}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.amber.shade300,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _showScoringInfo(context),
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.amber.shade600,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'points',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          icon: Icons.check_circle,
                          value: '$correctAnswers',
                          label: 'Correct',
                          color: Colors.green,
                        ),
                        _buildStatItem(
                          icon: Icons.cancel,
                          value: '${totalQuestions - correctAnswers}',
                          label: 'Wrong',
                          color: Colors.red,
                        ),
                        _buildStatItem(
                          icon: Icons.percent,
                          value: '$percentage%',
                          label: 'Score',
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Difficulty Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(difficulty).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.speed,
                      color: _getDifficultyColor(difficulty),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${difficulty.name.toUpperCase()} Mode',
                      style: TextStyle(
                        color: _getDifficultyColor(difficulty),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(difficulty: difficulty),
                          ),
                        );
                      },
                      icon: const Icon(Icons.replay),
                      label: const Text('Play Again'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Home'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(QuestionDifficulty difficulty) {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return Colors.green;
      case QuestionDifficulty.medium:
        return Colors.orange;
      case QuestionDifficulty.hard:
        return Colors.red;
    }
  }

  void _showScoringInfo(BuildContext context) {
    final lostPoints = totalQuestions * 30 - score;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[700]),
            const SizedBox(width: 8),
            const Text('How Scoring Works'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⏱️ Answer within 2 seconds → 30 points\n'
              '⏱️ After that, -2 points per second\n'
              '⏱️ Minimum 14 points per correct answer',
              style: TextStyle(height: 1.6),
            ),
            if (correctAnswers == totalQuestions && lostPoints > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All correct! You lost $lostPoints points due to time.',
                        style: TextStyle(fontSize: 13, color: Colors.amber[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  _ResultData _getResultData(int percentage) {
    if (percentage == 100) {
      return _ResultData(
        icon: Icons.auto_awesome,
        title: 'Perfect Score!',
        message: 'SubhanAllah! You answered everything perfectly!',
        color: Colors.deepPurple.shade300,
      );
    } else if (percentage >= 90) {
      return _ResultData(
        icon: Icons.emoji_events,
        title: 'Excellent!',
        message: 'MashaAllah! You did amazing!',
        color: Colors.amber,
      );
    } else if (percentage >= 70) {
      return _ResultData(
        icon: Icons.thumb_up,
        title: 'Good Job!',
        message: 'Keep learning and improving!',
        color: Colors.green,
      );
    } else if (percentage >= 50) {
      return _ResultData(
        icon: Icons.sentiment_satisfied,
        title: 'Nice Try!',
        message: 'Practice makes perfect!',
        color: Colors.orange,
      );
    } else {
      return _ResultData(
        icon: Icons.school,
        title: 'Keep Learning!',
        message: 'Don\'t give up, try again!',
        color: Colors.blue,
      );
    }
  }
}

class _ResultData {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  _ResultData({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });
}
