import 'package:gal/gal.dart';

class PermissionService {
  /// 写真保存に必要な権限をリクエスト
  static Future<bool> requestStoragePermission() async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (hasAccess) {
        return true;
      }

      final requestGranted = await Gal.requestAccess();
      return requestGranted;
    } catch (e) {
      print('権限要求エラー: $e');
      return false;
    }
  }

  /// 写真保存権限の状態を確認
  static Future<bool> isStoragePermissionGranted() async {
    try {
      return await Gal.hasAccess();
    } catch (e) {
      print('権限確認エラー: $e');
      return false;
    }
  }
}
