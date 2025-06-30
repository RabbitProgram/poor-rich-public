import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../config/config.dart';

class SpeechService {
  final _speechToText = SpeechToText();
  var _speechEnabled = false;
  var _wordsSpoken = '';
  double _confidenceLevel = 0;

  /// マイクの権限をリクエストして音声認識を初期化
  Future<bool> requestPermissionAndInitialize() async {
    // マイクの権限をリクエスト
    final micPermission = await Permission.microphone.request();
    if (micPermission != PermissionStatus.granted) {
      return false;
    }

    _speechEnabled = await _speechToText.initialize();
    return _speechEnabled;
  }

  /// 音声認識の初期化（権限チェックなし）
  Future<bool> initializeSpeech() async {
    if (!_speechEnabled) {
      _speechEnabled = await _speechToText.initialize();
    }
    return _speechEnabled;
  }

  /// 音声認識を開始
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    Function()? onComplete,
    Function(double)? onSoundLevel,
  }) async {
    if (!_speechEnabled) {
      // 権限と初期化を同時に行う
      final initialized = await requestPermissionAndInitialize();
      if (!initialized) {
        onError('マイクの権限が必要です');
        return;
      }
    }

    await _speechToText.listen(
      onResult: (result) {
        _wordsSpoken = result.recognizedWords;
        _confidenceLevel = result.confidence;
        onResult(_wordsSpoken);

        // 音声認識が完了したとき（final result）にコールバックを呼ぶ
        if (result.finalResult && onComplete != null) {
          onComplete();
        }
      },
      onSoundLevelChange: (level) {
        // 音声レベルの変化をコールバック
        if (onSoundLevel != null) {
          onSoundLevel(level);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'ja_JP',
      cancelOnError: true,
    );
  }

  /// 音声認識を停止
  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  /// 音声認識が利用可能かチェック
  bool get isEnabled => _speechEnabled;

  /// 現在音声認識中かチェック
  bool get isListening => _speechToText.isListening;

  /// 認識された言葉を取得
  String get wordsSpoken => _wordsSpoken;

  /// 信頼度を取得
  double get confidenceLevel => _confidenceLevel;

  /// 商品価格を推測するAPI呼び出し
  Future<Map<String, dynamic>> estimatePrice(String description) async {
    try {
      final response = await http.post(
        Uri.parse(Config.estimatePriceApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'description': description}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {'success': true, 'estimatedPrice': data['estimated_price']};
        } else {
          return {'success': false, 'error': data['error']};
        }
      } else {
        return {'success': false, 'error': 'サーバーエラー: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'ネットワークエラー: $e'};
    }
  }
}
