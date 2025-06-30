import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_calculator_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/preferences_service.dart';

void main() {
  runApp(const PoorRichCalculatorApp());
}

class PoorRichCalculatorApp extends StatelessWidget {
  const PoorRichCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 現在のフォーカスを外してキーボードを閉じる
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: 'マッチ売りの電卓',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00ACC1)),
          useMaterial3: true,
          textTheme: GoogleFonts.notoSansJpTextTheme(),
          fontFamily: GoogleFonts.notoSansJp().fontFamily,
        ),
        home: const AppHome(),
      ),
    );
  }
}

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PreferencesService.isOnboardingCompleted(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isOnboardingCompleted = snapshot.data ?? false;

        if (isOnboardingCompleted) {
          return const MainCalculatorScreen();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }
}
