import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:islamicquiz/data/models/question_model.dart';
import 'package:islamicquiz/data/providers/question_provider.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final QuestionDifficulty difficulty;
  final int questionCount;

  const QuizScreen({
    super.key,
    required this.difficulty,
    this.questionCount = 10,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> with TickerProviderStateMixin {
  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  bool _isLoading = true;
  bool _hasAnswered = false;
  int? _selectedOptionIndex;

  // Timer
  static const int _timerDuration = 10;
  int _timeLeft = _timerDuration;
  Timer? _timer;

  // Text-to-Speech
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  // Animations
  late AnimationController _timerAnimationController;
  late AnimationController _optionAnimationController;
  late Animation<double> _timerAnimation;

  @override
  void initState() {
    super.initState();
    _initTts();
    _timerAnimationController = AnimationController(
      duration: const Duration(seconds: _timerDuration),
      vsync: this,
    );
    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_timerAnimationController);

    _optionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _loadQuestions();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('en-GB');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });
    
    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
    
    _flutterTts.setCancelHandler(() {
      setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speakQuestion(QuestionModel question) async {
    await _flutterTts.stop();
    await _flutterTts.speak(question.questionText);
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await ref.read(questionServiceProvider).getQuestionsByDifficulty(widget.difficulty);
      
      if (questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No questions available for this difficulty')),
          );
          Navigator.pop(context);
        }
        return;
      }

      // Shuffle and take up to the requested number of questions
      final shuffled = List<QuestionModel>.from(questions)..shuffle(Random());
      
      setState(() {
        _questions = shuffled.take(widget.questionCount).toList();
        _isLoading = false;
      });
      
      _startTimer();
      _speakQuestion(_questions[_currentIndex]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading questions: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startTimer() {
    _timeLeft = _timerDuration;
    _timerAnimationController.reset();
    _timerAnimationController.forward();
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    _timer?.cancel();
    if (!_hasAnswered) {
      setState(() {
        _hasAnswered = true;
        _selectedOptionIndex = -1; // No selection
      });
      _showFeedbackAndProceed(false);
    }
  }

  void _selectOption(int index) {
    if (_hasAnswered) return;

    _timer?.cancel();
    final question = _questions[_currentIndex];
    final isCorrect = index == question.correctOptionIndex;

    setState(() {
      _hasAnswered = true;
      _selectedOptionIndex = index;
      if (isCorrect) {
        _correctAnswers++;
        _score += _calculateScore();
      }
    });

    _showFeedbackAndProceed(isCorrect);
  }

  int _calculateScore() {
    // Full marks (30 points) if answered within first 3 seconds (7+ seconds left)
    // Then -2 points per second: 6->28, 5->26, 4->24, 3->22, 2->20, 1->18, 0->16
    const int fullMarkThreshold = 7;
    const int maxScore = 30;

    if (_timeLeft >= fullMarkThreshold) {
      return maxScore;
    }
    
    // Deduct 2 points per second after reading time
    return maxScore - ((fullMarkThreshold - _timeLeft) * 2);
  }

  void _showFeedbackAndProceed(bool isCorrect) {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _hasAnswered = false;
          _selectedOptionIndex = null;
        });
        _startTimer();
        _speakQuestion(_questions[_currentIndex]);
      } else {
        _finishQuiz();
      }
    });
  }

  void _finishQuiz() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          score: _score,
          totalScore: _questions.length * 30,
          correctAnswers: _correctAnswers,
          totalQuestions: _questions.length,
          difficulty: widget.difficulty,
          questionCount: widget.questionCount,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flutterTts.stop();
    _timerAnimationController.dispose();
    _optionAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDarkMode ? null : const Color(0xFFF5F7FF),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [
                      const Color(0xFF6B4CE6).withValues(alpha: 0.15),
                      colorScheme.surface,
                    ]
                  : [
                      const Color(0xFFEDE9FE),
                      const Color(0xFFF5F7FF),
                    ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated quiz icon with bouncing effect
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6B4CE6), Color(0xFF8B6EF7)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6B4CE6).withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.quiz_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Loading text with dots animation
                _LoadingText(difficulty: widget.difficulty),
                const SizedBox(height: 24),
                // Progress indicator
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      backgroundColor: isDarkMode
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFFE9D5FF),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6B4CE6)),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Fun tip
                Container(
                  margin: EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width * 0.14),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFFFCD34D).withValues(alpha: 0.15)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFCD34D).withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFFFCD34D).withValues(alpha: 0.2)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.lightbulb_rounded,
                          size: 28,
                          color: isDarkMode ? const Color(0xFFFCD34D) : const Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getRandomTip(),
                          style: TextStyle(
                            color: isDarkMode ? const Color(0xFFFCD34D) : const Color(0xFF92400E),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: isDarkMode ? null : const Color(0xFFF5F7FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colorScheme, isDarkMode),
            _buildTimerBar(colorScheme, isDarkMode),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildQuestionCard(question, colorScheme, isDarkMode),
                    const SizedBox(height: 24),
                    ..._buildOptions(question, colorScheme, isDarkMode),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? colorScheme.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close_rounded, size: 24),
              onPressed: () => _showExitDialog(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B4CE6), Color(0xFF8B6EF7)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.track_changes_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Question ${_currentIndex + 1}/${_questions.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    backgroundColor: isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFE9D5FF),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6B4CE6)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFCD34D), Color(0xFFFBBF24)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFCD34D).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Color(0xFF78350F),
                ),
                const SizedBox(width: 6),
                Text(
                  '$_score',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF78350F),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBar(ColorScheme colorScheme, bool isDarkMode) {
    final timerColor = _timeLeft <= 3 
        ? const Color(0xFFF44336) 
        : (_timeLeft <= 5 ? const Color(0xFFFF9800) : const Color(0xFF4CAF50));
    final timerIcon = _timeLeft <= 3 
        ? Icons.sentiment_very_dissatisfied_rounded 
        : (_timeLeft <= 5 ? Icons.sentiment_neutral_rounded : Icons.sentiment_satisfied_alt_rounded);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: timerColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              timerIcon,
              size: 20,
              color: timerColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedBuilder(
              animation: _timerAnimation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: _timeLeft / _timerDuration,
                    backgroundColor: isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : timerColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                    minHeight: 12,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: timerColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: timerColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$_timeLeft',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: timerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionModel question, ColorScheme colorScheme, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  const Color(0xFF6B4CE6).withValues(alpha: 0.2),
                  const Color(0xFF8B6EF7).withValues(alpha: 0.1),
                ]
              : [
                  const Color(0xFFEDE9FE),
                  const Color(0xFFF5F3FF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF6B4CE6).withValues(alpha: 0.3),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4CE6).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(question.difficulty).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getDifficultyColor(question.difficulty).withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getDifficultyIcon(question.difficulty),
                      size: 16,
                      color: _getDifficultyColor(question.difficulty),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      question.difficulty.name.toUpperCase(),
                      style: TextStyle(
                        color: _getDifficultyColor(question.difficulty),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4CE6).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => _speakQuestion(question),
                  icon: Icon(
                    _isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                    size: 24,
                    color: const Color(0xFF6B4CE6),
                  ),
                  tooltip: 'Read question aloud',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            question.questionText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getDifficultyIcon(QuestionDifficulty difficulty) {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return Icons.sentiment_satisfied_alt_rounded;
      case QuestionDifficulty.medium:
        return Icons.psychology_rounded;
      case QuestionDifficulty.hard:
        return Icons.local_fire_department_rounded;
    }
  }

  List<Widget> _buildOptions(QuestionModel question, ColorScheme colorScheme, bool isDarkMode) {
    final optionLabels = ['A', 'B', 'C', 'D'];
    final optionColors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
    ];

    return List.generate(question.options.length, (index) {
      final isSelected = _selectedOptionIndex == index;
      final isCorrect = index == question.correctOptionIndex;
      final showResult = _hasAnswered;

      Color backgroundColor;
      Color borderColor;
      Color textColor;
      IconData? resultIcon;

      if (showResult) {
        if (isCorrect) {
          backgroundColor = const Color(0xFF4CAF50).withValues(alpha: isDarkMode ? 0.25 : 0.2);
          borderColor = const Color(0xFF4CAF50);
          textColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
          resultIcon = Icons.check_circle_rounded;
        } else if (isSelected && !isCorrect) {
          backgroundColor = const Color(0xFFF44336).withValues(alpha: isDarkMode ? 0.25 : 0.2);
          borderColor = const Color(0xFFF44336);
          textColor = isDarkMode ? const Color(0xFFE57373) : const Color(0xFFC62828);
          resultIcon = Icons.cancel_rounded;
        } else {
          backgroundColor = isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF3F4F6);
          borderColor = isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFE5E7EB);
          textColor = isDarkMode ? Colors.white54 : const Color(0xFF9CA3AF);
          resultIcon = null;
        }
      } else {
        backgroundColor = isDarkMode
            ? optionColors[index].withValues(alpha: 0.15)
            : optionColors[index].withValues(alpha: 0.1);
        borderColor = optionColors[index].withValues(alpha: isDarkMode ? 0.4 : 0.3);
        textColor = isDarkMode ? Colors.white : const Color(0xFF2D3748);
        resultIcon = null;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _hasAnswered ? null : () => _selectOption(index),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 2.5),
                boxShadow: isSelected && showResult
                    ? [
                        BoxShadow(
                          color: borderColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: showResult
                          ? (isCorrect
                              ? const Color(0xFF4CAF50)
                              : (isSelected ? const Color(0xFFF44336) : Colors.grey))
                                  .withValues(alpha: 0.2)
                          : optionColors[index].withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        optionLabels[index],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: showResult
                              ? (isCorrect
                                  ? const Color(0xFF4CAF50)
                                  : (isSelected ? const Color(0xFFF44336) : Colors.grey))
                              : optionColors[index],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      question.options[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (resultIcon != null)
                    Icon(
                      resultIcon,
                      size: 28,
                      color: isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
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

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 24,
                  color: Color(0xFFFF9800),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Leave Quiz?', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Text(
          'Your progress will be lost. Are you sure you want to leave?',
          style: TextStyle(fontSize: 15, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Stay', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Leave', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  String _getRandomTip() {
    final tips = [
      'Answer quickly for more points!',
      'You have 10 seconds per question',
      'Stay calm and do your best!',
      'Learning is fun!',
    ];
    return tips[Random().nextInt(tips.length)];
  }
}

// Animated loading text widget
class _LoadingText extends StatefulWidget {
  final QuestionDifficulty difficulty;
  
  const _LoadingText({required this.difficulty});

  @override
  State<_LoadingText> createState() => _LoadingTextState();
}

class _LoadingTextState extends State<_LoadingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _dotCount = (_dotCount + 1) % 4;
          });
          _controller.reset();
          _controller.forward();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getDifficultyLabel() {
    switch (widget.difficulty) {
      case QuestionDifficulty.easy:
        return 'Beginner';
      case QuestionDifficulty.medium:
        return 'Normal';
      case QuestionDifficulty.hard:
        return 'Hard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;
    return Column(
      children: [
        Text(
          'Preparing ${_getDifficultyLabel()} Quiz$dots',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Get ready to test your knowledge!',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
