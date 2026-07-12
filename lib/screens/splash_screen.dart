// screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/languages.dart';
import '../widgets/oxywatch_logo.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const SplashScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _dotIndex = 0;
  Timer? _dotTimer;
  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();

    _dotTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        _dotIndex = (_dotIndex + 1) % 3;
      });
    });

    _navigateTimer = Timer(const Duration(milliseconds: 3200), () {
      widget.onNext();
    });
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    _navigateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF1B3A5C),
      body: SafeArea(
        child: Center(  // 🔥 WRAP DENGAN CENTER
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,  // 🔥 CENTER VERTIKAL
              crossAxisAlignment: CrossAxisAlignment.center,  // 🔥 CENTER HORIZONTAL
              children: [
                // Logo
                const OxyWatchLogo(size: 80),
                const SizedBox(height: 20),
                const Text(
                  'OxyWatch',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                // 🔥 DUA BARIS - INDONESIA & ENGLISH
                Column(
                  children: [
                    Text(
                      'AI OxyWatch memantau secara aktif',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AI OxyWatch is actively monitoring',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: const Color(0xFFFFFFFF).withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // 🔥 LOADING DOTS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final bool isActive = index == _dotIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF4FC3F7)
                            : const Color(0xFF4FC3F7).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Text(
                  'v1.0',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: Color(0xFFA8B2C0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}