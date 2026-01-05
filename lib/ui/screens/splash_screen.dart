import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamicquiz/core/localization/app_localizations.dart';
import 'package:islamicquiz/data/providers/shared_prefs_provider.dart';
import 'package:islamicquiz/data/services/question_seeder.dart';
import 'package:islamicquiz/ui/screens/admin/admin_panel_screen.dart';
import 'package:islamicquiz/ui/screens/home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  // Secret admin access - tap logo 7 times quickly
  int _tapCount = 0;
  DateTime? _lastTapTime;
  static const int _requiredTaps = 7;
  static const Duration _tapTimeout = Duration(seconds: 2);

  String _adminPin = '';

  bool _navigationCancelled = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_rotateController);
    
    _controller.forward();

    getAdminPin();
    
    // Initialize app and navigate
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Seed questions on first launch
    try {
      final prefs = ref.read(sharedPrefsProvider);
      final seeder = QuestionSeeder(prefs: prefs);
      await seeder.seedIfNeeded();
    } catch (e) {
      debugPrint('Question seeding failed: $e');
    }

    // Wait for animation to complete (minimum 3 seconds)
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted && !_navigationCancelled) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _handleSecretTap() {
    final now = DateTime.now();
    
    // Reset if too much time passed since last tap
    if (_lastTapTime != null && now.difference(_lastTapTime!) > _tapTimeout) {
      _tapCount = 0;
    }
    
    _lastTapTime = now;
    _tapCount++;
    
    if (_tapCount >= _requiredTaps) {
      _tapCount = 0;
      _navigationCancelled = true;
      _showPinDialog();
    }
  }

  Future<void> getAdminPin() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('adminPin')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('Admin PIN not found');
        return;
      }

      final data = snapshot.docs.first.data();
      _adminPin = data['pin']?.toString() ?? '';
    } catch (e) {
      debugPrint('error getting admin pin $e');
    }
  }

  void _showPinDialog() {
    final pinController = TextEditingController();
    String? errorText;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Admin Access'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter admin PIN to continue'),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 5,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  border: const OutlineInputBorder(),
                  errorText: errorText,
                  prefixIcon: const Icon(Icons.lock),
                  counterText: '',
                ),
                onSubmitted: (_) => _verifyPin(pinController.text, context, setDialogState, (e) => errorText = e),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigationCancelled = false;
                _navigateToHome();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _verifyPin(pinController.text, context, setDialogState, (e) => errorText = e),
              child: const Text('Enter'),
            ),
          ],
        ),
      ),
    );
  }

  void _verifyPin(String pin, BuildContext dialogContext, StateSetter setDialogState, Function(String?) setError) {
    if (pin.trim().isNotEmpty && pin == _adminPin) {
      Navigator.pop(dialogContext);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
      );
    } else {
      setDialogState(() => setError('Incorrect PIN'));
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    bool darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: darkMode? [
              colorScheme.primary.withValues(alpha: 0.6),
              colorScheme.primary.withValues(alpha: 0.5),
            ] : [
              colorScheme.primary,
              colorScheme.primaryContainer,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(15, (index) => _buildFloatingParticle(index)),
            
            // Rotating decorative circles
            Center(
              child: RotationTransition(
                turns: _rotateAnimation,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: RotationTransition(
                turns: Tween<double>(begin: 1.0, end: 0.0).animate(_rotateController),
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Enhanced logo with pulsing glow
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: GestureDetector(
                          onTap: _handleSecretTap,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.5),
                                  blurRadius: 60,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white30, width: 2),
                              ),
                              child: Center(
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: 50,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      // App Title with shimmer effect
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withValues(alpha: 0.8),
                            Colors.white,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds),
                        child: Text(
                          'ISLAMIC QUIZ',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 5.0,
                            shadows: [
                              Shadow(
                                blurRadius: 20,
                                color: Colors.black.withValues(alpha: 0.4),
                                offset: const Offset(0, 4),
                              ),
                              Shadow(
                                blurRadius: 40,
                                color: Colors.white.withValues(alpha: 0.3),
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context);
                            return Text(
                              l10n.masterYourKnowledge,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFloatingParticle(int index) {
    final size = 4.0 + (index % 3) * 2.0;
    final duration = 3000 + (index % 5) * 1000;
    
    return Positioned(
      left: (index * 73.0) % MediaQuery.of(context).size.width,
      top: (index * 97.0) % MediaQuery.of(context).size.height,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: duration),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(
              20 * (value - 0.5) * (index % 2 == 0 ? 1 : -1),
              30 * (value - 0.5),
            ),
            child: Opacity(
              opacity: (0.3 + 0.4 * (1 - (value - 0.5).abs() * 2)).clamp(0.0, 1.0),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
