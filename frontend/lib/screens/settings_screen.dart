import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';

import '../data/income_preset_data.dart';
import '../models/income_preset.dart';
import '../utils/number_formatter.dart';
import 'debug_screen.dart';

class SettingsScreen extends HookWidget {
  const SettingsScreen({
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
    final myIncomeController = useTextEditingController(
      text: myIncome > 0 ? (myIncome / 10000).round().toString() : '',
    );
    final selectedTargetIncome = useState(targetIncome);
    final selectedTargetIncomeName = useState(targetIncomeName);

    Widget buildIncomeCard(IncomePreset preset) {
      final isSelected = selectedTargetIncome.value == preset.amount;

      // ユーザーの年収を取得（入力中の値を優先）
      var userIncome = 0.0;
      final inputText = myIncomeController.text.trim();
      final inputIncome = double.tryParse(inputText);

      if (inputIncome != null && inputIncome > 0) {
        userIncome = inputIncome * 10000; // 万円を円に変換
      } else if (myIncome > 0) {
        userIncome = myIncome * 10000; // myIncomeは万円単位なので円に変換
      }

      // 動的に比較結果を取得
      final comparisonCategory =
          userIncome > 0
              ? preset.getCategoryComparison(userIncome)
              : '---'; // ユーザー年収が未設定の場合
      final comparisonColor =
          userIncome > 0 ? preset.getComparisonColor(userIncome) : Colors.grey;

      // 自分の年収と同じかどうかを判定（万円単位で比較）
      final userIncomeInManYen = userIncome / 10000; // 円を万円に変換
      final presetIncomeInManYen = preset.amount / 10000; // 円を万円に変換
      final isSameAsMyIncome =
          userIncome > 0 &&
          userIncomeInManYen.round() == presetIncomeInManYen.round();

      return Opacity(
        opacity: isSameAsMyIncome ? 0.85 : 1.0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isSelected
                      ? comparisonColor
                      : isSameAsMyIncome
                      ? Colors.grey.shade400
                      : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            color:
                isSelected
                    ? comparisonColor.withValues(alpha: 0.1)
                    : isSameAsMyIncome
                    ? Colors.grey.shade200
                    : Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap:
                    isSameAsMyIncome
                        ? null
                        : () {
                          selectedTargetIncome.value = preset.amount;
                          selectedTargetIncomeName.value = preset.name;
                        },
                child: Stack(
                  children: [
                    // 背景画像
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Image.asset(
                          preset.assetPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // 画像の読み込みに失敗した場合は空のコンテナを表示
                            return Container();
                          },
                        ),
                      ),
                    ),
                    // カード下1/3のグラデーション背景
                    Positioned(
                      left: 1,
                      right: 1,
                      bottom: 1,
                      height: 100, // カードの約1/3の高さ
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent, // 上部は透明
                              Colors.black.withOpacity(
                                isSameAsMyIncome ? 0.35 : 0.4,
                              ),
                              Colors.black.withOpacity(
                                isSameAsMyIncome ? 0.5 : 0.6,
                              ), // 下部は濃い黒
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    // メインコンテンツ
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: comparisonColor.withOpacity(
                                    isSameAsMyIncome ? 0.08 : 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: comparisonColor.withOpacity(
                                      isSameAsMyIncome ? 0.65 : 1.0,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  comparisonCategory,
                                  style: TextStyle(
                                    color: comparisonColor.withOpacity(
                                      isSameAsMyIncome ? 0.8 : 1.0,
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: comparisonColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                preset.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSameAsMyIncome
                                          ? Colors.white.withOpacity(0.75)
                                          : Colors.white,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                '${NumberFormatter.formatNumberWithCommas(preset.amount / 10000)}'
                                ' 万円',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isSameAsMyIncome
                                          ? Colors.white.withOpacity(0.65)
                                          : Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // 同じ年収の場合の説明テキスト
                              if (isSameAsMyIncome) ...[
                                const Gap(4),
                                Text(
                                  '自分の年収と同じため選択できません',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100], // 背景を若干グレーに
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Colors.grey[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 年収部分
            const Text(
              'あなたの年収',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const Gap(16),
            TextField(
              controller: myIncomeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixText: '万円',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00ACC1), width: 2),
                ),
              ),
              onChanged: (value) {
                // リアルタイムで比較表示を更新
                final inputIncome = double.tryParse(value);

                if (inputIncome != null && inputIncome > 0) {
                  final userIncome = inputIncome * 10000;

                  // 現在選択中の項目が「同じ」になった場合は次の有効な項目を選択
                  if (selectedTargetIncome.value > 0) {
                    final userIncomeInManYen = userIncome / 10000;
                    final selectedIncomeInManYen =
                        selectedTargetIncome.value / 10000;
                    if (userIncomeInManYen.round() ==
                        selectedIncomeInManYen.round()) {
                      // 現在選択中の項目のインデックスを取得
                      final currentIndex = IncomePresetData.presets.indexWhere(
                        (preset) => preset.amount == selectedTargetIncome.value,
                      );

                      if (currentIndex != -1) {
                        // 次の有効な項目を探す
                        IncomePreset? nextValidPreset;

                        // まず現在の項目より後ろから探す
                        for (
                          var i = currentIndex + 1;
                          i < IncomePresetData.presets.length;
                          i++
                        ) {
                          final preset = IncomePresetData.presets[i];
                          final presetIncomeInManYen = preset.amount / 10000;
                          if (userIncomeInManYen.round() !=
                              presetIncomeInManYen.round()) {
                            nextValidPreset = preset;
                            break;
                          }
                        }

                        // 後ろに見つからなければ前から探す
                        if (nextValidPreset == null) {
                          for (var i = 0; i < currentIndex; i++) {
                            final preset = IncomePresetData.presets[i];
                            final presetIncomeInManYen = preset.amount / 10000;
                            if (userIncomeInManYen.round() !=
                                presetIncomeInManYen.round()) {
                              nextValidPreset = preset;
                              break;
                            }
                          }
                        }

                        // 有効な項目が見つかった場合は選択、見つからなければリセット
                        if (nextValidPreset != null) {
                          selectedTargetIncome.value = nextValidPreset.amount;
                          selectedTargetIncomeName.value = nextValidPreset.name;
                        } else {
                          selectedTargetIncome.value = 0;
                          selectedTargetIncomeName.value = '';
                        }
                      }
                    }
                  }
                }
                // 入力が空の場合は何もしない（選択をそのまま維持）

                // UIは自動的に更新される（hooks使用のため）
              },
            ),
            const Gap(24),
            const Text(
              '換算したい年収を選択',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const Gap(16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: IncomePresetData.presets.length,
              itemBuilder: (context, index) {
                return buildIncomeCard(IncomePresetData.presets[index]);
              },
            ),
            const Gap(32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00ACC1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // キーボードを閉じる
                  FocusManager.instance.primaryFocus?.unfocus();

                  final myIncome =
                      double.tryParse(myIncomeController.text) ?? 0;
                  if (myIncome > 0 && selectedTargetIncome.value > 0) {
                    Navigator.pop(context, {
                      'my_income': myIncome * 10000,
                      'target_income': selectedTargetIncome.value,
                      'target_income_name': selectedTargetIncomeName.value,
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('年収と換算先を正しく設定してください')),
                    );
                  }
                },
                child: const Text(
                  '設定を保存',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // デバッグボタン（デバッグモードのみ）
            if (kDebugMode) ...[
              const Gap(16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DebugScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bug_report),
                      SizedBox(width: 8),
                      Text(
                        'デバッグ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
