import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/number_formatter.dart';

class CompletePage extends StatelessWidget {
  const CompletePage({
    super.key,
    required this.myIncome,
    required this.targetIncome,
    required this.targetIncomeName,
  });
  final double myIncome;
  final double targetIncome;
  final String targetIncomeName;

  @override
  Widget build(BuildContext context) {
    // 年収差の計算
    final incomeDifference = targetIncome - (myIncome * 10000);
    final isRicher = incomeDifference < 0;
    final differenceInManYen = (incomeDifference.abs() / 10000).round();
    final differenceText =
        '${NumberFormatter.formatNumberWithCommas(differenceInManYen.toDouble())}万円';

    // 時給差の計算（年間2000時間労働想定）
    final myHourlyWage = (myIncome * 10000) / 2000;
    final targetHourlyWage = targetIncome / 2000;
    final hourlyDifference = targetHourlyWage - myHourlyWage;
    final hourlyDifferenceText = NumberFormatter.formatNumberWithCommas(
      hourlyDifference.abs().round().toDouble(),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40), // 上部に余白を追加
          // チェックアイコン
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.shade100,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 60,
              color: Colors.green.shade600,
            ),
          ),

          const SizedBox(height: 24),

          // 完了メッセージ
          Text(
            '設定が完了しました',
            style: GoogleFonts.notoSansJp(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 42),

          // 比較結果の表示
          Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.notoSansJp(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                  children: [
                    const TextSpan(text: 'あなたは '),
                    TextSpan(
                      text: targetIncomeName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: isRicher ? ' より\n' : ' より\n'),
                    TextSpan(
                      text: differenceText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            isRicher
                                ? Colors.green.shade600
                                : Colors.orange.shade600,
                      ),
                    ),
                    TextSpan(text: isRicher ? ' 多く稼いでいます！' : ' 少ない年収です'),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '時給換算で ${isRicher ? '+' : '-'} $hourlyDifferenceText 円の差があります',
                style: GoogleFonts.notoSansJp(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          const SizedBox(height: 42),

          // 励ましのメッセージ
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber.shade700,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  isRicher
                      ? '素晴らしい！あなたの努力が実を結んでいますね。\nこの電卓で日々の支出を時給換算して、\nより賢い消費を心がけましょう！'
                      : 'この電卓を使って支出を時給換算すると、\n$targetIncomeNameの働く価値がよく分かります。\n目標に向けて一歩ずつ進んでいきましょう！',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 14,
                    color: Colors.amber.shade700,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
