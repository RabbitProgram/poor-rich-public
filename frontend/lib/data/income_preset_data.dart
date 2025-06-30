import 'package:poor_rich/gen/assets.gen.dart';
import '../models/income_preset.dart';

class IncomePresetData {
  IncomePresetData._();

  static final presets = [
    IncomePreset(
      name: '年金受給者',
      amount: 876972,
      assetPath: Assets.images.nenkinTechouObaasan.path,
    ),
    IncomePreset(
      name: '生活保護受給者',
      amount: 1440000,
      assetPath: Assets.images.seikatsuhogoMan.path,
    ),
    IncomePreset(
      name: '新卒社員',
      amount: 2500000,
      assetPath: Assets.images.shinsyakaijinRunMan2.path,
    ),
    IncomePreset(
      name: '普通の男性',
      amount: 5000000,
      assetPath: Assets.images.motemoteIkemen.path,
    ),
    IncomePreset(
      name: '東京都港区',
      amount: 13970000,
      assetPath: Assets.images.minatoku.path,
    ),
    IncomePreset(
      name: '社長',
      amount: 20000000,
      assetPath: Assets.images.kaisyaDesk1SyachouMan.path,
    ),
  ];
}
