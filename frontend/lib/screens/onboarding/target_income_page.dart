import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poor_rich/data/income_preset_data.dart';
import '../../utils/number_formatter.dart';

class TargetIncomePage extends StatelessWidget {
  const TargetIncomePage({
    super.key,
    required this.myIncome,
    required this.targetIncome,
    required this.targetIncomeName,
    required this.onTargetIncomeChanged,
  });
  final double myIncome;
  final double targetIncome;
  final String targetIncomeName;
  final Function(double, String) onTargetIncomeChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            '比較対象の年収を設定',
            style: GoogleFonts.notoSansJp(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '比較したい職業や年収を選択してください',
            style: GoogleFonts.notoSansJp(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 24),

          // プリセット選択
          ...IncomePresetData.presets.asMap().entries.map((entry) {
            final index = entry.key;
            final preset = entry.value;
            final isSelected =
                targetIncome == preset.amount &&
                targetIncomeName == preset.name;

            // 自分の年収と同じかどうかを判定（万円単位で比較）
            final userIncomeInManYen = myIncome; // myIncomeは既に万円単位
            final presetIncomeInManYen = preset.amount / 10000; // 円を万円に変換
            final isSameAsMyIncome =
                myIncome > 0 &&
                userIncomeInManYen.round() == presetIncomeInManYen.round();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap:
                      isSameAsMyIncome
                          ? null
                          : () {
                            onTargetIncomeChanged(preset.amount, preset.name);
                          },
                  borderRadius: BorderRadius.circular(12),
                  child: Opacity(
                    opacity: isSameAsMyIncome ? 0.85 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1)
                                : isSameAsMyIncome
                                ? Colors.grey.shade100
                                : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Theme.of(context).primaryColor
                                  : isSameAsMyIncome
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // アイコン
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                preset.assetPath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.grey.shade400,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // メインコンテンツ
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 職業名
                                Text(
                                  preset.name,
                                  style: GoogleFonts.notoSansJp(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isSameAsMyIncome
                                            ? Colors.grey.shade600
                                            : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // 年収と比較チップを横並びで配置
                                Row(
                                  children: [
                                    Text(
                                      '${NumberFormatter.formatNumberWithCommas(preset.amount / 10000)}万円',
                                      style: GoogleFonts.notoSansJp(
                                        fontSize: 14,
                                        color:
                                            isSameAsMyIncome
                                                ? Colors.grey.shade500
                                                : Colors.grey.shade700,
                                      ),
                                    ),
                                    if (myIncome > 0) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: preset
                                              .getComparisonColor(
                                                myIncome * 10000,
                                              )
                                              .withOpacity(
                                                isSameAsMyIncome ? 0.12 : 0.15,
                                              ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: preset
                                                .getComparisonColor(
                                                  myIncome * 10000,
                                                )
                                                .withOpacity(
                                                  isSameAsMyIncome ? 0.65 : 1.0,
                                                ),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Text(
                                          preset.getCategoryComparison(
                                            myIncome * 10000,
                                          ),
                                          style: GoogleFonts.notoSansJp(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: preset
                                                .getComparisonColor(
                                                  myIncome * 10000,
                                                )
                                                .withOpacity(
                                                  isSameAsMyIncome ? 0.65 : 1.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                // 同じ年収の場合の説明テキスト
                                if (isSameAsMyIncome) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '自分の年収と同じため選択できません',
                                    style: GoogleFonts.notoSansJp(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // チェックアイコン
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
