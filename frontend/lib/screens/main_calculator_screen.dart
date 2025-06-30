import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../services/preferences_service.dart';
import '../services/speech_service.dart';
import '../utils/calculator.dart';
import '../widgets/calculator_button.dart';
import '../widgets/calculator_display.dart';
import '../widgets/speech_recognition_dialog.dart';
import 'camera_screen.dart';
import 'settings_screen.dart';

class MainCalculatorScreen extends HookWidget {
  const MainCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final display = useState('0');
    final currentValue = useState<double>(0);
    final myIncome = useState<double>(0);
    final targetIncome = useState<double>(0);
    final targetIncomeName = useState('');

    // 音声認識関連
    final speechService = useMemoized(SpeechService.new);
    final isListening = useState(false);
    final speechText = useState('');
    final isProcessing = useState(false);
    final soundLevel = useState<double>(0.0);

    // ダイアログの状態更新用コールバック
    final dialogStateSetter = useState<StateSetter?>(null);

    /// エラーダイアログを表示
    void showErrorDialog(String message) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('エラー'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }

    /// 価格推測
    Future<void> estimatePrice(String description) async {
      isListening.value = false; // API通信開始時に音声認識を停止
      isProcessing.value = true;
      // ダイアログの状態も更新
      dialogStateSetter.value?.call(() {
        isListening.value = false;
        isProcessing.value = true;
      });

      try {
        final result = await speechService.estimatePrice(description);

        if (result['success'] == true) {
          final estimatedPrice = result['estimatedPrice'] as int;
          display.value = estimatedPrice.toString();
          currentValue.value = estimatedPrice.toDouble();
        } else {
          showErrorDialog('価格推測に失敗しました: ${result['error']}');
        }
      } catch (e) {
        showErrorDialog('エラーが発生しました: $e');
      } finally {
        isProcessing.value = false;
        // ダイアログの状態も更新
        dialogStateSetter.value?.call(() {
          isProcessing.value = false;
        });

        // API取得完了表示を500ms維持
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    /// 音声認識完了時の処理
    Future<void> handleSpeechRecognitionComplete() async {
      // 音声認識完了後はisListeningをfalseにせず、そのままAPI通信に移行

      // 認識されたテキストがあれば価格推測を実行
      if (speechText.value.isNotEmpty) {
        await estimatePrice(speechText.value);
      }

      // API取得完了後、ダイアログを閉じる
      if (context.mounted) {
        Navigator.of(context).pop();
        // ダイアログが閉じられたのでコールバックをクリア
        dialogStateSetter.value = null;
      }
    }

    /// 音声認識をキャンセル
    Future<void> cancelListening() async {
      await speechService.stopListening();
      isListening.value = false;
      speechText.value = '';
      soundLevel.value = 0;
      dialogStateSetter.value?.call(() {
        isListening.value = false;
        speechText.value = '';
        soundLevel.value = 0;
      });

      // ダイアログを閉じる
      Navigator.of(context).pop();
      dialogStateSetter.value = null;
    }

    /// 音声認識ダイアログを表示
    void showSpeechRecognitionDialog() {
      showDialog(
        context: context,
        barrierDismissible: false, // タップでのキャンセルはダイアログ内で制御
        builder:
            (context) => PopScope(
              canPop: false,
              onPopInvoked: (didPop) async {
                if (!didPop) {
                  await cancelListening();
                }
              },
              child: StatefulBuilder(
                builder: (context, setDialogState) {
                  // ビルドフェーズ完了後にダイアログの状態更新コールバックを保存
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    dialogStateSetter.value = setDialogState;
                  });

                  return SpeechRecognitionDialog(
                    isListening: isListening.value,
                    recognizedText: speechText.value,
                    soundLevel: soundLevel.value,
                    isProcessing: isProcessing.value,
                    onCancel: cancelListening,
                  );
                },
              ),
            ),
      );
    }

    /// 音声認識を開始
    Future<void> startListening() async {
      isListening.value = true;
      speechText.value = '';

      // ダイアログを表示
      showSpeechRecognitionDialog();

      await speechService.startListening(
        onResult: (text) {
          print('音声認識結果: $text'); // デバッグ用ログ
          speechText.value = text;
          // ダイアログの状態も更新
          dialogStateSetter.value?.call(() {
            speechText.value = text;
          });
        },
        onError: (error) {
          isListening.value = false;
          dialogStateSetter.value?.call(() {
            isListening.value = false;
          });
          Navigator.of(context).pop(); // ダイアログを閉じる
          showErrorDialog('音声認識エラー: $error');
        },
        onComplete: () {
          // 音声認識完了時に自動で処理を続行
          handleSpeechRecognitionComplete();
        },
        onSoundLevel: (level) {
          soundLevel.value = level;
          // ダイアログの状態も更新
          dialogStateSetter.value?.call(() {
            soundLevel.value = level;
          });
        },
      );
    }

    /// 音声認識を停止（手動停止時用）
    Future<void> stopListening() async {
      await speechService.stopListening();
      isListening.value = false;
      dialogStateSetter.value?.call(() {
        isListening.value = false;
      });

      // ダイアログを閉じる
      if (context.mounted) {
        Navigator.of(context).pop();
        dialogStateSetter.value = null;

        if (speechText.value.isNotEmpty) {
          await estimatePrice(speechText.value);
        }
      }
    }

    /// 音声認識切り替え
    Future<void> toggleListening() async {
      if (isListening.value) {
        await stopListening();
      } else {
        await startListening();
      }
    }

    Future<void> saveSettings() async {
      await PreferencesService.saveSettings(
        myIncome: myIncome.value, // 既に円単位なので、そのまま保存
        targetIncome: targetIncome.value,
        targetIncomeName: targetIncomeName.value,
      );
    }

    Future<void> navigateToSettings() async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute<Map<String, dynamic>>(
          builder:
              (context) => SettingsScreen(
                myIncome: myIncome.value,
                targetIncome: targetIncome.value,
                targetIncomeName: targetIncomeName.value,
              ),
        ),
      );

      if (result != null) {
        myIncome.value = result['my_income'] as double;
        targetIncome.value = result['target_income'] as double;
        targetIncomeName.value = result['target_income_name'] as String;
        await saveSettings();
      }
    }

    Future<void> navigateToCamera() async {
      final relativeValue = Calculator.calculateRelativeValue(
        currentValue: currentValue.value,
        myIncome: myIncome.value,
        targetIncome: targetIncome.value,
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => CameraScreen(
                targetIncomeName: targetIncomeName.value,
                targetIncome: targetIncome.value,
                relativeValue: relativeValue,
                currentValue: currentValue.value,
                myIncome: myIncome.value,
              ),
        ),
      );
    }

    Future<void> loadSettings() async {
      final myIncomeData = await PreferencesService.getMyIncome();
      final targetIncomeData = await PreferencesService.getTargetIncome();
      final targetIncomeNameData =
          await PreferencesService.getTargetIncomeName();

      myIncome.value = myIncomeData; // 既に円単位で保存されているので、そのまま使用
      targetIncome.value = targetIncomeData;
      targetIncomeName.value = targetIncomeNameData;

      // 初回起動時は設定画面を表示
      if (myIncome.value == 0 || targetIncome.value == 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigateToSettings();
        });
      }
    }

    useEffect(() {
      loadSettings();
      return null;
    }, []);

    void onNumberPressed(String number) {
      String newDisplay;
      if (display.value == '0') {
        newDisplay = number;
      } else {
        newDisplay = display.value + number;
      }

      // 最大値999999999を超えないようにチェック
      final newValue = double.tryParse(newDisplay) ?? 0;
      if (newValue <= 999999999) {
        display.value = newDisplay;
        currentValue.value = newValue;
      }
    }

    void onClear() {
      display.value = '0';
      currentValue.value = 0;
    }

    void onDelete() {
      if (display.value.length > 1) {
        display.value = display.value.substring(0, display.value.length - 1);
      } else {
        display.value = '0';
      }
      currentValue.value = double.tryParse(display.value) ?? 0;
    }

    final relativeValue = Calculator.calculateRelativeValue(
      currentValue: currentValue.value,
      myIncome: myIncome.value,
      targetIncome: targetIncome.value,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('マッチ売りの電卓'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: navigateToCamera,
            tooltip: 'カメラ撮影',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: navigateToSettings,
            tooltip: '設定',
          ),
        ],
      ),
      body: Column(
        children: [
          // ディスプレイ
          CalculatorDisplay(
            targetIncomeName: targetIncomeName.value,
            targetIncome: targetIncome.value,
            relativeValue: relativeValue,
            currentValue: currentValue.value,
            myIncome: myIncome.value,
          ),

          // 電卓ボタン
          Expanded(
            child: Material(
              elevation: 8,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    // 1行目 - 操作ボタン
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton(
                            text: 'C',
                            onPressed: onClear,
                            isSpecial: true,
                          ),
                          CalculatorButton(
                            text: '⌫',
                            onPressed: onDelete,
                            isSpecial: true,
                          ),
                          // 音声認識ボタン
                          CalculatorButton(
                            text: '',
                            icon: Icons.mic_none,
                            onPressed:
                                isProcessing.value ? null : toggleListening,
                            isLoading: isProcessing.value,
                            customBackgroundColor: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    // 2行目
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton(
                            text: '7',
                            onPressed: () => onNumberPressed('7'),
                          ),
                          CalculatorButton(
                            text: '8',
                            onPressed: () => onNumberPressed('8'),
                          ),
                          CalculatorButton(
                            text: '9',
                            onPressed: () => onNumberPressed('9'),
                          ),
                        ],
                      ),
                    ),
                    // 3行目
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton(
                            text: '4',
                            onPressed: () => onNumberPressed('4'),
                          ),
                          CalculatorButton(
                            text: '5',
                            onPressed: () => onNumberPressed('5'),
                          ),
                          CalculatorButton(
                            text: '6',
                            onPressed: () => onNumberPressed('6'),
                          ),
                        ],
                      ),
                    ),
                    // 4行目
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton(
                            text: '1',
                            onPressed: () => onNumberPressed('1'),
                          ),
                          CalculatorButton(
                            text: '2',
                            onPressed: () => onNumberPressed('2'),
                          ),
                          CalculatorButton(
                            text: '3',
                            onPressed: () => onNumberPressed('3'),
                          ),
                        ],
                      ),
                    ),
                    // 5行目 - 特殊ボタン
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton(
                            text: '0',
                            onPressed: () => onNumberPressed('0'),
                          ),
                          CalculatorButton(
                            text: '00',
                            onPressed: () => onNumberPressed('00'),
                          ),
                          CalculatorButton(
                            text: '000',
                            onPressed: () => onNumberPressed('000'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
