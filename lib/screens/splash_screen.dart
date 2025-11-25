import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../config/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final authProvider = context.read<AuthProvider>();
    await authProvider.initialize();
    
    if (!mounted) return;
    
    if (authProvider.isAuthenticated) {
      final user = authProvider.currentUser;
      if (user?.isAdmin == true) {
        Navigator.of(context).pushReplacementNamed('/admin-home');
      } else if (user?.isEmployee == true) {
        Navigator.of(context).pushReplacementNamed('/employee-home');
      } else {
        Navigator.of(context).pushReplacementNamed('/child-home');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo
              Container(
                padding: const EdgeInsets.all(20),
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icons/drozdovo.jpg',
                  fit: BoxFit.contain,
                ),
              ).animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms)
                .shimmer(delay: 800.ms, duration: 1500.ms),
              
              const SizedBox(height: 40),
              
              // App name
              Text(
                'Detský Pas',
                style: AppTheme.headingLarge.copyWith(
                  color: Colors.white,
                  fontSize: 42,
                ),
              ).animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 10),
              
              Text(
                'Zbieraj pečiatky a získavaj body!',
                style: AppTheme.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ).animate()
                .fadeIn(delay: 500.ms, duration: 600.ms),
              
              const SizedBox(height: 60),
              
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ).animate()
                .fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}

