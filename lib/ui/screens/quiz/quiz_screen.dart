import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamicquiz/data/models/question_model.dart';
import 'package:islamicquiz/data/providers/question_provider.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final QuestionDifficulty difficulty;

  const QuizScreen({super.key, required this.difficulty});

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

  // Animations
  late AnimationController _timerAnimationController;
  late AnimationController _optionAnimationController;
  late Animation<double> _timerAnimation;

  @override
  void initState() {
    super.initState();
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

      // Shuffle and take up to 10 questions
      final shuffled = List<QuestionModel>.from(questions)..shuffle(Random());
      
      setState(() {
        _questions = shuffled.take(10).toList();
        _isLoading = false;
      });
      
      _startTimer();
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
    // Full marks (30 points) if answered within first 2 seconds (8+ seconds left)
    // Then -2 points per second: 7->28, 6->26, 5->24, 4->22, 3->20, 2->18, 1->16, 0->14
    const int fullMarkThreshold = 8;
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerAnimationController.dispose();
    _optionAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary.withValues(alpha: 0.1),
                colorScheme.surface,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated quiz icon
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.quiz,
                          size: 50,
                          color: colorScheme.primary,
                        ),
                      ),
                    );
                  },
                  onEnd: () => setState(() {}),
                ),
                const SizedBox(height: 32),
                // Loading text with dots animation
                _LoadingText(difficulty: widget.difficulty),
                const SizedBox(height: 24),
                // Progress indicator
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Fun tip
                Container(
                  margin: EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width * 0.14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getRandomTip(),
                          style: TextStyle(
                            color: Colors.amber[800],
                            fontSize: 13,
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colorScheme),
            _buildTimerBar(colorScheme),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildQuestionCard(question, colorScheme),
                    const SizedBox(height: 24),
                    ..._buildOptions(question, colorScheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Question ${_currentIndex + 1} of ${_questions.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBar(ColorScheme colorScheme) {
    final timerColor = _timeLeft <= 3 ? Colors.red : (_timeLeft <= 5 ? Colors.orange : Colors.green);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.timer,
            color: timerColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: _timerAnimation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _timeLeft / _timerDuration,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                    minHeight: 10,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '$_timeLeft',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: timerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionModel question, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getDifficultyColor(question.difficulty).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              question.difficulty.name.toUpperCase(),
              style: TextStyle(
                color: _getDifficultyColor(question.difficulty),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOptions(QuestionModel question, ColorScheme colorScheme) {
    final optionLabels = ['A', 'B', 'C', 'D'];
    final optionColors = [Colors.blue, Colors.orange, Colors.purple, Colors.teal];

    return List.generate(question.options.length, (index) {
      final isSelected = _selectedOptionIndex == index;
      final isCorrect = index == question.correctOptionIndex;
      final showResult = _hasAnswered;

      Color backgroundColor;
      Color borderColor;
      Color textColor;
      IconData? trailingIcon;

      if (showResult) {
        if (isCorrect) {
          backgroundColor = Colors.green.withValues(alpha: 0.2);
          borderColor = Colors.green;
          textColor = Colors.green.shade700;
          trailingIcon = Icons.check_circle;
        } else if (isSelected && !isCorrect) {
          backgroundColor = Colors.red.withValues(alpha: 0.2);
          borderColor = Colors.red;
          textColor = Colors.red.shade700;
          trailingIcon = Icons.cancel;
        } else {
          backgroundColor = const Color(0xFFE8EAED);
          borderColor = const Color(0xFFDADCE0);
          textColor = const Color(0xFF5F6368);
          trailingIcon = null;
        }
      } else {
        backgroundColor = optionColors[index].withValues(alpha: 0.1);
        borderColor = optionColors[index].withValues(alpha: 0.3);
        textColor = colorScheme.onSurface;
        trailingIcon = null;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _hasAnswered ? null : () => _selectOption(index),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: isSelected && showResult
                    ? [
                        BoxShadow(
                          color: borderColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: showResult
                          ? (isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.grey))
                              .withValues(alpha: 0.2)
                          : optionColors[index].withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        optionLabels[index],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: showResult
                              ? (isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.grey))
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
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (trailingIcon != null)
                    Icon(
                      trailingIcon,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 28,
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
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('Leave Quiz?'),
          ],
        ),
        content: const Text('Your progress will be lost. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getRandomTip() {
    final tips = [
      'Answer quickly for more points! ⚡',
      'You have 10 seconds per question ⏱️',
      'Stay calm and do your best! 💪',
      'Learning is fun! 🌟',
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
