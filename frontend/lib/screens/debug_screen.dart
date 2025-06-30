import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  var _isClearing = false;

  Future<void> _clearAllData() async {
    setState(() {
      _isClearing = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('すべてのデータをクリアしました'),
            backgroundColor: Colors.green,
          ),
        );

        // オンボーディング画面に戻る
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClearing = false;
        });
      }
    }
  }

  Future<void> _showClearConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'データクリア確認',
              style: GoogleFonts.notoSansJp(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'すべての設定データをクリアします。\nこの操作は取り消せません。\n\n本当に実行しますか？',
              style: GoogleFonts.notoSansJp(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('キャンセル', style: GoogleFonts.notoSansJp()),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'クリア',
                  style: GoogleFonts.notoSansJp(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );

    if (result == true) {
      await _clearAllData();
    }
  }

  Future<Map<String, dynamic>> _getStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final data = <String, dynamic>{};

    for (final key in keys) {
      final value = prefs.get(key);
      data[key] = value;
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'デバッグ画面',
          style: GoogleFonts.notoSansJp(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 警告メッセージ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'デバッグモードで実行中です',
                      style: GoogleFonts.notoSansJp(
                        fontWeight: FontWeight.w500,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // データクリアセクション
            Text(
              'データ管理',
              style: GoogleFonts.notoSansJp(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'すべてのデータをクリア',
                    style: GoogleFonts.notoSansJp(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '保存されているすべての設定データを削除し、初期状態に戻します。',
                    style: GoogleFonts.notoSansJp(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isClearing ? null : _showClearConfirmDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child:
                          _isClearing
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'データをクリア',
                                style: GoogleFonts.notoSansJp(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 保存データ表示セクション
            Text(
              '保存データ',
              style: GoogleFonts.notoSansJp(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _getStoredData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'エラー: ${snapshot.error}',
                        style: GoogleFonts.notoSansJp(color: Colors.red),
                      ),
                    );
                  }

                  final data = snapshot.data ?? {};

                  if (data.isEmpty) {
                    return Center(
                      child: Text(
                        '保存されているデータはありません',
                        style: GoogleFonts.notoSansJp(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: data.keys.length,
                      itemBuilder: (context, index) {
                        final key = data.keys.elementAt(index);
                        final value = data[key];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  key,
                                  style: GoogleFonts.notoSansJp(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  value.toString(),
                                  style: GoogleFonts.notoSansJp(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
