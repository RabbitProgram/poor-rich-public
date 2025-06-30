import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calculate,
            size: 100,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 32),
          Text(
            'マッチ売りの電卓',
            style: GoogleFonts.notoSansJp(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'あなたの年収と比較対象の年収を設定して、\n金額の相対的な価値を計算できるアプリです',
            style: GoogleFonts.notoSansJp(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
