import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamicquiz/data/models/question_model.dart';
import 'package:islamicquiz/data/providers/auth_provider.dart';
import 'package:islamicquiz/data/providers/local_stats_provider.dart';
import 'package:islamicquiz/ui/screens/home_screen.dart';
import 'quiz_screen.dart';

class QuizResultScreen extends ConsumerStatefulWidget {
  final int score;
  final int totalScore;
  final int correctAnswers;
  final int totalQuestions;
  final QuestionDifficulty difficulty;
  final int questionCount;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.totalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.difficulty,
    required this.questionCount,
  });

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen>
    with TickerProviderStateMixin {
  bool _pointsUpdated = false;
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 8));

    // Scale animation for the result icon
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Slide animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Pulse animation for score
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Progress animation for circular indicator
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _scaleController.forward();
      _slideController.forward();
      _progressController.forward();
    });

    _updateUserPoints();
    _checkForCelebration();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _checkForCelebration() {
    final percentage = (widget.score / widget.totalScore * 100).round();
    if (percentage >= 90) {
      _confettiController.play();
      _playCelebrationSound();
    }
  }

  Future<void> _playCelebrationSound() async {
    await _audioPlayer.play(AssetSource('sounds/celebration.wav'));
  }

  Future<void> _updateUserPoints() async {
    if (_pointsUpdated) return;
    _pointsUpdated = true;

    final userData = ref.read(userDataProvider);
    if (userData.valueOrNull != null) {
      await ref.read(userDataProvider.notifier).updatePoints(widget.score);
    } else {
      await ref.read(localStatsProvider.notifier).addPoints(widget.score);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = (widget.score / widget.totalScore * 100).round();
    final resultData = _getResultData(percentage);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: resultData.color.withValues(alpha: 0.2)
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      resultData.color.withValues(alpha: 0.06),
                      resultData.color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.06),
                      colorScheme.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxHeight < 799;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, isSmallScreen ? 12 : 24, 20, 12),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // Animated Result Icon with Circular Progress
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: _buildCircularProgress(percentage, resultData, colorScheme, isSmallScreen),
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 24),

                          // Result Title with gradient
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [resultData.color, resultData.color.withValues(alpha: 0.7)],
                            ).createShader(bounds),
                            child: Text(
                              resultData.title,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 28 : 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            resultData.message,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 28),

                          // Score Card with glassmorphism effect
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: _buildScoreCard(colorScheme, isDark, isSmallScreen),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 20),

                          // Stats Row
                          _buildStatsRow(colorScheme, percentage, isDark, isSmallScreen),
                          SizedBox(height: isSmallScreen ? 16 : 28),

                          // Action Buttons
                          _buildActionButtons(context, colorScheme),
                          SizedBox(height: isSmallScreen ? 12 : 20),

                          // Difficulty Badge
                          _buildDifficultyBadge(),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.amber,
                  Colors.pink,
                  Colors.blue,
                  Colors.purple,
                  Colors.orange,
                  Colors.teal,
                ],
                numberOfParticles: 200,
                gravity: 0.3,
                emissionFrequency: 0.08,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress(int percentage, _ResultData resultData, ColorScheme colorScheme, bool isSmallScreen) {
    final size = isSmallScreen ? 130.0 : 160.0;
    final innerSize = isSmallScreen ? 110.0 : 140.0;
    final iconSize = isSmallScreen ? 54.0 : 68.0;
    
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              CustomPaint(
                size: Size(size, size),
                painter: _CircularProgressPainter(
                  progress: _progressAnimation.value * (percentage / 100),
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  progressColor: resultData.color,
                  strokeWidth: isSmallScreen ? 10 : 12,
                ),
              ),
              // Inner glow container
              Container(
                width: innerSize,
                height: innerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      resultData.color.withValues(alpha: 0.2),
                      resultData.color.withValues(alpha: 0.05),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: resultData.color.withValues(alpha: 0.24),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  resultData.icon,
                  size: iconSize,
                  color: resultData.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreCard(ColorScheme colorScheme, bool isDark, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withValues(alpha: isDark ? 0.15 : 0.1),
            Colors.orange.withValues(alpha: isDark ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Star icon with glow
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.amber.withValues(alpha: 0.3),
                  Colors.amber.withValues(alpha: 0),
                ],
              ),
            ),
            child: Icon(Icons.star_rounded, color: Colors.amber, size: isSmallScreen ? 36 : 44),
          ),
          SizedBox(height: isSmallScreen ? 4 : 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${widget.score}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 44 : 56,
                  fontWeight: FontWeight.w800,
                  color: Colors.amber.shade600,
                  height: 1,
                ),
              ),
              Text(
                ' / ${widget.totalQuestions * 30}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade400,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showScoringInfo(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.amber.shade700,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'POINTS EARNED',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.amber.shade700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ColorScheme colorScheme, int percentage, bool isDark, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_rounded,
            value: '${widget.correctAnswers}',
            label: 'Correct',
            color: Colors.green,
            isDark: isDark,
            isSmallScreen: isSmallScreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.cancel_rounded,
            value: '${widget.totalQuestions - widget.correctAnswers}',
            label: 'Wrong',
            color: Colors.red,
            isDark: isDark,
            isSmallScreen: isSmallScreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.percent_rounded,
            value: '$percentage%',
            label: 'Accuracy',
            color: Color(0xFF4ADE80),
            isDark: isDark,
            isSmallScreen: isSmallScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.5)),
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.6)],
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      difficulty: widget.difficulty,
                      questionCount: widget.questionCount,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.replay_rounded, color: Colors.grey.shade300),
                    const SizedBox(width: 8),
                    Text(
                      'Play Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.6)],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_rounded, color: Colors.grey.shade300),
                      SizedBox(width: 8),
                      Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyBadge() {
    final color = _getDifficultyColor(widget.difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed_rounded, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '${widget.difficulty.name.toUpperCase()} MODE',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
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
    final lostPoints = widget.totalQuestions * 30 - widget.score;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline_rounded, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            const Text('How Scoring Works', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoringRow('⚡', 'Answer within 3 seconds', '30 points'),
            const SizedBox(height: 8),
            _buildScoringRow('⏱️', 'After 3 seconds', '-2 pts/sec'),
            const SizedBox(height: 8),
            _buildScoringRow('🛡️', 'Minimum per correct', '16 points'),
            if (widget.correctAnswers == widget.totalQuestions && lostPoints > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withValues(alpha: 0.2),
                      Colors.orange.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Perfect answers! Lost $lostPoints pts to time.',
                        style: TextStyle(fontSize: 13, color: Colors.amber[800], fontWeight: FontWeight.w500),
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
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Got it!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildScoringRow(String emoji, String description, String points) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(child: Text(description, style: const TextStyle(fontSize: 14))),
        Text(points, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  _ResultData _getResultData(int percentage) {
    if (percentage == 100) {
      return _ResultData(
        icon: Icons.emoji_events_rounded,
        title: 'Perfect Score!',
        message: 'SubhanAllah! You answered everything perfectly!',
        color: Colors.amber,
      );
    } else if (percentage >= 80) {
      return _ResultData(
        icon: Icons.auto_awesome_rounded,
        title: percentage >= 90 ? 'Almost Perfect!' : 'Excellent!',
        message: 'MashaAllah! You did amazing!',
        color: Colors.deepPurple.shade400,
      );
    } else if (percentage >= 60) {
      return _ResultData(
        icon: Icons.thumb_up_rounded,
        title: 'Good Job!',
        message: 'Keep learning and improving!',
        color: Colors.green,
      );
    } else if (percentage >= 40) {
      return _ResultData(
        icon: Icons.sentiment_satisfied_rounded,
        title: 'Nice Try!',
        message: 'Practice makes perfect!',
        color: Colors.orange,
      );
    } else {
      return _ResultData(
        icon: Icons.school_rounded,
        title: 'Keep Learning!',
        message: "Don't give up, try again!",
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

// Custom painter for circular progress
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          progressColor.withValues(alpha: 0.6),
          progressColor,
          progressColor,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
