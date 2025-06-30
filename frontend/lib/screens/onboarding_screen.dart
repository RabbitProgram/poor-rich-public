import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poor_rich/data/income_preset_data.dart';
import 'package:poor_rich/models/income_preset.dart';
import 'package:poor_rich/screens/onboarding/complete_page.dart';
import 'package:poor_rich/screens/onboarding/my_income_page.dart';
import 'package:poor_rich/screens/onboarding/target_income_page.dart';
import '../services/preferences_service.dart';
import 'main_calculator_screen.dart';
import 'onboarding/welcome_page.dart';

class OnboardingScreen extends HookWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController();
    final currentPage = useState(0);
    final myIncome = useState<double>(0); // 万円単位で管理
    final targetIncome = useState<double>(0);
    final targetIncomeName = useState('');
    final myIncomeController = useTextEditingController();

    Future<void> completeOnboarding() async {
      // 万円を円に変換して保存
      await PreferencesService.saveSettings(
        myIncome: myIncome.value * 10000,
        targetIncome: targetIncome.value,
        targetIncomeName: targetIncomeName.value,
      );
      await PreferencesService.setOnboardingCompleted();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainCalculatorScreen()),
        );
      }
    }

    void nextPage() {
      // キーボードを閉じる
      FocusManager.instance.primaryFocus?.unfocus();

      if (currentPage.value < 3) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        completeOnboarding();
      }
    }

    void previousPage() {
      // キーボードを閉じる
      FocusManager.instance.primaryFocus?.unfocus();

      if (currentPage.value > 0) {
        pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    void updateMyIncome(double income) {
      myIncome.value = income;

      // 選択中の項目が無効になった場合の処理
      if (targetIncome.value > 0 && income > 0) {
        final userIncomeInManYen = income;
        final selectedIncomeInManYen = targetIncome.value / 10000;

        // 現在選択中の項目が「同じ」になった場合は次の有効な項目を選択
        if (userIncomeInManYen.round() == selectedIncomeInManYen.round()) {
          // 現在選択中の項目のインデックスを取得
          final currentIndex = IncomePresetData.presets.indexWhere(
            (preset) => preset.amount == targetIncome.value,
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
              if (userIncomeInManYen.round() != presetIncomeInManYen.round()) {
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
              targetIncome.value = nextValidPreset.amount;
              targetIncomeName.value = nextValidPreset.name;
            } else {
              targetIncome.value = 0;
              targetIncomeName.value = '';
            }
          }
        }
      }
    }

    void updateTargetIncome(double income, String name) {
      targetIncome.value = income;
      targetIncomeName.value = name;
    }

    bool canProceed() {
      switch (currentPage.value) {
        case 0:
          return true;
        case 1:
          return myIncome.value > 0;
        case 2:
          return targetIncome.value > 0 && targetIncomeName.value.isNotEmpty;
        case 3:
          return true;
        default:
          return false;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // プログレスインジケーター
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        color:
                            index <= currentPage.value
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // メインコンテンツ
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  currentPage.value = page;
                },
                children: [
                  const WelcomePage(),
                  MyIncomePage(
                    myIncome: myIncome.value,
                    myIncomeController: myIncomeController,
                    onIncomeChanged: updateMyIncome,
                  ),
                  TargetIncomePage(
                    myIncome: myIncome.value,
                    targetIncome: targetIncome.value,
                    targetIncomeName: targetIncomeName.value,
                    onTargetIncomeChanged: updateTargetIncome,
                  ),
                  CompletePage(
                    myIncome: myIncome.value,
                    targetIncome: targetIncome.value,
                    targetIncomeName: targetIncomeName.value,
                  ),
                ],
              ),
            ),

            // ナビゲーションボタン
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (currentPage.value > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: previousPage,
                        child: const Text('戻る'),
                      ),
                    ),
                  if (currentPage.value > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canProceed() ? nextPage : null,
                      child: Text(
                        currentPage.value == 2
                            ? '次へ'
                            : currentPage.value == 3
                            ? '開始'
                            : '次へ',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
