import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamicquiz/data/providers/shared_prefs_provider.dart';
import 'package:islamicquiz/data/services/question_seeder.dart';
import 'package:islamicquiz/ui/screens/admin/admin_panel_screen.dart';
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

  // Secret admin access - tap logo 5 times quickly
  int _tapCount = 0;
  DateTime? _lastTapTime;
  static const int _requiredTaps = 5;
  static const Duration _tapTimeout = Duration(seconds: 2);
  
  // Admin PIN - change this to your secret PIN
  static const String _adminPin = '78659';

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
    if (pin == _adminPin) {
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
      backgroundColor: colorScheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Islamic Star Icon - SECRET TAP TARGET
                GestureDetector(
                  onTap: _handleSecretTap,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.star,
                      size: 60,
                      color: colorScheme.tertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // App Title
                const Text(
                  'Islamic Quiz',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Subtitle
                const Text(
                  'Learn Islam through interactive quizzes',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
