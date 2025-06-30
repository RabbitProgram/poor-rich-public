import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SpeechRecognitionDialog extends HookWidget {
  const SpeechRecognitionDialog({
    super.key,
    required this.isListening,
    required this.recognizedText,
    required this.onCancel,
    this.soundLevel = 0.0,
    this.isProcessing = false,
  });

  final bool isListening;
  final String recognizedText;
  final double soundLevel;
  final bool isProcessing;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final isCancelled = useState(false);
    final frozenButtonColor = useState<Color?>(null);
    final frozenGlowColor = useState<Color?>(null);

    // 音量レベルを0.0-1.0に正規化
    double normalizeSoundLevel() {
      return ((soundLevel + 160).clamp(0.0, 160.0) / 160.0).clamp(0.0, 1.0);
    }

    // 現在の状態に応じたグローエフェクトの色を取得
    Color getCurrentGlowColor() {
      if (!isListening) return Colors.green;

      final normalizedLevel = normalizeSoundLevel();
      if (normalizedLevel < 0.3) {
        return Colors.blue; // 静か
      } else if (normalizedLevel < 0.7) {
        return Colors.orange; // 中程度
      } else {
        return Colors.red; // 大きな音
      }
    }

    // 音量レベルに応じた色を取得
    Color getSoundBasedColor() {
      if (isCancelled.value) return frozenGlowColor.value ?? Colors.blue;
      return getCurrentGlowColor();
    }

    // 現在の状態に応じたボタンの色を取得
    Color getCurrentButtonColor() {
      if (isProcessing) {
        return Colors.orange;
      } else if (isListening) {
        return getSoundBasedColor();
      } else {
        return Colors.green;
      }
    }

    // アニメーションするかどうかを判定
    bool shouldAnimate() {
      if (isCancelled.value) return false;
      return isListening && !isProcessing;
    }

    // 状態に応じたテキストを取得
    String getStatusText() {
      if (isCancelled.value || isListening) {
        return '価格を推測する\n物の名前を話してください...';
      } else if (isProcessing) {
        return '価格を推測中...';
      } else {
        return '音声認識完了';
      }
    }

    // 状態に応じたボタンのアイコンを取得
    Widget getButtonIcon() {
      if (isCancelled.value) {
        return const Icon(
          Icons.mic,
          color: Colors.white,
          size: 40,
        ); // キャンセル時はマイクアイコンを維持
      } else if (isProcessing) {
        return const SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        );
      } else if (isListening) {
        return const Icon(Icons.mic, color: Colors.white, size: 40);
      } else {
        return const Icon(Icons.check, color: Colors.white, size: 40);
      }
    }

    // ヘルプテキストを取得
    String getHelpText() {
      if (isCancelled.value || isListening) {
        return '外側をタップしてキャンセル';
      }
      return '認識が完了しました';
    }

    void handleCancel() {
      isCancelled.value = true;
      // キャンセル時点での色を保存
      frozenButtonColor.value = getCurrentButtonColor();
      frozenGlowColor.value = getCurrentGlowColor();
      onCancel();
    }

    return GestureDetector(
      onTap: handleCancel,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black54,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 閉じるボタン
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: handleCancel,
                          icon: const Icon(Icons.close),
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // タイトル
                    Text(
                      getStatusText(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // AvatarGlowを使用したマイクボタン
                    SizedBox(
                      height: 200,
                      child: AvatarGlow(
                        animate: shouldAnimate(),
                        glowColor: getSoundBasedColor(),
                        child: Material(
                          elevation: 8,
                          shape: const CircleBorder(),
                          child: CircleAvatar(
                            backgroundColor: getCurrentButtonColor(),
                            radius: 40,
                            child: getButtonIcon(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 認識されたテキスト
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 60),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        recognizedText.isNotEmpty ? recognizedText : '認識中',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              recognizedText.isNotEmpty
                                  ? Colors.black87
                                  : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 説明テキスト
                    Text(
                      getHelpText(),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
