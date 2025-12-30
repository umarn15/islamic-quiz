import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamicquiz/data/providers/shared_prefs_provider.dart';
import 'package:islamicquiz/data/services/question_seeder.dart';
import 'package:islamicquiz/ui/screens/admin/admin_panel_screen.dart';
import 'package:islamicquiz/ui/screens/auth/login_screen.dart';
import 'package:islamicquiz/ui/screens/home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Secret admin access - tap logo 7 times quickly
  int _tapCount = 0;
  DateTime? _lastTapTime;
  static const int _requiredTaps = 7;
  static const Duration _tapTimeout = Duration(milliseconds: 2500);

  String _adminPin = '';

  bool _navigationCancelled = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
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
      final user = FirebaseAuth.instance.currentUser;
      final destination = user != null ? const HomeScreen() : const LoginScreen();
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => destination),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        // Added a subtle gradient for depth
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Optional: Add a low-opacity background pattern here
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Improved Secret Tap Target
                      GestureDetector(
                        onTap: _handleSecretTap,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1), // Glassmorphism effect
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
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
                      const SizedBox(height: 40),

                      // App Title with better font styling
                      Text(
                        'ISLAMIC QUIZ',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4.0, // Increased tracking for a modern look
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle with a "pill" background
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Master your knowledge',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.2,
                          ),
                        ),
                      )
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
}
