import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../services/permission_service.dart';
import '../widgets/calculator_display.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    required this.targetIncomeName,
    required this.targetIncome,
    required this.relativeValue,
    required this.currentValue,
    required this.myIncome,
  });

  final String targetIncomeName;
  final double targetIncome;
  final double relativeValue;
  final double currentValue;
  final double myIncome;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  final _screenshotController = ScreenshotController();
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  var _isCameraInitialized = false;
  late AnimationController _shutterAnimationController;
  late Animation<double> _shutterAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    // シャッターアニメーションの初期化（高速化）
    _shutterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );

    _shutterAnimation = Tween<double>(begin: 0, end: 0.4).animate(
      CurvedAnimation(
        parent: _shutterAnimationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _shutterAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras[0],
          ResolutionPreset.high,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('カメラの初期化エラー: $e');
    }
  }

  Future<void> _captureScreenshot() async {
    try {
      // 権限をチェック（初回のみ）
      var hasPermission = await PermissionService.isStoragePermissionGranted();
      if (!hasPermission) {
        hasPermission = await PermissionService.requestStoragePermission();
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('写真保存の権限が必要です'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }

      // 即座にシャッターアニメーション開始（視覚的フィードバック）
      unawaited(_playShutterAnimation());

      // 並行してスクリーンショット撮影と保存処理を実行
      final captureAndSave = _captureAndSaveQuickly();

      // アニメーションと撮影処理を並行実行（待機しない）
      unawaited(captureAndSave);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // エラー時もアニメーションをリセット
        _shutterAnimationController.reset();
      }
    }
  }

  // 高速なシャッターアニメーション
  Future<void> _playShutterAnimation() async {
    await _shutterAnimationController.forward();
    if (mounted) {
      await _shutterAnimationController.reverse();
    }
  }

  // 高速なスクリーンショット撮影と保存
  Future<void> _captureAndSaveQuickly() async {
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        // 保存処理をバックグラウンドで実行（UI をブロックしない）
        unawaited(_saveImageInBackground(image));
      }
    } catch (e) {
      print('高速撮影エラー: $e');
    }
  }

  // バックグラウンドで画像を保存
  Future<void> _saveImageInBackground(Uint8List image) async {
    try {
      // 一時ファイルとして保存
      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/poor_rich_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      // ギャラリーに保存
      await Gal.putImage(imagePath);

      // 一時ファイルを削除
      await imageFile.delete();

      // 保存完了（SnackBarは表示しない）
    } catch (e) {
      // バックグラウンド保存でエラーが発生した場合
      print('画像保存エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存に失敗しました'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // 撮影してシェア（保存はしない）
  Future<void> _captureAndShare() async {
    try {
      // 即座にシャッターアニメーション開始（視覚的フィードバック）
      unawaited(_playShutterAnimation());

      // スクリーンショットを撮影
      final image = await _screenshotController.capture();
      if (image != null) {
        // 一時ファイルとして保存（ギャラリーには保存しない）
        final directory = await getTemporaryDirectory();
        final imagePath =
            '${directory.path}/poor_rich_share_${DateTime.now().millisecondsSinceEpoch}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);

        // 画像をシェア
        await Share.shareXFiles([XFile(imagePath)], text: '相対金額計算アプリで撮影した画像です');

        // 一時ファイルを削除
        await imageFile.delete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('シェアに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // エラー時もアニメーションをリセット
        _shutterAnimationController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('カメラ撮影', style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),

                // スクリーンショット対象範囲
                Screenshot(
                  controller: _screenshotController,
                  child: ColoredBox(
                    color: Colors.white,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // カメラビュー（正方形、角丸、1/3サイズ）
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          child: FractionallySizedBox(
                            widthFactor: 4 / 5,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    children: [
                                      // カメラプレビュー
                                      if (_isCameraInitialized &&
                                          _cameraController != null)
                                        Positioned.fill(
                                          child: Center(
                                            child: SizedBox.expand(
                                              child: FittedBox(
                                                fit: BoxFit.cover,
                                                child: SizedBox(
                                                  width:
                                                      _cameraController!
                                                          .value
                                                          .previewSize!
                                                          .height,
                                                  height:
                                                      _cameraController!
                                                          .value
                                                          .previewSize!
                                                          .width,
                                                  child: CameraPreview(
                                                    _cameraController!,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        // カメラが初期化されていない場合
                                        Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          color: Colors.black,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),

                                      // カメラビュー用シャッターエフェクト
                                      AnimatedBuilder(
                                        animation: _shutterAnimation,
                                        builder: (context, child) {
                                          return Positioned.fill(
                                            child: Container(
                                              color: Colors.black.withOpacity(
                                                _shutterAnimation.value,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 相対金額表示パネル
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          child: CalculatorDisplay(
                            targetIncomeName: widget.targetIncomeName,
                            targetIncome: widget.targetIncome,
                            relativeValue: widget.relativeValue,
                            currentValue: widget.currentValue,
                            myIncome: widget.myIncome,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // 撮影ボタンとシェアボタン
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Stack(
                    children: [
                      // 撮影ボタン（中央配置）
                      Align(
                        child: GestureDetector(
                          onTap: _captureScreenshot,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade100,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // シェアボタン（シャッターボタンの右側）
                      Positioned(
                        left:
                            MediaQuery.of(context).size.width / 2 +
                            40 +
                            20, // シャッターボタン右端 + 20px間隔
                        top: 10, // シャッターボタンより少し下に配置
                        child: GestureDetector(
                          onTap: _captureAndShare,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.share,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
